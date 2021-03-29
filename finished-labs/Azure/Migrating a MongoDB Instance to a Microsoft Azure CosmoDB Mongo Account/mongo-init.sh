#!/usr/bin/env bash
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
mkdir -p /var/lib/mongodb
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo cp ./mongod.conf /etc/mongod.conf
sudo chown mongodb:mongodb /etc/mongod.conf
sudo service mongod restart
sleep 10
wget https://raw.githubusercontent.com/ps-interactive/lab_azure_build-a-python-app-using-azure-cosmosdb-api-for-monogdb/main/source.csv
mongoimport --file source.csv --drop --collection movies --db pluralsight --type tsv --headerline
