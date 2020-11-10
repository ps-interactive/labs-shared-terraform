#! /bin/bash

echo "begin proxy test" >> script.test
response=\$$(sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 curl --write-out '%%{http_code}' --silent --output /dev/null www.google.com)
while [ \$$response -ne "200" ]; do
    echo \$$response >> script.test
    sleep 10
    response=\$$(sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888curl --write-out '%%{http_code}' --silent --output /dev/null www.google.com)
done

echo "success">> /home/ubuntu/peaceinourtime

sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 apt update
sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 apt -y install ec2-instance-connect
sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 apt -y install nmap
sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 apt -y install mysql-client
sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 DEBIAN_FRONTEND=noninteractive apt -y --force-yes install snort
mkdir /home/ubuntu/challenge2
echo 172.31.37.0/24 >> /home/ubuntu/challenge2/subnet-targets
echo 172.31.64.0/24 >> /home/ubuntu/challenge2/subnet-targets
echo 172.31.128.0/24 >> /home/ubuntu/challenge2/subnet-targets
mkdir /home/ubuntu/challenge3
echo "${micro_1_ip}" >> /home/ubuntu/challenge3/host-targets
echo "${micro_2_ip}" >> /home/ubuntu/challenge3/host-targets
echo "${micro_3_ip}">> /home/ubuntu/challenge3/host-targets
echo "${micro_4_ip}" >> /home/ubuntu/challenge3/host-targets
mkdir /home/ubuntu/challenge4
echo "${micro_1_ip} -p 22,80">> /home/ubuntu/challenge4/port-targets
echo "${micro_2_ip} -p 22,8080">> /home/ubuntu/challenge4/port-targets
echo "${micro_3_ip} -p 22,3306">> /home/ubuntu/challenge4/port-targets
echo "${micro_4_ip} -p 22,1433,3389,5985">> /home/ubuntu/challenge4/port-targets
mkdir /home/ubuntu/challenge5
echo "${micro_1_ip} -p 80 apache httpd">> /home/ubuntu/challenge5/service-targets
echo "${micro_2_ip} -p 8080 tomcat7">> /home/ubuntu/challenge5/service-targets
echo "${micro_3_ip} -p 3306 mysql">> /home/ubuntu/challenge5/service-targets
echo "${micro_1_ip}">> /home/ubuntu/challenge5/ssh-targets
echo "${micro_2_ip}">> /home/ubuntu/challenge5/ssh-targets
echo "${micro_3_ip}">> /home/ubuntu/challenge5/ssh-targets
echo "Happy Hunting">> /home/ubuntu/peaceinourtime