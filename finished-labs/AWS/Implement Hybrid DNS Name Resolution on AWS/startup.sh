#!/bin/bash

## Enable password authentication (w/ no public IP for EC2 Connect avoid pre-shared SSH key)
sed -i 's/PasswordAuthentication\ no/PasswordAuthentication\ yes/' /etc/ssh/sshd_config
service sshd restart
echo 'ubuntu:pluralsight123' | chpasswd

## Wait for the network to come up before going any further
host="google.com"
max=600
timer=0
counter=15
echo "Waiting until network is available -- up to $max seconds"
while [ $timer -lt $max ]; do
  if ping -c1 -w1 -W1 -n $host &> /dev/null; then
    echo "Network detected!  Starting up!"
    break
  else
    timer=$(( $timer + $counter ))
    echo "Waiting for network, sleeping $counter seconds ( $timer / $max )"
    sleep $counter
  fi
done

## Disable built-in local DNS server to make way for Unbound
systemctl disable systemd-resolved.service
service systemd-resolved stop
service systemd-resolved status

## Use AWS local DNS resolver for resolving server's own DNS
mv -v /etc/resolv.conf /etc/resolv.conf.backup
echo "nameserver 169.254.169.253" > /etc/resolv.conf

## Install and configure Unbound
apt-get update && apt-get install -y unbound
cat << EOT > /etc/unbound/unbound.conf.d/lab-setup.conf
server:
  interface-automatic: yes
  interface: 0.0.0.0
  outgoing-interface: 0.0.0.0
  access-control: 192.168.0.0/24 allow
  access-control: 172.31.0.0/16 allow

  domain-insecure: corp.globomantics.com
  private-domain: corp.globomantics.com
  local-zone: corp.globomantics.com static
  local-data: "corp.globomantics.com. 7200 IN SOA localhost. admin.globomantics.com. 26676048 3600 1200 9600 300"
  local-data: "corp.globomantics.com. 7200 IN NS localhost."
  local-data: 'corp.globomantics.com. 7200 IN TXT "comment=Welcome to Globomantics corporate network!"'
  local-data: "ns.corp.globomantics.com. 300 IN A 192.168.0.53"
  local-data: "jump.corp.globomantics.com. 300 IN A 192.168.0.100"
EOT
service unbound restart

## Clean up hostname for prompt and get rid of host unresolvable warnings
echo "ns.corp.globomantics.com" > /etc/hostname
hostname ns.corp.globomantics.com
echo "192.168.0.53 ns.corp.globomantics.com" >> /etc/hosts
