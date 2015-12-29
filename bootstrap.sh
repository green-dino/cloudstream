#!/bin/bash
##########
# This script is part of the unidata/cloudstream Docker image.
#
# It sets up a VNC session accessible via a webbrowser using noVNC and
# then executes start.sh, if available.
#
# Instructions for use are at https://github.com/Unidata/cloudstream.
#
# Copyright Unidata 2015 http://www.unidata.ucar.edu
##########

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

###
# If HELP environmental variable is non-empty,
# cat the README file and exit.
###
if [ "x${HELP}" != "x" ]; then
    cat README.md
    exit
fi

###
# Set up vnc to use a password if USEPASS is non-empty.
###

if [ "x${USEPASS}" == "x" ]; then
    cp /home/${CUSER}/.xinitrc.nopassword /home/${CUSER}/.xinitrc
else
    mkdir -p /home/${CUSER}/.vnc
    cp /home/${CUSER}/.xinitrc.password /home/${CUSER}/.xinitrc
    x11vnc -storepasswd "${USEPASS}" /home/${CUSER}/.vnc/passwd
fi

xinit -- /usr/bin/Xvfb :1 -screen 0 $SIZEW\x$SIZEH\x$CDEPTH &
sleep 5

export DISPLAY=localhost:1

if [ "x${USENOVNC}" == "xTRUE" ]; then
    mv /home/${CUSER}/docs/self_unsigned.pem /home/${CUSER}/noVNC/utils/self.pem
    /home/${CUSER}/noVNC/utils/launch.sh --vnc 127.0.0.1:5901 &
fi

if [ -f /home/${CUSER}/start.sh ]; then
    /home/${CUSER}/start.sh
fi

echo "Session Running. Press [Return] to exit."
read