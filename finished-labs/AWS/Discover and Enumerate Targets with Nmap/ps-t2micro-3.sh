#! /bin/bash


echo "begin proxy test" >> script.test
response=\$$(sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 curl --write-out '%%{http_code}' --silent --output /dev/null www.google.com)
while [ \$$response -ne "200" ]; do
    echo \$$response >> script.test
    sleep 10
    response=\$$(sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888curl --write-out '%%{http_code}' --silent --output /dev/null www.google.com)
done

echo "success1">> ~/peaceinourtime



echo "success1">> ~/peaceinourtime
sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 apt update
sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 DEBIAN_FRONTEND=noninteractive apt -y --force-yes install mysql-server
sed 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf > /tmp/mysqld.cnf
sudo mv /tmp/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
sudo ufw allow 3306
sudo systemctl stop mysql
sudo systemctl daemon-reload
sudo systemctl start mysql
sudo mysql mysql -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'admin';"
sudo mysql mysql -e "CREATE DATABASE plumbus5000;"
sudo mysql -e "GRANT ALL PRIVILEGES ON plumbus5000.* TO 'admin'@'%';"