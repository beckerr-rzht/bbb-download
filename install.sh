#!/bin/bash

# Check if we are root
uid=$(id -u)
if [ $uid -ne 0 ]
then 
    echo "Please run as root"
    exit 1
fi

# Install python
apt-get install -y python

# Install additional libs need to convertation process
if [[ $(lsb_release -rs) == "18.04" ]]; then
    apt-get install -y curl libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 libsdl2-2.0-0 libfdk-aac-dev
    # http://repos.interior.udelar.edu.uy/ubuntu/archives/pool/universe/libv/libva/
    wget http://repos.interior.udelar.edu.uy/ubuntu/archives/pool/universe/libv/libva/libva1_1.8.3-2_amd64.deb
    apt install ./libva1_1.8.3-2_amd64.deb 
    wget http://repos.interior.udelar.edu.uy/ubuntu/archives/pool/universe/libv/libva/libva-x11-1_1.8.3-2_amd64.deb
    apt install ./libva-x11-1_1.8.3-2_amd64.deb 
    wget http://repos.interior.udelar.edu.uy/ubuntu/archives/pool/universe/libv/libva/libva-drm1_1.8.3-2_amd64.deb
    apt install ./libva-drm1_1.8.3-2_amd64.deb
if [[ $(lsb_release -rs) == "16.04" ]]; then 
    apt-get install -y curl libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 libsdl2-2.0-0 libva-x11-1 libva-drm1 libfdk-aac-dev
else
    echo "Non-compatible version"
    exit 0
fi

# Copy ffmpeg to /opt/ffmpeg folder
mkdir -p /opt/ffmpeg
cp ffmpeg/* /opt/ffmpeg
chmod 755 /opt/ffmpeg/ffmpeg
chmod 755 /usr/local/bigbluebutton/core/scripts/post_publish/*

# Set up NGINX to make MP4 files available for createwebinar.com
mkdir /var/www/bigbluebutton-default/download
ln -s /var/bigbluebutton/published/presentation /var/www/bigbluebutton-default/download
chmod 0755 /var/bigbluebutton/published/presentation
# sudo chown -R bigbluebutton:bigbluebutton /var/bigbluebutton

# Create log directory
mkdir -p /var/log/bigbluebutton/download
chown -R bigbluebutton:bigbluebutton /var/log/bigbluebutton/download
chmod -R ugo+rw /var/log/bigbluebutton/download/

# Copy python scripts to post_publish directory
cp src/*.py /usr/local/bigbluebutton/core/scripts/post_publish

# Copy ruby script that controlls the download process
cp src/*.rb /usr/local/bigbluebutton/core/scripts/post_publish
