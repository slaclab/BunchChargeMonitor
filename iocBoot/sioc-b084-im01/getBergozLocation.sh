#!/bin/sh
# Script that will find the the path for
# the serial number of a connected bergoz
# device
##########################################

DEVICE_PATH=/dev/ttyACM*
SERIAL_NUMBER=$(echo ${IM01} | tr '[:lower:]' '[:upper:]')
echo $SERIAL_NUMBER

for SERIAL_DEVICE in $DEVICE_PATH ; do
    if [ ! -w "$SERIAL_DEVICE" ]; then
        echo "Permission issues on $SERIAL_DEVICE"
        exit 2
    fi

    DEVICE=$SERIAL_DEVICE
    # start 'cat' process and save the PID
    cat $SERIAL_DEVICE >> /data/Reterived_Serial &
    CAT_PID=$!

    # configure serial port
    stty -F $SERIAL_DEVICE raw pass8 echo -crtscts cstopb

    # get register values
    echo -en "S0?\n\0" > $SERIAL_DEVICE

    # stop the 'cat' process by PID
    # wait for the 5 seconds to fill the file
    sleep 5
    kill $CAT_PID

    # Get one serial number from file
    FOUND_DEVICE=$(cat /data/Reterived_Serial | grep -iE -m 1 'S0:.{4}=.{8}')
    echo 'Found Serial Number ' $FOUND_DEVICE

    case $FOUND_DEVICE in
        *"$SERIAL_NUMBER"*)
            echo 'Making enviroment Variable for path'
            echo "epicsEnvSet(IM01_PATH,${DEVICE})"
            echo "epicsEnvSet(IM01_PATH,${DEVICE})" > /data/im01_path
        ;;
    esac

    rm /data/Reterived_Serial
done
exit