#!/bin/sh
# This file sets up nfs between development machine and GCE instance.
#
# Before running:
#   1. Set SERVER_IP and SERVER_DIR corresponding to host
#   2. Set up and configure nfs-kernel-server on host
#   3. Set destination directory

SERVER_IP=141.126.89.186
SERVER_DIR=/home/jonathon/projects/harvester/harvester_instance
DEST=/mnt/disks/nfs 

if ! mount | grep ${DEST} > /dev/null; then 
    sudo mkdir -p ${DEST} 
    sudo apt-get -y install nfs-common
    sudo mount ${SERVER_IP}:${SERVER_DIR} ${DEST}
    sudo echo "${SERVER_IP}:${SERVER_DIR} ${DEST} nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab
else
    echo "Volume already mounted at ${DEST}"
fi

curl -fsSL https://raw.githubusercontent.com/CWSpear/local-persist/master/scripts/install.sh | sudo bash
sudo docker volume create -d local-persist -o mountpoint=${DEST} --name=harvester_project