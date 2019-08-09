#!/bin/sh

SERIALDEVICE=/dev/ttyACM0

if [ ! -e "$SERIALDEVICE" ]; then
  echo "$0: device $SERIALDEVICE not found"
    exit 1
    fi

    if [ ! -w "$SERIALDEVICE" ]; then
      echo "$0: device $SERIALDEVICE not writable"
        exit 1
        fi

        # start 'cat' process and save the PID
        cat $SERIALDEVICE | egrep '^[B-Z]' &
        catpid=$!

        # configure serial port
        stty -F "$SERIALDEVICE" raw pass8 -echo -crtscts -cstopb

        # get register values
        echo -en "D0?\n\0" > "$SERIALDEVICE"
        echo -en "I0?\n\0" > "$SERIALDEVICE"
        echo -en "K0?\n\0" > "$SERIALDEVICE"
        echo -en "M0?\n\0" > "$SERIALDEVICE"
        echo -en "T0?\n\0" > "$SERIALDEVICE"
        echo -en "V1?\n\0" > "$SERIALDEVICE"
        echo -en "W1?\n\0" > "$SERIALDEVICE"
        echo -en "S0?\n\0" > "$SERIALDEVICE"

        sleep 1

        # stop the 'cat' process by PID
        kill $catpid

        exit

