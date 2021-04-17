#!/bin/bash

scriptDir=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

echo "Check if we are root"
uid=$(id -u)
if [ $uid -ne 0 ]
then 
    echo "Please run as root"
    exit 1
fi

echo "Installing python"
apt-get install -y python

echo "Installing additional libs need to convertation process"
if [[ $(lsb_release -rs) == "18.04" ]]; then
    apt-get install -y curl libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 libsdl2-2.0-0 libfdk-aac-dev
    # http://repos.interior.udelar.edu.uy/ubuntu/archives/pool/universe/libv/libva/
    wget http://repos.interior.udelar.edu.uy/ubuntu/archives/pool/universe/libv/libva/libva1_1.8.3-2_amd64.deb
    apt install ./libva1_1.8.3-2_amd64.deb 
    wget http://repos.interior.udelar.edu.uy/ubuntu/archives/pool/universe/libv/libva/libva-x11-1_1.8.3-2_amd64.deb
    apt install ./libva-x11-1_1.8.3-2_amd64.deb 
    wget http://repos.interior.udelar.edu.uy/ubuntu/archives/pool/universe/libv/libva/libva-drm1_1.8.3-2_amd64.deb
    apt install ./libva-drm1_1.8.3-2_amd64.deb
elif [[ $(lsb_release -rs) == "16.04" ]]; then 
    apt-get install -y curl libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 libsdl2-2.0-0 libva-x11-1 libva-drm1 libfdk-aac-dev
else
    echo "Non-compatible version"
    exit 0
fi

echo "Copy ffmpeg to /opt/ffmpeg folder"
mkdir -p /opt/ffmpeg
cp $scriptDir/ffmpeg/* /opt/ffmpeg
chmod 755 /opt/ffmpeg/ffmpeg
chmod 755 /usr/local/bigbluebutton/core/scripts/post_publish/*

echo "Seting up NGINX to make MP4 files available for download"
mkdir /var/www/bigbluebutton-default/download
ln -s /var/bigbluebutton/published/presentation /var/www/bigbluebutton-default/download
chmod 0755 /var/bigbluebutton/published/presentation
# sudo chown -R bigbluebutton:bigbluebutton /var/bigbluebutton

echo "Creating log directory"
mkdir -p /var/log/bigbluebutton/download
chown -R bigbluebutton:bigbluebutton /var/log/bigbluebutton/download
chmod -R ugo+rwx /var/log/bigbluebutton/download/

echo "Coping ruby script"
if [[ $(lsb_release -rs) == "18.04" ]]; then
cp $scriptDir/src/python_executer.rb /usr/local/bigbluebutton/core/scripts/post_publish
elif [[ $(lsb_release -rs) == "16.04" ]]; then
cp $scriptDir/src/python_executer16.rb /usr/local/bigbluebutton/core/scripts/post_publish
fi

echo "Coping python scripts to post_publish directory"
cp $scriptDir/src/*.py /usr/local/bigbluebutton/core/scripts/post_publish
echo "Set permisions"
sudo chmod -R 755 /usr/local/bigbluebutton/core/scripts/post_publish/

echo "BBB-Download Installaltion Done."