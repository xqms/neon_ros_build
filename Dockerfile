FROM kdeneon/plasma:testing

# Delft Mirror
RUN sudo bash -c '. /etc/lsb-release && echo "deb http://ftp.tudelft.nl/ros/ubuntu $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/ros-latest.list'

# ROS keys
RUN sudo bash -c 'wget -O- https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -'

RUN sudo apt-get update && sudo apt-get dist-upgrade -y && sudo apt-get install -y ros-noetic-ros-base

RUN sudo apt-get install -y python3-catkin-tools git python3-rosdep build-essential dh-python python3-all-dbg python3-all-dev python3-sphinx git-buildpackage bison debhelper-compat flex

RUN mkdir -p ws/src && cd ws/src && git clone -b melodic-devel https://github.com/ros-visualization/qt_gui_core.git

RUN . /opt/ros/noetic/setup.sh && sudo rosdep init && rosdep update --rosdistro=noetic && rosdep install --os ubuntu:focal -y --from-path . --ignore-src

# Patch shiboken2
RUN sudo sed -i 's/\/workspace//g' /usr/lib/x86_64-linux-gnu/cmake/Shiboken2-5.*/Shiboken2Targets-relwithdebinfo.cmake 

# Install newer sip
RUN git clone https://github.com/xqms/sip4.git && cd sip4 && gbp buildpackage --git-builder="debuild -i -I --no-sign" --git-ignore-new

RUN sudo dpkg -i sip-dev_4.19.25+dfsg-1_amd64.deb python3-sip_4.19.25+dfsg-1_amd64.deb python3-sip-dev_4.19.25+dfsg-1_amd64.deb

RUN sudo apt-get install -y ros-noetic-qt-gui equivs

RUN git clone --depth=1 -b debian/noetic/focal/qt_gui_cpp https://github.com/ros-gbp/qt_gui_core-release.git
RUN cd qt_gui_core-release && \
    dch -l .xqms2. "xqms build" && \
    mk-build-deps --install --root-cmd sudo --tool "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y" --remove && \
    DEB_BUILD_OPTIONS="nocheck parallel=8" debuild -b -uc -us

RUN sudo dpkg -i ros-noetic-qt-gui-cpp*.deb

#RUN . /opt/ros/noetic/setup.sh && cd ws && catkin build --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo

CMD bash

