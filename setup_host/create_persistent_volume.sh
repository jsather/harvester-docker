#!/bin/sh
# This file contains commandline instructions for mounting a volume named /dev/sdb

# Mount volume
if ! mount | grep /mnt/disks/disk-1 > /dev/null; then
    echo "Mounting volume at /mnt/disks/disk1"
    sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
    sudo mkdir -p /mnt/disks/disk-1
    sudo mount -o discard,defaults /dev/sdb /mnt/disks/disk-1
    sudo chmod a+w /mnt/disks/disk-1

    # Add persistent disk to fstab for auto mounting on reboot
    sudo cp /etc/fstab /etc/fstab.orig
    echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /mnt/disks/disk-1 ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab

    # Create training directories 
    sudo mkdir -p /mnt/disks/disk-1/results 
    sudo mkdir -p /mnt/disks/disk-1/buffer 
    sudo mkdir -p /mnt/disks/disk-1/combined 
    sudo touch /mnt/disks/disk-1/disp.out 
else
    echo "Volume already mounted at /mnt/disks/disk-1"
fi


# Create docker volume
curl -fsSL https://raw.githubusercontent.com/CWSpear/local-persist/master/scripts/install.sh | sudo bash
sudo docker volume create -d local-persist -o mountpoint=/mnt/disks/disk-1 --name=harvester_storage