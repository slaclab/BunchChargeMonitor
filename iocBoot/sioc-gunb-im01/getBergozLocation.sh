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
    cat $SERIAL_DEVICE | egrep '^[B-Z]' &
    CAT_PID=$!

    # configure serial port
    stty -F "$SERIAL_DEVICE" raw pass8 -echo -crtscts -cstopb

    # get register values
    echo -en "S0?\n\0" > "$SERIAL_DEVICE"
    FOUND_DEVICE=$(cat $SERIAL_DEVICE)

    echo $FOUND_DEVICE
    echo $SERIALNUMBER
    echo $DEVICE
    case $FOUND_DEVICE in
        $SERIALNUMBER)
            echo $DEVICE
            #echo "epicsEnvSet('IM01_PATH','${DEVICE}')" > /data/im01_path
        ;;
    esac
    
    sleep 1
    # stop the 'cat' process by PID
    kill $CAT_PID
done
exit