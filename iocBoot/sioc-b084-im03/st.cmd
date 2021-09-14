#!../../bin/linuxRT-x86_64/bcm

#- You may have to change sioc-b084-im03 to something else
#- everywhere it appears in this file

< envPaths

epicsEnvSet("AREA","B084")

# Start up enviroment variable 
epicsEnvSet("STARTUP","/afs/slac/g/lcls/epics/iocCommon/${IOC_NAME}")

# ***********************************************************************
# **** Environment variables for IOC Admin ******************************
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):IM03")

cd $(TOP)
< iocBoot/common/temperatureMonitor.cmd

