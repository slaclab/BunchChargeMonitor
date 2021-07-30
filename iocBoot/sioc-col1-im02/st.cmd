#!../../bin/linuxRT-x86_64/bcm

#- You may have to change bcm to something else
#- everywhere it appears in this file

#< envPaths

## Register all support components
dbLoadDatabase("../../dbd/bcm.dbd",0,0)
bcm_registerRecordDeviceDriver(pdbbase) 

## Load record instances
dbLoadRecords("../../db/bcm.db","user=taine")

iocInit()

## Start any sequence programs
#seq sncbcm,"user=taine"
