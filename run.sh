#!/bin/bash

set -e

./install.sh

clear

echo "Simple HDMI CEC media server - v0.0.1"

cec-client | ./server.sh $1
