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
sudo http_proxy=http://tstark:pssecrocks@172.31.245.222:8888 apt install -y nmap
sudo ufw allow 3389
sudo ufw allow 1433
sudo ufw allow 5985
screen -dmS rdp bash -c 'sudo echo Solenya-rdp | ncat -k -l 3389'
screen -dmS mssql bash -c 'sudo echo micro-schwifty-sql | ncat -k -l 1433'
screen -dmS winrm bash -c 'sudo echo wabalabadubdub-winrm | ncat -k -l 5985'