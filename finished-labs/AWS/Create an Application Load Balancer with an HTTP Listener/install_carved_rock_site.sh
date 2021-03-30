#!/bin/bash
yum update -y
amazon-linux-extras install -y php7.2
yum install -y httpd
systemctl start httpd
systemctl enable httpd
yum install -y git
cd /var/www/
git clone https://github.com/ps-interactive/lab_aws_create-application-load-balancer-with-http-listener
cp -R /var/www/lab_aws_create-application-load-balancer-with-http-listener/carved_rock_site/* /var/www/html/