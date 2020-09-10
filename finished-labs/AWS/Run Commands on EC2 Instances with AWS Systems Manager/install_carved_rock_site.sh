#!/bin/bash

yum update -y

# install and configure apache web server
yum install -y httpd
yum install -y git

cd /var/www/

# downloads the carved rock assest, unzips them and copies it to /var/www/html folder
git clone https://github.com/pputhran/carved-rock-fitness.git
cp -R /var/www/carved-rock-fitness/* /var/www/html/

chmod 644 /var/www/html/index.html

# adding iptable rules to drop any tcp packets on port 80 
yum install iptables-services -y
systemctl enable iptables
systemctl start iptables

iptables -A INPUT -p tcp --dport 80 -j DROP

iptables-save >  /etc/sysconfig/iptables

# start the apache server and ensuring its restarted even during a reboot
systemctl start httpd
systemctl enable httpd
systemctl restart httpd


