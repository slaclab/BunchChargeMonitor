# This file is AUTOMATICALLY GENERATED
# DO NOT EDIT
if [ -z "$ARCH" ] ; then
  MACH=`uname -m`
  VERS=`uname -v`
  REL=`uname -r`
  if echo $VERS | grep -q PREEMPT ; then
    if  echo $REL | grep -q '4[.]8[.]11' ; then
      ARCH=buildroot-2016.11.1-
    elif echo $REL | grep -q '3[.]18[.]11' ; then
      ARCH=buildroot-2015.02-
    else
      echo "Unable to determine buildroot version"
    fi
  elif echo $REL | grep -q el6 ; then
    ARCH=rhel6-
  else
    echo "Unable to determine OS type"
  fi
  ARCH=$ARCH$MACH
fi
if [ -z $ARCH ] ; then
  echo "ARCH not set; not modifying environment"
else
  echo "Setting environment for $ARCH"
  # TOPDIR is replaced by 'make'!
  . /usr/local/lcls/package/cpsw/framework/R3.6.4/${ARCH}/bin/env-*.sh
fi
