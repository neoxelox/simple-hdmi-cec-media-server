#!/bin/bash

if [ -z "$(which cec-client)" ]
then
    echo "CEC Client not installed"
    echo "Installing..."
    sudo apt install cec-utils
fi

if [ -z "$(which xdotool)" ]
then
    echo "XDoTool not installed"
    echo "Installing..."
    sudo apt-get install xdotool
fi

if [ -z "$(which vlc)" ]
then
    echo "OMX Player not installed"
    echo "Installing..."
    sudo apt-get install vlc
fi
