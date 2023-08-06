#!/bin/bash

set -e
pwd=$(dirname $0)

$pwd/install.sh

export DISPLAY=:0

clear

echo "Simple HDMI CEC media server - v0.0.1"

cec-client | $pwd/server.sh $1
