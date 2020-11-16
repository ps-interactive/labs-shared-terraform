#!/bin/bash
sudo yum update -y
# install python3
sudo yum install python3 -y
#install lab tools
# Install jq
sudo yum install jq -y
# Install git
sudo yum install git -y

# Install PowerShell
# Register the Microsoft RedHat repository
curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
sudo yum install -y powershell
#################
## NOTE: Investigating options to make python3 default, python 2 is very sticky and persistent, 
## and instructions are unclear just how to set python3.X as default so subsequent pip installs go properly
##
## VIRTUAL ENVIRONMENT OPTION
##
# # create virtual environment for python3
# python3 -m venv my_app/env
# # activate the venv for rest of install steps
# ${HOME}/my_app/env/bin/activate
# # make python3 default on login
# echo "source ${HOME}/my_app/env/bin/activate" >> ${HOME}/.bashrc
##################
# #################
# ##
# ## ALIAS OPTION
# ##
# alias python=/usr/bin/python3.7
# which python3.7
# which python
# python --version
# # make python3 default on login
# sudo echo 'alias python=/usr/bin/python3.7' >> /home/ec2-user/.bashrc
# #################
##################
##
## LINK OPTION
##
## Change the default python  from python2 to python3
sudo rm /usr/bin/python
sudo ln -s /usr/bin/python3 /usr/bin/python
which python
python --version
##################


# install lab requirements that use python3
sudo easy_install pip
which pip
sudo pip install --upgrade pip
sudo pip install setuptools
sudo pip install wheel
# Install aws-shell
sudo pip install aws-shell --ignore-installed
# install http-aws
sudo pip install httpaws --ignore-installed


sudo echo 'end of config script'