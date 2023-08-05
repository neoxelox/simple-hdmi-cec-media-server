#!/bin/bash

if [ -z "$(which cec-client)" ]
then
    echo "CEC Client not installed"
    echo "Installing..."
    sudo apt install -y cec-utils
fi

if [ -z "$(which dbus-send)" ]
then
    echo "QD Bus not installed"
    echo "Installing..."
    sudo apt-get install -y qdbus
fi

if [ -z "$(which cvlc)" ]
then
    echo "VLC not installed"
    echo "Installing..."
    sudo apt-get install -y vlc
fi
