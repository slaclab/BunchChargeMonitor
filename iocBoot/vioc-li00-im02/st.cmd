#!../../bin/linuxRT-x86_64/bcm

#########################################
# This IOC is related to the Toroid
# for the Bunch Charge Monitor.
#########################################


## You may have to change bcm to something else
## everywhere it appears in this file

< envPaths


# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# ****************************************************
# **** Environment variables for BCM on YCPSWAsyn ****

# Support Large Arrays/Waveforms; Number in Bytes
# Please calculate the size of the largest waveform
# that you support in your IOC.  Do not just copy numbers
# from other apps.  This will only lead to an exhaustion
# of resources and problems with your IOC.
# The default maximum size for a channel access array is
# 16K bytes.
# Uncomment and set appropriate size for your application:
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "21000000")

epicsEnvSet("CPSW_PORT","Atca7")

# Yaml File
epicsEnvSet("YAML_FILE", "yaml/AmcCarrierBcm_project.yaml/000TopLevel.yaml")

# FPGA IP address
epicsEnvSet("FPGA_IP", "10.0.1.105")

# Use Automatic generation of records from the YAML definition
# 0 = No, 1 = Yes
epicsEnvSet("AUTO_GEN", 0)

# Automatically generated record prefix
#epicsEnvSet("PREFIX","LI00:IM02")

epicsEnvSet("AREA","LI00")

# BCM-TORO attached to AMC0
epicsEnvSet("AMC0_PREFIX","TORO:$(AREA):215")

# BCM-TORO attached to AMC1
epicsEnvSet("AMC1_PREFIX","TORO:$(AREA):431")

# AMCC in crate 1, slot 5
epicsEnvSet("AMC_CARRIER_PREFIX","AMCC:$(AREA):15")

# Dictionary file for manual (empty string if none)
epicsEnvSet("DICT_FILE", "yaml/bcm_00000018.dict")


# *****************************************************
# **** Environment variables for Toroid on  Bergoz ****

epicsEnvSet("P_BERGOZ","$(P=VIOC:)")
epicsEnvSet("R","$(R=$(AREA):IM02:)")
epicsEnvSet("BERGOZ_PORT","$(PORT=L0)")
epicsEnvSet("BERGOZ_TTY","$(BERGOZ_TTY=/dev/ttyACM0)")
epicsEnvSet("SERIALNUM_EXPECT","$(SERIALNUM_EXPECT=40)")
epicsEnvSet("STREAM_PROTOCOL_PATH","${TOP}/db")

# Temperature xfer: ESLO, EOFF
epicsEnvSet("ESLO","$(ESLO=0.01)")
epicsEnvSet("EOFF","$(EOFF=273.15)")


# *********************************************
# **** Environment variables for IOC Admin ****

epicsEnvSet(IOC_NAME,"VIOC:$(AREA):IM02")


cd ${TOP}

# ===========================================
#               DBD LOADING
# ===========================================
## Register all support components
dbLoadDatabase("dbd/bcm.dbd",0,0)
bcm_registerRecordDeviceDriver(pdbbase)


# ===========================================
#              DRIVER SETUP
# ===========================================

# ************************************
# **** Driver setup for YCPSWAsyn ****

## Configure asyn port driver
# YCPSWASYNConfig(
#    Port Name,                 # the name given to this port driver
#    Yaml Doc,                  # Path to the YAML file
#    Root Path                  # OPTIONAL: Root path to start the generation. If empty, the Yaml root will be used
#    IP Address,                # OPTIONAL: Target FPGA IP Address. If not given it is taken from the YAML file
#    Record name Prefix,        # Record name prefix
#    Record name Length Max,    # Record name maximum length (must be greater than lenght of prefix + 4)
#    Use DB Autogeneration,     # Set to 1 for autogeneration of records from the YAML definition. Set to 0 to disable it
#    Load dictionary,           # Dictionary file path with registers to load. An empty string will disable this function
# In Sector 0 L2KA00-05, the BCMs are in slots 6 and 7. Here, for testing purposes we are using slots 4 and 5.
YCPSWASYNConfig("${CPSW_PORT}", "${YAML_FILE}", "", "${FPGA_IP}", "", 40, "${AUTO_GEN}", "${DICT_FILE}")


# *********************************
# **** Driver setup for Bergoz ****

# Set up ASYN ports
# drvAsynIPPortConfigure port ipInfo priority noAutoconnect noProcessEos
drvAsynSerialPortConfigure("$(BERGOZ_PORT)","$(BERGOZ_TTY)",0,0,0)


# ===========================================
#               ASYN MASKS
# ===========================================

# **********************************
# **** Asyn Masks for YCPSWAsyn ****

#asynSetTraceMask(${PORT},, -1, 9)


# *******************************
# **** Asyn Masks for Bergoz ****

#asynSetTraceIOMask("$(BERGOZ_PORT)",-1,0x2)
#asynSetTraceMask("$(BERGOZ_PORT)",-1,0x9)


# ===========================================
#               DB LOADING
# ===========================================

# ***************************
# **** Load YCPSWAsyn db ****

#Save/Load configuration related records
dbLoadRecords("db/saveLoadConfig.db", "P=${AMC_CARRIER_PREFIX}, PORT=${CPSW_PORT}, SAVE_FILE=/tmp/configDump.yaml, LOAD_FILE=yaml/defaults_bergoz.yaml")

# Manually create records
dbLoadRecords("db/bcm.db", "P=${AMC0_PREFIX}, PORT=${CPSW_PORT}, AMC=0")
dbLoadRecords("db/bcm.db", "P=${AMC1_PREFIX}, PORT=${CPSW_PORT}, AMC=1")
dbLoadRecords("db/carrier.db", "P=${AMC_CARRIER_PREFIX}, PORT=${CPSW_PORT}")

# Automatic initialization
dbLoadRecords("db/monitorFPGAReboot.db", "P=${AMC_CARRIER_PREFIX}, KEY=-66686157")


# ************************
# **** Load Bergoz db ****

dbLoadRecords("db/devBergozBCM.db" "P=$(P_BERGOZ),R=$(R),PORT=$(BERGOZ_PORT),A=-1")
dbLoadRecords("db/asynRecord.db" "P=$(P_BERGOZ),R=asyn,PORT=$(BERGOZ_PORT),ADDR=-1,OMAX=0,IMAX=0")
dbLoadRecords("db/TempMonitoring_TORO.db", "P=$(P_BERGOZ)$(R),ESLO=$(ESLO),EOFF=$(EOFF)")



# **********************************************************************
# **** Load iocAdmin databases to support IOC Health and monitoring ****
dbLoadRecords("db/iocAdminSoft.db","IOC=${IOC_NAME}")
dbLoadRecords("db/iocAdminScanMon.db","IOC=${IOC_NAME}")

# The following database is a result of a python parser
# which looks at RELEASE_SITE and RELEASE to discover
# versions of software your IOC is referencing
# The python parser is part of iocAdmin
dbLoadRecords("db/iocRelease.db","IOC=${IOC_NAME}")


# *******************************************
# **** Load database for autosave status ****

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

# *********************
# **** Bergoz dbpf ****

# Save the TTY device name
dbpf $(P_BERGOZ)$(R)TTY_RD $(BERGOZ_TTY)

# Save the expected BERGOZ serial number
dbpf $(P_BERGOZ)$(R)SERIALNUM_EXPECT $(SERIALNUM_EXPECT)

