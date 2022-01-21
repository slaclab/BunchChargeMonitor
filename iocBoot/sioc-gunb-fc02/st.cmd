#!../../bin/rhel6-x86_64/bcm

#########################################
# This IOC is related to the Faraday Cup
# for the Bunch Charge Monitor.
#########################################

## You may have to change bcm to something else
## everywhere it appears in this file

< envPaths


# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

epicsEnvSet("IOC_UNIT", "FC02")

# Automatically generated record prefix
#epicsEnvSet("PREFIX","GUNB:FC02")

epicsEnvSet("AREA","GUNB")
epicsEnvSet("UNIT","753")
epicsEnvSet("IOC_PREFIX","FARC:$(AREA):$(UNIT)")


# ***********************************************************************
# **** Environment variables for Faraday Cup on Keithley ****************

epicsEnvSet("K6482_PORT","L1")
epicsEnvSet("K6482_P","$(IOC_PREFIX):")
epicsEnvSet("K6482_R","")
epicsEnvSet("K6482_ADDRESS","$(K6482_ADDRESS=ts-li00-nw02:2011)")
epicsEnvSet("STREAM_PROTOCOL_PATH","${TOP}/db")

# **********************************************************************
# **** Environment variables for IOC Admin *****************************

epicsEnvSet(IOC_NAME,"SIOC:GUNB:FC02")

# Start up enviroment variable
epicsEnvSet("STARTUP","/usr/local/lcls/epics/iocCommon/${IOC_NAME}")


cd ${TOP}

# ===========================================
#               DBD LOADING
# ===========================================
## Register all support components
dbLoadDatabase("dbd/bcm.dbd",0,0)
bcm_registerRecordDeviceDriver(pdbbase)

# *********************************************************************
# **** Driver setup for Keithley **************************************
# drvAsynIPPortConfigure port ipInfo priority noAutoconnect noProcessEos
drvAsynIPPortConfigure("$(K6482_PORT)","$(K6482_ADDRESS)",0,0,0)

# ********************************************************************
# **** Asyn Masks for Keithley ***************************************
#asynSetTraceIOMask("$(K6482_PORT)",-1,0x2)
#asynSetTraceMask("$(K6482_PORT)",-1,0x9)


# ===========================================
#               DB LOADING
# ===========================================

# *********************************************************************
# **** Load YCPSWAsyn db **********************************************
#Save/Load configuration related records
dbLoadRecords("db/saveLoadConfig.db", "P=${IOC_PREFIX}, PORT=${CPSW_PORT}")

dbLoadRecords("db/iocMeta.db", "AREA=$(AREA), IOC_UNIT=$(IOC_UNIT)") 

# Parse IP address
dbLoadRecords("db/ipAddr.db", "P=${IOC_PREFIX}, SRC=SrvRemoteIp")
dbLoadRecords("db/swap.db",   "P=${IOC_PREFIX}, SRC=SrvRemotePort, DEST=SrvRemotePortSwap")

# Allow time for Keithley driver to connect
epicsThreadSleep(1.0)

# **********************************************************************
# **** Load Keithley db ************************************************
dbLoadRecords ("db/devKeithley6482.db" "P=$(K6482_P),R=$(K6482_R),PORT=$(K6482_PORT),A=-1,NELM=1000,VDRVH=30,VDRVL=-30")
dbLoadRecords ("db/asynRecord.db" "P=$(K6482_P),R=$(K6482_R),PORT=$(K6482_PORT),ADDR=-1,OMAX=0,IMAX=0")



# *************************************************************************
# **** Load message status   **********************************************
dbLoadRecords("db/msgStatus.db","carrier_prefix=${IOC_PREFIX},DESC=Communications Diagnostics,BPM_LOCA=314,LOCA=$(UNIT),AREA=GUNB")


# *************************************************************************
# **** Load iocAdmin databases to support IOC Health and monitoring *******
dbLoadRecords("db/iocAdminSoft.db","IOC=${IOC_NAME}")
dbLoadRecords("db/iocAdminScanMon.db","IOC=${IOC_NAME}")

# The following database is a result of a python parser
# which looks at RELEASE_SITE and RELEASE to discover
# versions of software your IOC is referencing
# The python parser is part of iocAdmin
dbLoadRecords("db/iocRelease.db","IOC=${IOC_NAME}")


# ************************************************************************
# **** Load database for autosave status *********************************
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


#////////////////////////////////////////#
#Run script to generate archiver files   #
#////////////////////////////////////////#
#cd(${TOP}/bcmApp/scripts/)
#system("./makeArchive.sh ${IOC} &")
#cd(${TOP})
