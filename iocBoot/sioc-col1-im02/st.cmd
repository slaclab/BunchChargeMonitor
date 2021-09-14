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

# Temperature xfer: ESLO, EOFF
epicsEnvSet("ESLO","$(ESLO=0.01)")
epicsEnvSet("EOFF","$(EOFF=273.15)")

cd ${TOP}

# ===========================================
#               DBD LOADING
# ===========================================
## Register all support components
dbLoadDatabase("dbd/bcm.dbd",0,0)
bcm_registerRecordDeviceDriver(pdbbase)

# ***********************************************************************
# **** Driver setup for Temperature Chassis on Ethercat *****************
# Init EtherCAT: To support Real Time fieldbus
# EtherCAT AsynDriver must be initialized in the IOC startup script before iocInit
# ecAsynInit("<unix_socket>", <max_message>)
# unix_socket = path to the unix socket created by the scanner
# max_message = maximum size of messages between scanner and ioc
ecAsynInit("/tmp/sock1", 1000000)


# ***********************************************************************
# **** Load db for Temperature Chassis on Ethercat **********************
# Load the database templates for the EtherCAT components
# dbLoadRecords("db/<template_name_for slave_module>, <pass_in_macros>")
dbLoadRecords("db/EK1101.template", "DEVICE=${IOC_NAME}:BCM_EK1101,PORT=COUPLER0,SCAN=1 second")

dbLoadRecords("db/multTempMonitoring.db", "P=BLEN:BC1B:850, R=1, IOC=${IOC_NAME},MODULE=1,NODE=1, TYPE=TempPrimPyro, ESLO=${ESLO}, EOFF=${EOFF}")
dbLoadRecords("db/multTempMonitoring.db", "P=TORO:COL1:125, R=1, IOC=${IOC_NAME},MODULE=2,NODE=1, TYPE=TempElc, ESLO=${ESLO}, EOFF=${EOFF}")
dbLoadRecords("db/multTempMonitoring.db", "P=TORO:COL1:125, R=2, IOC=${IOC_NAME},MODULE=3,NODE=1, TYPE=TempRef, ESLO=${ESLO}, EOFF=${EOFF}")
dbLoadRecords("db/multTempMonitoring.db", "P=TORO:COL1:125, R=3, IOC=${IOC_NAME},MODULE=3,NODE=2, TYPE=TempAmpRef, ESLO=${ESLO}, EOFF=${EOFF}")
#dbLoadRecords("db/multTempMonitoring.db", "P=, R=1, IOC=${IOC_NAME},MODULE=4,NODE=1, TYPE=TempGapLeft, ESLO=${ESLO}, EOFF=${EOFF}")
#dbLoadRecords("db/multTempMonitoring.db", "P=, R=2, IOC=${IOC_NAME},MODULE=4,NODE=2, TYPE=TempGapTop, ESLO=${ESLO}, EOFF=${EOFF}")
#dbLoadRecords("db/multTempMonitoring.db", "P=, R=3, IOC=${IOC_NAME},MODULE=5,NODE=1, TYPE=TempGapRight, ESLO=${ESLO}, EOFF=${EOFF}")
#dbLoadRecords("db/multTempMonitoring.db", "P=, R=4, IOC=${IOC_NAME},MODULE=5,NODE=2, TYPE=TempGapBtm, ESLO=${ESLO}, EOFF=${EOFF}")

# ************************************************************************
# **** Load iocAdmin databases to support IOC Health and monitoring ******
dbLoadRecords("db/iocAdminSoft.db","IOC=${IOC_NAME}")
dbLoadRecords("db/iocAdminScanMon.db","IOC=${IOC_NAME}")

# The following database is a result of a python parser
# which looks at RELEASE_SITE and RELEASE to discover
# versions of software your IOC is referencing
# The python parser is part of iocAdmin
dbLoadRecords("db/iocRelease.db","IOC=${IOC_NAME}")


# ***********************************************************************
# **** Load database for autosave status ********************************
dbLoadRecords("db/save_restoreStatus.db", "P=${IOC_NAME}:")

# ===========================================
#           SETUP AUTOSAVE/RESTORE
# ===========================================

# If all PVs don't connect continue anyway
save_restoreSet_IncompleteSetsOk(1)

# created save/restore backup files with date string
# useful for recovery.
save_restoreSet_DatedBackupFiles(1)

# Where to find the list of PVs to save
# Where "/data" is an NFS mount point setup when linuxRT target
# boots up.
set_requestfile_path("/data/${IOC}/autosave-req")

# Where to write the save files that will be used to restore
set_savefile_path("/data/${IOC}/autosave")

# Prefix that is use to update save/restore status database
# records
save_restoreSet_UseStatusPVs(1)
save_restoreSet_status_prefix("${IOC_NAME}:")

## Restore datasets
set_pass0_restoreFile("info_settings.sav")
set_pass1_restoreFile("info_settings.sav")


# ===========================================
#          CHANNEL ACESS SECURITY
# ===========================================
# This is required if you use caPutLog.
# Set access security filea
# Load common LCLS Access Configuration File
< ${ACF_INIT}


# ===========================================
#               IOC INIT
# ===========================================
iocInit()

# Turn on caPutLogging:
# Log values only on change to the iocLogServer:
caPutLogInit("${EPICS_CA_PUT_LOG_ADDR}")
caPutLogShow(2)


# Start autosave routines to save our data
# optional, needed if the IOC takes a very long time to boot.
#epicsThreadSleep( 1.0)

cd("/data/${IOC}/autosave-req")
iocshCmd("makeAutosaveFiles")

# Start the save_restore task
# save changes on change, but no faster
# than every 5 seconds.
# Note: the last arg cannot be set to 0
create_monitor_set("info_positions.req", 5 )
create_monitor_set("info_settings.req" , 30 )

cd ${TOP}
