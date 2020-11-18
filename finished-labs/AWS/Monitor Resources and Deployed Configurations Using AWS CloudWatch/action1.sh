#! /bin/bash

echo "success1">> ~/peaceinourtime
echo "${micro_1_ip}">> ~/peaceinourtime2
sudo sed '$a*/1 * * * * root nc ${micro_1_ip} 22 -w 60' /etc/crontab | tee /tmp/cron.tab
sudo mv /tmp/cron.tab /etc/crontab
sudo chown root:root /etc/crontab
sudo chmod 600 /etc/crontab
sudo systemctl restart cron
