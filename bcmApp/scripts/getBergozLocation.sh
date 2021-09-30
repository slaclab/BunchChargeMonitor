#!/bin/sh
# Script that will find the the path for
# the serial number of a connected bergoz
# device
##########################################

DEVICE_PATH=/dev/ttyACM*

DEVICE_NUM=$(ls $DEVICE_PATH | wc -l)

if [ $DEVICE_NUM -eq 1 ]
then
    echo "The bergoz chassis is connected to $DEVICE_PATH" 
    DEVICE=$(ls $DEVICE_PATH)
fi

if [ $DEVICE_NUM -eq 0 ]
then
    echo Error no device connected on USB
    DEVICE=ERROR_NO_DEVICE
fi

if [ $DEVICE_NUM -gt 2 ]
then
    echo "Error more than one device connected on USB"
    DEVICE=ERROR_MULTIPLE
fi


echo 'Making environment Variable for path'
echo "epicsEnvSet(IM01_PATH,${DEVICE})"
echo "epicsEnvSet(IM01_PATH,${DEVICE})" > /tmp/im01_path

