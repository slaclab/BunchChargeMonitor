#  -*- Makefile -*-
TOP=../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

# EDM Screens to install
# You can override the default installation path.
#INSTALL_LOCATION=

# EDM Screens to install
EDL += InputBiasCalib.edl bcmBergozDebug.edl  bcmFcCoef.edl   bcmTrigger.edl      keithleyCalib.edl
EDL += bcmBergozMode.edl  bcmFcDebug.edl
EDL += amcStatus.edl      bcmBergozTop.edl    bcmFcMode.edl   daqmuxV2Status.edl  version.edl
EDL += bcmCoef.edl        bcmFcTop.edl        defaults.edl    webStatus.edl
EDL += bcmBergozCoef.edl  bcmDebug.edl        bcmMode.edl     bsaStatus.edl
EDL += startEdm_toroid.sh startEdm_FC.sh

# Install images to be used by EDM (Gif and Png are supported)
# PNG is better and preferred.
#PNGS +=
#GIFS +=

# EDM Screens to install
# If you want to install all screens and are
# lazy use the wildcard method. :)
#EDLS+=$(wildcard *.edl)
#PNGS+=$(wildcard *.png)
#GIFS+=$(wildcard *.gif)


include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
