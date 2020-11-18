#! /bin/bash

echo "success1">> ~/peaceinourtime
sudo apt update
sudo apt -y install stress
sudo sed '$a*/1 * * * * root stress -t 60 --cpu 4' /etc/crontab | tee /tmp/cron.tab
sudo mv /tmp/cron.tab /etc/crontab
sudo chown root:root /etc/crontab
sudo chmod 600 /etc/crontab
sudo systemctl restart cron
