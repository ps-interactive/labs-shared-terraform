#!/bin/bash -x

#install and configure tools
sudo yum install -y nmap-ncat

#discover IP's and query ports to produce network traffic
private_ips=($(aws ec2 describe-instances --region us-west-2 --query Reservations[].Instances[].PrivateIpAddress --output text))
for ip in $${private_ips[@]}; do
    echo "Discovered IP: $ip"
    nc -v $ip 8083
    nc -v $ip 80
done