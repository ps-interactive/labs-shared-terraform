#! /bin/bash


echo "success1">> ~/peaceinourtime
sudo apt update
sudo apt -y install stress
sudo sed '$a*/1 * * * * root stress -t 60 -d 8 --hdd-bytes 300B' /etc/crontab | tee /tmp/cron.tab
sudo sed '$a*/5 * * * * root stress -t 120 -d 20 --hdd-bytes 3000B' /tmp/cron.tab | tee /tmp/cron.tab2
sudo mv /tmp/cron.tab2 /etc/crontab
sudo chown root:root /etc/crontab
sudo chmod 600 /etc/crontab
sudo systemctl restart cron
