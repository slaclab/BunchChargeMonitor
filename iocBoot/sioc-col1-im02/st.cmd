#!../../bin/linuxRT-x86_64/bcm

#- You may have to change bcm to something else
#- everywhere it appears in this file

< envPaths

# Production area
epicsEnvSet("AREA","COL1")

# Start up enviroment variable 
epicsEnvSet("STARTUP","/afs/slac/g/lcls/epics/iocCommon/${IOC_NAME}")

# ***********************************************************************
# **** Environment variables for IOC Admin ******************************
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):IM02")

cd $(TOP)
< iocBoot/common/temperatureMonitor.cmd
