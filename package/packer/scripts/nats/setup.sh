#!/bin/bash
set -x
SERVICE_NAME=natssd
# update apt
sudo apt-get update
# install required libs
sudo apt-get -y install unzip rsync nfs-common
# download nats
curl -L https://github.com/nats-io/nats-streaming-server/releases/download/v0.3.0/nats-streaming-server-linux-amd64.zip > ./nats-streaming-server-linux-amd64.zip

# unzip
unzip nats-streaming-server-linux-amd64.zip
sudo cp ./nats-streaming-server-linux-amd64/nats-streaming-server /opt/nats-streaming-server
sudo chmod +x /opt/nats-streaming-server

# fix ownership and permissions
sudo chown root:root etc/systemd/system/natssd\@.service
sudo chmod 664 etc/systemd/system/natssd\@.service

# service template install
sudo rsync -arv etc/ /etc/

# per instance setup of systemd template
# Moving this setup to a terraform
# expects /nats-data/svc_id-instance_id to be configured similar to below.
# INSTANCE_ID=1
# SVC_ID=$SERVICE_NAME-$INSTANCE_ID
# sudo useradd -m -d /home/$SVC_ID -s /usr/sbin/nologin -c "$SVC_ID service user." -u 1019 $SVC_ID
# 
# # copy everything in ./home/ to /home/service_user
# sudo cp -R home/* /home/$SVC_ID
# sudo chown $SVC_ID:$SVC_ID -R /home/$SVC_ID 
# 
# sudo systemctl enable $SERVICE_NAME\@$INSTANCE_ID.service

# upgrade ubuntu
sudo apt-get -qq -y dist-upgrade 
