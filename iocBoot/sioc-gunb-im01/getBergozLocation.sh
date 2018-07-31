#!/bin/bash
# Script that will find the the path for 
# the serial number of a connected bergoz
# device
##########################################

DEVICE_PATH=/dev/ttyACM*
FOUND_DEVICES=`ls -l $DEVICE_PATH | grep -c ^d`
CONVERT_PATH=$(echo $PWD | tr "/" "-")
IFS='-' read -r -a IOC_ARRAY <<< $CONVERT_PATH
DEVICE="${IOC_ARRAY[@]: -1:1}"
echo ${DEVICE^^}

SERIAL_NUMBER=${DEVICE}

if [ 0 -eq $FOUND_DEVICES ]; then
	echo '************ERROR*************'
	echo 'Could not find any tty devices'
	exit 1
fi

for SERIAL_DEVICE in $DEVICE_PATH ; do
	if [ ! -w || -r "$SERIAL_DEVICE" ]; then
		echo "Permission issues on $SERIAL_DEVICE"
		exit 2
	fi

	# start 'cat' process and save the PID
	cat $SERIAL_DEVICE | egrep '^[B-Z]' &
	catpid=$!

	# configure serial port
	stty -F "$SERIAL_DEVICE" raw pass8 -echo -crtscts -cstopb

	# get register values
	echo -en "S0?\n\0" > "$DEVICE_NUMBER"
	if [ $DEVICE_NUMBER -eq $SERIAL_NUMBER ]; then
		export $DEVICE=$SERIAL_DEVICE
	fi
	sleep 1

	# stop the 'cat' process by PID
	kill $catpid
done
exit