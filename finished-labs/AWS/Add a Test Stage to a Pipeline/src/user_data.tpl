#!/bin/bash -xe
#install and configure aws codedeploy-agent
yum install -y ruby

cd /opt
curl -O https://aws-codedeploy-${region}.s3.amazonaws.com/latest/install

chmod +x ./install
./install auto

#install and configure apache web server
yum install -y polkit
yum install -y httpd
echo "Hello Pluralsight Cloud Labs Learner!" > /var/www/html/index.html
chmod 644 /var/www/html/index.html
systemctl start httpd

#codecommit interaction
yum install -y git
echo "${privatekey}" > ~/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
git config --system core.sshCommand 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
echo "Host git-codecommit.*.amazonaws.com" >> /root/.ssh/config
echo "User ${ssh_public_key_id}" >> /root/.ssh/config
echo "IdentityFile /root/.ssh/id_rsa" >> /root/.ssh/config
git clone ${clone_url_ssh}
cd ${repository_name}
echo 'Hello Pluralsight Cloud Lab Learner.</br>
</br>
This update was delivered via AWS CodePipeline & CodeDeploy!' > index.html
echo "${appspec}" > appspec.yml
echo '${buildspec}' > buildspec.yml
echo "${before_install}" > before_install.sh
git add index.html *.yml *.sh
git commit -m 'initial commit (hi Pluralsight!)'
git push
