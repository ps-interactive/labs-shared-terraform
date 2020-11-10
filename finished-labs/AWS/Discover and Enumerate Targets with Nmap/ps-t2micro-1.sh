#! /bin/bash




echo "begin proxy test" >> script.test
response=\$$(sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 curl --write-out '%%{http_code}' --silent --output /dev/null www.google.com)
while [ \$$response -ne "200" ]; do
    echo \$$response >> script.test
    sleep 10
    response=\$$(sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888curl --write-out '%%{http_code}' --silent --output /dev/null www.google.com)
done


echo "success1">> ~/peaceinourtime

sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 apt update
sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 apt -y install apache2
sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 systemctl start apache2