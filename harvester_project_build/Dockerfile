FROM nvidia/cudagl:9.0-devel

LABEL maintainer="Jonathon Sather"
# Original dockerfile from: https://github.com/willkessler/nvidia-docker-novnc
# Mods by Jonathon Sather:
#    - Added NVIDIA software CUDA + CUDnn to set up for Tensorflow-gpu install
#    - Added additional ROS packages/Moveit and set up catkin workspace
#    - Added darknet and darkflow install + mods
#    - Customized desktop
#    - And more!

ARG SOURCEFORGE=https://sourceforge.net/projects
ARG TURBOVNC_VERSION=2.1.2
ARG VIRTUALGL_VERSION=2.5.2
ARG LIBJPEG_VERSION=1.5.2
ARG WEBSOCKIFY_VERSION=0.8.0
ARG NOVNC_VERSION=1.0.0

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils

RUN apt-get -y update && \
    apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -f && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates \
    curl wget emacs vim less sudo lsof net-tools git htop gedit gedit-plugins \
    unzip zip psmisc xz-utils \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    libpython-dev libsuitesparse-dev libeigen3-dev libsdl1.2-dev doxygen graphviz libignition-math2-dev \
    gcc \
    libc6-dev \
    libglu1 \
    libglu1:i386 \
    libopencv-dev \
    libxv1 \
    libxv1:i386 \
    lubuntu-desktop xvfb xterm terminator zenity mesa-utils \
    make cmake \
    python \
    python-dev \
    python-numpy \
    python-pip \
    python-virtualenv \
    ruby \
    searchmonkey \
    x11-xkb-utils \
    xauth \
    xfonts-base \
    xkb-data && \
    gem install rubystats && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    curl -fsSL -O ${SOURCEFORGE}/turbovnc/files/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
        -O ${SOURCEFORGE}/libjpeg-turbo/files/${LIBJPEG_VERSION}/libjpeg-turbo-official_${LIBJPEG_VERSION}_amd64.deb \
        -O ${SOURCEFORGE}/virtualgl/files/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb \
        -O ${SOURCEFORGE}/virtualgl/files/${VIRTUALGL_VERSION}/virtualgl32_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb && \
    sed -i 's/$host:/unix:/g' /opt/TurboVNC/bin/vncserver

ENV PATH ${PATH}:/opt/VirtualGL/bin:/opt/TurboVNC/bin

RUN curl -fsSL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz | tar -xzf - -C /opt && \
    curl -fsSL https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz | tar -xzf - -C /opt && \
    mv /opt/noVNC-${NOVNC_VERSION} /opt/noVNC && \
    chmod -R a+w /opt/noVNC && \
    mv /opt/websockify-${WEBSOCKIFY_VERSION} /opt/websockify && \
    cd /opt/websockify && make && \
    cd /opt/noVNC/utils && \
    ln -s /opt/websockify

COPY xorg.conf /etc/X11/xorg.conf
COPY index.html /opt/noVNC/index.html

# Defeat screen locking and power management
RUN mv /etc/xdg/autostart/light-locker.desktop /etc/xdg/autostart/light-locker.desktop_bak
RUN mv /etc/xdg/autostart/xfce4-power-manager.desktop /etc/xdg/autostart/xfce4-power-manager.desktop_bak

# Expose whatever port NoVNC will serve from. In our case it will be 40001, see ./start_desktop.sh
EXPOSE 40001
ENV DISPLAY :1

# Install desktop file for this user
RUN mkdir -p /root/Desktop
COPY ./firefox.desktop_applications /usr/share/applications/firefox.desktop
COPY ./terminator.desktop /root/Desktop
RUN mkdir -p /root/.config/terminator
COPY ./terminator_config /root/.config/terminator/config
COPY ./firefox.desktop /root/Desktop
COPY ./htop.desktop /root/Desktop
COPY ./self.pem /root/self.pem
# Precede bash on all new terminator shells with vglrun so that 3d graphics apps will use the GPU
RUN perl -pi -e 's/^Exec=terminator$/Exec=terminator -e "vglrun bash"/g' /usr/share/applications/terminator.desktop

# Set up wallpaper (strawberry themed)
COPY ./background.png /usr/share/lubuntu/wallpapers/1604-lubuntu-default-wallpaper.png
RUN mkdir -p /root/.vnc
COPY ./xstartup.turbovnc /root/.vnc/xstartup.turbovnc
RUN chmod a+x /root/.vnc/xstartup.turbovnc

# Install ROS
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > \
    /etc/apt/sources.list.d/ros-latest.list && \
    apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -f && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y ros-kinetic-desktop-full

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -f && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python-rosinstall \
    python-rosinstall-generator \
    python-wstool \
    build-essential \ 
    python-catkin-tools \ 
    clang-format-3.8 \
    ros-kinetic-geometry-msgs \
    ros-kinetic-gazebo-ros \
    ros-kinetic-trac-ik-kinematics-plugin \
    ros-kinetic-gazebo-ros-pkgs ros-kinetic-gazebo-ros-control \
    ros-kinetic-ros-control ros-kinetic-ros-controllers && \ 
    pip install --upgrade pyassimp  && \
    pip install cython && \
    rosdep init && \
    rosdep update 

