#!/bin/sh
# Script that will find the the path for
# the serial number of a connected bergoz
# device
##########################################

DEVICE_PATH=/dev/ttyACM*

for SERIAL_DEVICE in $DEVICE_PATH ; do
    if [ ! -w "$SERIAL_DEVICE" ]; then
        echo "Permission issues on $SERIAL_DEVICE"
        exit 2
    fi

    DEVICE=$SERIAL_DEVICE

    echo 'Making environment Variable for path'
    echo "epicsEnvSet(IM01_PATH,${DEVICE})"
    echo "epicsEnvSet(IM01_PATH,${DEVICE})" > /tmp/im01_path
done
exit
