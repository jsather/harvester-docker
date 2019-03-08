#!/bin/bash -x

# Updated by Jonathon Sather 9/9/18

# Start XVnc/X/Lubuntu
chmod -f 777 /tmp/.X11-unix
# From: https://superuser.com/questions/806637/xauth-not-creating-xauthority-file (squashes complaints about .Xauthority)
touch ~/.Xauthority
xauth generate :0 . trusted
rm -rf /tmp/.X1-lock # added
rm -rf /tmp/.X11-unix/X1 # added 
/opt/TurboVNC/bin/vncserver -SecurityTypes None


# Start NoVNC. self.pem is a self-signed cert.
if [ $? -eq 0 ] ; then
    /opt/noVNC/utils/launch.sh --vnc localhost:5901 --cert /root/self.pem --listen 40001;
fi