# Upgrade Gazebo to latest v7 release
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \ 
    wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - && \
    apt-get update -y && apt-get install -y gazebo7

#Set up catkin workspace, install Moveit, and add modifications
RUN /bin/bash -c "mkdir -p /root/catkin_ws/src ;\
                  mkdir -p /mnt/nfs/harvester-ros ;\
                  ln -sf /mnt/nfs/harvester-ros /root/catkin_ws/src/ ;\
                  cd /root/catkin_ws ;\
                  wstool init src ;\ 
                  wstool merge -t src https://raw.githubusercontent.com/ros-planning/moveit/kinetic-devel/moveit.rosinstall ;\ 
                  wstool update -t src ;\ 
                  rosdep install -y --from-paths src --ignore-src --rosdistro kinetic ;\ 
                  catkin config --extend /opt/ros/kinetic --cmake-args -DCMAKE_BUILD_TYPE=Release ;\
                  cd /root/catkin_ws/src/moveit/moveit_ros/planning/planning_scene_monitor/include/moveit/planning_scene_monitor ;\
                  mv current_state_monitor.h current_state_monitor.h.orig"
COPY ./moveit/current_state_monitor.h /root/catkin_ws/src/moveit/moveit_ros/planning/planning_scene_monitor/include/moveit/planning_scene_monitor
RUN /bin/bash -c "cd /root/catkin_ws ;\
                  catkin build"

# Install cuDNN runtime and dev packages
COPY ./cuda/libcudnn7* /tmp/ 
RUN cd /tmp && \ 
    dpkg -i libcudnn7_7.2.1.38-1+cuda9.0_amd64.deb && \
    dpkg -i libcudnn7-dev_7.2.1.38-1+cuda9.0_amd64.deb && \ 
    rm -f /tmp/libcudnn7*

# Install Tensorflow 
RUN pip install tensorflow-gpu 

# Install Darknet, configure, and add modifications
# RUN mkdir -p /root/git && \ 
#     cd /root/git && \ 
#     git clone https://github.com/pjreddie/darknet.git && \ 
#     cd darknet && \ 
#     cp Makefile Makefile.orig && \ 
#     sed -i '/GPU/s/=.*/=1/' Makefile && \ 
#     sed -i '/CUDNN/s/=.*/=1/' Makefile && \ 
#     sed -i '/OPENCV/s/=.*/=1/' Makefile && \ 
#     sed -i '/OPENMP/s/=.*/=0/' Makefile && \ 
#     sed -i '/DEBUG/s/=.*/=0/' Makefile && \ 
#     make 
# RUN cd /root/git/darknet/python && \ 
#     mv darknet.py darknet.py.orig
# COPY ./darknet/darknet.py /root/git/darknet/python

# Install Darkflow and add modifications
RUN mkdir -p /root/git && \ 
    cd /root/git && \ 
    git clone https://github.com/thtrieu/darkflow.git && \ 
    cd darkflow && \ 
    pip install -e . && \ 
    mkdir built_graph && \
    cd darkflow/net && \ 
    mv build.py build.py.orig 
COPY ./darkflow/yolov2-tiny-strawb.meta /root/git/darkflow/built_graph
COPY ./darkflow/yolov2-tiny-strawb.pb /root/git/darkflow/built_graph
COPY ./darkflow/yolov2-tiny-strawb.cfg /root/git/darkflow/cfg
COPY ./darkflow/yolov2-tiny-strawb_final.weights /root/git/darkflow/bin
COPY ./darkflow/labels.txt /root/git/darkflow
COPY ./darkflow/build.py /root/git/darkflow/darkflow/net 


# Update .bashrc 
RUN echo "export GAZEBO_RESOURCE_PATH=/root/catkin_ws/src/harvester-ros/harvester_gazebo:$GAZEBO_RESOURCE_PATH" >> \
        /root/.bashrc && \ 
    echo "export GAZEBO_MODEL_PATH=/root/catkin_ws/src/harvester-ros/harvester_gazebo/models:$GAZEBO_MODEL_PATH" >> \
        /root/.bashrc && \ 
    echo "export PYTHONPATH=/mnt/nfs/harvester_python:/root/git/darknet/python:/root/git/darkflow/darkflow:$PYTHONPATH" >> \ 
        /root/.bashrc && \
    echo "source /opt/ros/kinetic/setup.bash" >> /root/.bashrc 

# Create some useful default aliases
RUN printf "%s\n" \
           "alias cp=\"cp -i\"" \
           "alias mv=\"mv -i\"" \
           "alias rm=\"rm -i\"" >> /root/.bash_aliases

COPY start_desktop.sh /usr/local/bin/start_desktop.sh

CMD /usr/local/bin/start_desktop.sh