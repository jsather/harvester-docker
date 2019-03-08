#/bin/bash

#docker run --init --runtime=nvidia --name=autonomous_sys_build --rm -it -e DISPLAY=:1 -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0:rw -p 40001:40001 autonomous_sys_build

if ! docker ps -a | grep harvester_project_build; then 
    docker run --init --runtime=nvidia --name=harvester_project_build -it -e DISPLAY=:1 -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0:rw  --mount type=volume,src=harvester_project,dst=/mnt/nfs --mount type=volume,src=harvester_storage,dst=/mnt/storage -p 40001:40001 harvester_project_build
else
    docker start -i harvester_project_build
fi
