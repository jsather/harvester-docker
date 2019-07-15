# harvester-docker
![harvester-gif](https://imgur.com/0dghLur.gif)

Browser-based harvesting environment using ROS and Gazebo on a Google Compute Engine Instance. For a video summary of the full project, click [here](https://youtu.be/C6hrCVv2B-o). 

This repo is a fork of [nvidia-docker-novnc](https://github.com/willkessler/nvidia-docker-novnc) that has been modified to work with [harvester-sim](https://github.com/jsather/harvester-sim) and [harvester-python](https://github.com/jsather/harvester-python). 

## Getting Started
These instructions will get you a copy of the project up and running using Google Compute Engine.

### Instance Setup
Create an instance with Ubuntu 16.04 with at least 1 GPU and attach a persistent disk. It is recommended to use a boot disk of at least 50GB and a persistent disk of at least 100GB. My setup is shown below:
![instance-setup](https://imgur.com/WVu58PV.jpg)
![instance-setup2](https://imgur.com/jddeMSO.jpg)
![instance-setup3](https://imgur.com/IcreLCp.jpg)

### Firewalls
Set up firewalls for VNC, noVNC, and NFS.
![firewalls](https://imgur.com/X1HPRr3.jpg)

### Installing
Clone the repo into your GCE instance.
```
mkdir ~/git
cd ~/git
git clone https://github.com/jsather/harvester-docker.git
```

Download the relevant CUDA runtine and dev packages from the [NVIDIA developer site](https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/), and place into project. 
```
mkdir ~/git/harvester-docker/harvester_project_build/cuda
mv libcudnn7_7.2.1.38-1+cuda9.0_amd64.deb ~/git/harvester-docker/harvester_project_build/cuda/
mv libcudnn7-dev_7.2.1.38-1+cuda9.0_amd64.deb ~/git/harvester-docker/harvester_project_build/cuda/
```

Run the preinstall script.
```
cd ~/git/harvester-docker
sudo ./preinstall.sh
```

Build the Docker container. This will take 30-60 minutes.
```
cd harvester
sudo ./build.sh
```

Start the Docker container to run your browser-based GUI.
```
cd harvester
sudo ./run.sh
```
Navigate to XX.XXX.XX.XXX:40001/vnc.html?host=XX.XXX.XX.XXX&port=40001, substituting your instance's external IP address.
![browser](https://imgur.com/NgCbpDg.jpg)

## Running the Simulated Environment
Open the terminal in the browser-based gui and source the catkin environment.
```
source /root/catkin_ws/devel/setup.bash
```

Run harvester_test.launch to spawn arm and randomly generated plant.
``` 
roslaunch harvester_gazebo harvester_test.launch
```

After testing, interface with [harvester-python](https://github.com/jsather/harvester-python) or your own agent. Note that the Dockerfile automatically clones a copy of harvester-python and harvester-sim into the ~/git/ folder of your container.

## Built With
* [Docker](https://www.docker.com/) - Container platform 
* [Gazebo](http://gazebosim.org) - Physics simulator
* [Google Compute Engine](https://cloud.google.com/compute/) - Remote high-performance VM
* [ROS](https://www.ros.org) - Robotics framework

## Author

* **Jonathon Sather** 

## License
This project is licensed under the MIT license - see [LICENSE](LICENSE) for details.

## Acknowledgments
* Dockerfile based off of [nvidia-docker-novnc](https://github.com/willkessler/nvidia-docker-novnc)
