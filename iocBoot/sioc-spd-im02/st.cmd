#!../../bin/linuxRT-x86_64/bcm

< envPaths 

# Production area
epicsEnvSet("AREA","SPD")

# Start up enviroment variable 
epicsEnvSet("STARTUP","/usr/local/lcls/epics/iocCommon/${IOC_NAME}")

# ***********************************************************************
# **** Environment variables for IOC Admin ******************************
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):IM02")

cd $(TOP)
< iocBoot/common/temperatureMonitor.cmd

