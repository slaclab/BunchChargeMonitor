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

epicsEnvSet("CPSW_PORT","ATCA7")

# Yaml File
epicsEnvSet("YAML_DIR", "$(IOC_DATA)/$(IOC)/yaml"
epicsEnvSet("TOP_YAML", "$(YAML_DIR)/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "$(YAML_DIR)/config/defaults.yaml")

# FPGA IP address
# From crate ID = 0x0001, slot = 7
# see the ATCA 101 training on Confluence for IP addr encoding in crateID + slot
epicsEnvSet("FPGA_IP", "10.0.1.107")

# Use Automatic generation of records from the YAML definition
# 0 = No, 1 = Yes
epicsEnvSet("AUTO_GEN", 0)

epicsEnvSet("AREA", "LI14")
epicsEnvSet("AMC1_POS","890")
epicsEnvSet("IOC_UNIT", "IM01")

# BCM-TORO in crate 1, slot 7, AMC 1 (IM14890)
epicsEnvSet("AMC1_PREFIX","TORO:$(AREA):$(AMC1_POS)")

# AMCC in crate 1, slot 7
epicsEnvSet("AMC_CARRIER_PREFIX","AMCC:$(AREA):$(IOC_UNIT)")

# Dictionary file for manual (empty string if none)
epicsEnvSet("DICT_FILE", "yaml/bcmMR.dict")

# Start up enviroment variable 
epicsEnvSet("STARTUP","/usr/local/lcls/epics/iocCommon/$(IOC_NAME)")

# IOC Admin
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):$(IOC_UNIT)")

cd $(TOP)

# ===========================================
#               DBD LOADING
# ===========================================
## Register all support components
dbLoadDatabase("dbd/bcm.dbd",0,0)
bcm_registerRecordDeviceDriver(pdbbase)

# ===========================================
#              DRIVER SETUP
# ===========================================
# ***********************************************************************
# **** Driver setup for YCPSWAsyn ***************************************

## Configure the Yaml Loader Driver
# cpswLoadYamlFile(
#    Yaml Doc,                  # Path to the YAML hierarchy description file
#    Root Device,               # Root Device Name (optional; default = 'root')
#    YAML Path,                 #directory where YAML includes can be found (optional)
#    IP Address,                # OPTIONAL: Target FPGA IP Address. If not given it is taken from the YAML file
# ==========================================================================================================
DownloadYamlFile("$(FPGA_IP)", "$(YAML_DIR)")
cpswLoadYamlFile("$(TOP_YAML)", "NetIODev", "", "$(FPGA_IP)")
cpswLoadConfigFile("$(YAML_CONFIG_FILE)", "mmio", "")

## Configure asyn port driver
# YCPSWASYNConfig(
#    Port Name,                 # the name given to this port driver
#    Root Path                  # OPTIONAL: Root path to start the generation. If empty, the Yaml root will be used
#    Record name Prefix,
#    Use DB Autogeneration,     # Set to 1 for autogeneration of records from the YAML definition. Set to 0 to disable it
#    Load dictionary,           # Dictionary file path with registers to load. An empty string will disable this function
YCPSWASYNConfig("$(CPSW_PORT)", "", "", "$(AUTO_GEN)", "$(DICT_FILE)")


tprTriggerAsynDriverConfigure("trig", "mmio/AmcCarrierCore")

#This driver needs to be loaded only for LCLS1 devices
tprPatternAsynDriverConfigure("pattern", "mmio/AmcCarrierCore", "tstream")


# ===========================================
#               DB LOADING
# ===========================================

#Save/Load configuration related records
dbLoadRecords("db/saveLoadConfig.db", "P=$(AMC_CARRIER_PREFIX), PORT=$(CPSW_PORT)")

# Manually create records
dbLoadRecords("db/bcmFACET2.db", "P=$(AMC1_PREFIX), PORT=$(CPSW_PORT), AMC=1, CHAN=0")

dbLoadRecords("db/carrierFACET2.db", "P=$(AMC_CARRIER_PREFIX), PORT=$(CPSW_PORT)")

dbLoadRecords("db/waveform.db", "P=$(AMC1_PREFIX)")

dbLoadRecords("db/streamControl.db", "P=$(AMC1_PREFIX)")

dbLoadRecords("db/iocMeta.db", "AREA=$(AREA), IOC_UNIT=$(IOC_UNIT)")

# Parse IP address
dbLoadRecords("db/ipAddr.db", "P=$(AMC_CARRIER_PREFIX), SRC=SrvRemoteIp")
dbLoadRecords("db/swap.db",   "P=$(AMC_CARRIER_PREFIX), SRC=SrvRemotePort, DEST=SrvRemotePortSwap")

dbLoadRecords("db/monitorFPGAReboot.db", "P=$(AMC_CARRIER_PREFIX), KEY=-66686157")

dbLoadRecords("db/tprTrig.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=00,DEV_PREFIX=$(AMC1_PREFIX):TRG00:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=01,DEV_PREFIX=$(AMC1_PREFIX):TRG01:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=02,DEV_PREFIX=$(AMC1_PREFIX):TRG02:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=03,DEV_PREFIX=$(AMC1_PREFIX):TRG03:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=04,DEV_PREFIX=$(AMC1_PREFIX):TRG04:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=05,DEV_PREFIX=$(AMC1_PREFIX):TRG05:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=06,DEV_PREFIX=$(AMC1_PREFIX):TRG06:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=07,DEV_PREFIX=$(AMC1_PREFIX):TRG07:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=08,DEV_PREFIX=$(AMC1_PREFIX):TRG08:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=09,DEV_PREFIX=$(AMC1_PREFIX):TRG09:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=10,DEV_PREFIX=$(AMC1_PREFIX):TRG10:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=11,DEV_PREFIX=$(AMC1_PREFIX):TRG11:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=12,DEV_PREFIX=$(AMC1_PREFIX):TRG12:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=13,DEV_PREFIX=$(AMC1_PREFIX):TRG13:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=14,DEV_PREFIX=$(AMC1_PREFIX):TRG14:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=$(AREA),IOC_UNIT=$(IOC_UNIT),INST=0,SYS=SYS0,NN=15,DEV_PREFIX=$(AMC1_PREFIX):TRG15:,PORT=trig")

# ************************************************************************
# **** Load iocAdmin databases to support IOC Health and monitoring ******
dbLoadRecords("db/iocAdminSoft.db","IOC=$(IOC_NAME)")
dbLoadRecords("db/iocAdminScanMon.db","IOC=$(IOC_NAME)")

# The following database is a result of a python parser
# which looks at RELEASE_SITE and RELEASE to discover
# versions of software your IOC is referencing
# The python parser is part of iocAdmin
dbLoadRecords("db/iocRelease.db","IOC=$(IOC_NAME)")


# ***********************************************************************
# **** Load database for autosave status ********************************
dbLoadRecords("db/save_restoreStatus.db", "P=$(IOC_NAME):")

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
set_requestfile_path("/data/$(IOC)/autosave-req")

# Where to write the save files that will be used to restore
set_savefile_path("/data/$(IOC)/autosave")

# Prefix that is use to update save/restore status database
# records
save_restoreSet_UseStatusPVs(1)
save_restoreSet_status_prefix("$(IOC_NAME):")

## Restore datasets
set_pass0_restoreFile("info_settings.sav")
set_pass1_restoreFile("info_settings.sav")


# ===========================================
#          CHANNEL ACESS SECURITY
# ===========================================
# This is required if you use caPutLog.
# Set access security filea
# Load common LCLS Access Configuration File
< $(ACF_INIT)


# ===========================================
#               IOC INIT
# ===========================================
iocInit()

# Turn on caPutLogging:
# Log values only on change to the iocLogServer:
caPutLogInit("$(EPICS_CA_PUT_LOG_ADDR)")
caPutLogShow(2)

cd("/data/$(IOC)/autosave-req")
iocshCmd("makeAutosaveFiles")

# Start the save_restore task
# save changes on change, but no faster
# than every 5 seconds.
# Note: the last arg cannot be set to 0
create_monitor_set("info_positions.req", 5 )
create_monitor_set("info_settings.req" , 30 )

cd $(TOP)
