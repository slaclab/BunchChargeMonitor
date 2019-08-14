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

# configure serial port
stty -F "$SERIALDEVICE" raw pass8 -echo -crtscts -cstopb

echo "D0: set digital delay line to 100 (0x64)"
echo -en "D0:0064\n\0" > "$SERIALDEVICE"

echo "I0: set on-board switch position to 6"
echo -en "I0:0006\n\0" > "$SERIALDEVICE"

echo "K0: disable CAL-FO"
echo -en "K0:0000\n\0" > "$SERIALDEVICE"

echo "M0: disable reverse function algorithm"
echo -en "M0:0000\n\0" > "$SERIALDEVICE"

echo "T0: set average number of points to 1"
echo -en "T0:0001\n\0" > "$SERIALDEVICE"

echo "W0: set W0"
echo -en "W0:696E\n\0" > "$SERIALDEVICE"

echo "W1: set W1"
echo -en "W1:3F5D\n\0" > "$SERIALDEVICE"

echo "V0: set V0"
echo -en "V0:B72C\n\0" > "$SERIALDEVICE"

echo "v1: set V1"
echo -en "V1:3C34\n\0" > "$SERIALDEVICE"
