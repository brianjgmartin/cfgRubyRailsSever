#!/bin/bash

# Launch Instance and save instance ID 
# to variable "HADOOP_NODE_NAME_INST_ID"
RUBY_ON_RAILS_INST_ID="$(aws ec2 run-instances \
	--image-id ami-f0b11187 \
	--instance-type t2.micro \
	--key-name  irishkey \
	--security-groups  launch-wizard-7 \
	--region eu-west-1 | grep INSTANCE | awk '{print $8}')"

# Name The Instance by using 
# ${RUBY_ON_RAILS_INST_ID}
aws ec2 create-tags \
--resources ${RUBY_ON_RAILS_INST_ID} \
--tag Key=Name,Value=RailsServer
sleep 60

# Get Public IP Address of Ruby Server
PUB_IP_ADRS_RS="$(aws ec2 describe-instances \
 	--filters 'Name=tag:Name,Values=RailsServer' \
 	--output text \
 	--query 'Reservations[*].Instances[*].PublicIpAddress')"

#ssh Into Ruby Server and configure Instance 
ssh -i ~/.ssh/irishkey.pem ubuntu@${PUB_IP_ADRS_RS} bash -c "'
sudo apt-get update
sudo apt-get install curl -y
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -L https://get.rvm.io | bash -s stable --ruby
source /home/ubuntu/.rvm/scripts/rvm
rvm get stable --autolibs=enable
rvm install ruby
rvm --default use ruby-2.2.0
sudo apt-get install nodejs -y
gem update --system
gem install nokogiri
gem install rails --version=4.1.0
sudo apt-get install apache2 -y
sudo service apache2 restart
sudo apt-get install git -y
mkdir workspace
cd workspace
git clone https://github.com/brianjgmartin/mathsapp.git
cd mathsapp
bundle install
rails server &
'"