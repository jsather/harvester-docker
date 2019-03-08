#!/bin/bash
# Original build script from: https://github.com/willkessler/nvidia-docker-novnc
# Modified by Jonathon Sather
# Last updated: 9/9/18

echo "********************************************************************************"
echo ""
echo "Setting up the host."
echo ""
echo "********************************************************************************"

cd setup_host
./basics.sh
./install-nvidia-drivers.sh
./install-nvidia-docker2.sh
./add_xhost.sh
./create_nfs_volume.sh # added
./create_persistent_volume.sh # added
cd ..

echo "********************************************************************************"
echo ""
echo "Creating the docker container."
echo ""
echo "********************************************************************************"

docker build -t harvester_project_build harvester_project_build

echo "********************************************************************************"
echo ""
echo "All done. Now you can run the container by running run.sh."
echo ""
echo "********************************************************************************"
