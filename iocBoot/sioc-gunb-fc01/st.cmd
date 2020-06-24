#!../../bin/linuxRT-x86_64/bcm

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

# ***********************************************************************
# **** Environment variables for BCM on YCPSWAsyn ***********************

# Support Large Arrays/Waveforms; Number in Bytes
# Please calculate the size of the largest waveform
# that you support in your IOC.  Do not just copy numbers
# from other apps.  This will only lead to an exhaustion
# of resources and problems with your IOC.
# The default maximum size for a channel access array is
# 16K bytes.
# Uncomment and set appropriate size for your application:
# Port name
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "21000000")

epicsEnvSet("CPSW_PORT","Atca6")

# Yaml File
epicsEnvSet("YAML_FILE", "yaml/AmcCarrierBcm_project.yaml/000TopLevel.yaml")

# FPGA IP address
epicsEnvSet("FPGA_IP", "10.0.1.106")

# Use Automatic generation of records from the YAML definition
# 0 = No, 1 = Yes
epicsEnvSet("AUTO_GEN", 0)

# Automatically generated record prefix
#epicsEnvSet("PREFIX","GUNB:FC01")

epicsEnvSet("AREA","GUNB")
epicsEnvSet("UNIT","999")

# BCM-FC in crate 1, slot 4, AMC 0
epicsEnvSet("AMC0_PREFIX","FARC:$(AREA):$(UNIT)")

# AMCC in crate 1, slot 4
epicsEnvSet("AMC_CARRIER_PREFIX","AMCC:$(AREA):$(UNIT)")

# Dictionary file for manual (empty string if none)
epicsEnvSet("DICT_FILE", "yaml/bcmLCLS2.dict")

# ***********************************************************************
# **** Environment variables for MPS ************************************
epicsEnvSet("MPS_PORT",   "mpsPort")
epicsEnvSet("MPS_APP_ID", "0x05")
epicsEnvSet("MPS_PREFIX", "MPLN:GUNB:MP01:4")

# ***********************************************************************
# **** Environment variables for Faraday Cup on Keithley ****************

epicsEnvSet("K6482_PORT","L1")
epicsEnvSet("K6482_P","$(AMC0_PREFIX):")
epicsEnvSet("K6482_R","")
epicsEnvSet("K6482_ADDRESS","$(K6482_ADDRESS=ts-li00-nw02:2001)")
epicsEnvSet("STREAM_PROTOCOL_PATH","${TOP}/db")


# ***********************************************************************
# **** Environment variables for Temperature Chassis on Ethercat ********

# System Location:
epicsEnvSet(FAC,"SYS2")
epicsEnvSet("LOCA","GUNB")
epicsEnvSet("TEMP_IOC_NAME","SIOC:${LOCA}:FC01")


# **********************************************************************
# **** Environment variables for IOC Admin *****************************

epicsEnvSet(IOC_NAME,"SIOC:GUNB:FC01")

# Start up enviroment variable
epicsEnvSet("STARTUP","/usr/local/lcls/epics/iocCommon/${IOC_NAME}")



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
# **********************************************************************
# **** Driver setup for YCPSWAsyn **************************************

## Configure the Yaml Loader Driver
# cpswLoadYamlFile(
#    Yaml Doc,                  # Path to the YAML hierarchy description file
#    Root Device,               # Root Device Name (optional; default = 'root')
#    YAML Path,                 #directory where YAML includes can be found (optional)
#    IP Address,                # OPTIONAL: Target FPGA IP Address. If not given it is taken from the YAML file
# ==========================================================================================================
cpswLoadYamlFile("${YAML_FILE}","NetIODev","","${FPGA_IP}")
cpswLoadConfigFile("yaml/AmcCarrierBcm_project.yaml/config/defaultsFC.yaml", "mmio")
# *********************************************************************
# **** BSA Driver setup ***********************************************
# add BSA PVs
addBsa("CHRG",       "uint32")
addBsa("JUNK",       "uint32")
addBsa("CHRGUNC",    "uint32")
addBsa("CHRGFLOAT",  "float32")
addBsa("FCSTATUS",   "uint32")
# BSA driver for yaml
bsaAsynDriverConfigure("bsaPort", "mmio/AmcCarrierCore/AmcCarrierBsa","strm/AmcCarrierDRAM/dram")

# *********************************************************************
# **** MPS Driver setup ***********************************************
# LCLS2MPSCPASYNConfig(
#    Port Name,                 # the name given to this port driver
#    App ID,                    # Application ID
#    Record name Prefix,        # Record name prefix
#    AppType bay0,              # Bay 0 Application type (BPM, BLEN)
#    AppType bay1,              # Bay 1 Application type (BPM, BLEN)
#    MPS Root Path              # OPTIONAL: Root path to the MPS register area
L2MPSASYNConfig("${MPS_PORT}","${MPS_APP_ID}", "${MPS_PREFIX}", "${AMC0_PREFIX}", "", "")

## Configure asyn port driver
# YCPSWASYNConfig(
#    Port Name,                 # the name given to this port driver
#    Root Path                  # OPTIONAL: Root path to start the generation. If empty, the Yaml root will be used
#    Record name Prefix,        # Record name prefix
#    Use DB Autogeneration,     # Set to 1 for autogeneration of records from the YAML definition. Set to 0 to disable it
#    Load dictionary,           # Dictionary file path with registers to load. An empty string will disable this function
YCPSWASYNConfig("${CPSW_PORT}", "", "", "0", "${DICT_FILE}")

# *********************************************************************
# **** Driver setup for Keithley **************************************
# drvAsynIPPortConfigure port ipInfo priority noAutoconnect noProcessEos
drvAsynIPPortConfigure("$(K6482_PORT)","$(K6482_ADDRESS)",0,0,0)

# *********************************************************************
# **** Driver setup for Temperature Chassis on Ethercat ***************
# Init EtherCAT: To support Real Time fieldbus
# EtherCAT AsynDriver must be initialized in the IOC startup script before iocInit
# ecAsynInit("<unix_socket>", <max_message>)
# unix_socket = path to the unix socket created by the scanner
# max_message = maximum size of messages between scanner and ioc
ecAsynInit("/tmp/sock1", 1000000)

# *********************************************************************
# **** TprTrigger driver setup ****************************************
tprTriggerAsynDriverConfigure("trig", "mmio/AmcCarrierCore")

# *********************************************************************
# **** Setup TprPattern driver ****************************************
#This driver needs to be loaded only for LCLS1 devices
#tprPatternAsynDriverConfigure("pattern", "mmio/AmcCarrierCore", "Lcls1TimingStream")
#
# ===========================================
#               ASYN MASKS
# ===========================================

# **********************************
# **** Asyn Masks for YCPSWAsyn ****
#asynSetTraceMask(${PORT},, -1, 9)


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
dbLoadRecords("db/saveLoadConfig.db", "P=${AMC_CARRIER_PREFIX}, PORT=${CPSW_PORT}")

# Manually create records
dbLoadRecords("db/bcm.db", "P=${AMC0_PREFIX}, PORT=${CPSW_PORT}, AMC=0")
# ...only one BCM-FC per board is anticipated
dbLoadRecords("db/carrier.db", "P=${AMC_CARRIER_PREFIX}, PORT=${CPSW_PORT}")

# Parse IP address
dbLoadRecords("db/ipAddr.db", "P=${AMC_CARRIER_PREFIX}, SRC=SrvRemoteIp")
dbLoadRecords("db/swap.db",   "P=${AMC_CARRIER_PREFIX}, SRC=SrvRemotePort, DEST=SrvRemotePortSwap")

# Automatic initialization
dbLoadRecords("db/monitorFPGAReboot.db", "P=${AMC_CARRIER_PREFIX}, KEY=-66686157")

# Allow time for Keithley driver to connect
epicsThreadSleep(1.0)

# **********************************************************************
# **** Load Keithley db ************************************************
dbLoadRecords ("db/devKeithley6482.db" "P=$(K6482_P),R=$(K6482_R),PORT=$(K6482_PORT),A=-1,NELM=1000,VDRVH=30,VDRVL=-30")
dbLoadRecords ("db/asynRecord.db" "P=$(K6482_P),R=$(K6482_R),PORT=$(K6482_PORT),ADDR=-1,OMAX=0,IMAX=0")

# **********************************************************************
# **** Load Waveforms db ***********************************************
dbLoadRecords("db/waveform.db", "P=${AMC0_PREFIX}")
dbLoadRecords("db/streamControl.db", "P=${AMC0_PREFIX}")


# **********************************************************************
# **** Load BSA driver DB **********************************************

dbLoadRecords("db/bsa.db", "DEV=${AMC0_PREFIX},PORT=bsaPort,BSAKEY=CHRG,SECN=CHRG")
dbLoadRecords("db/bsa.db", "DEV=${AMC0_PREFIX},PORT=bsaPort,BSAKEY=CHRGUNC,SECN=CHRGUNC")
dbLoadRecords("db/bsa.db", "DEV=${AMC0_PREFIX},PORT=bsaPort,BSAKEY=CHRGFLOAT,SECN=CHRGFLOAT")
dbLoadRecords("db/bsa.db", "DEV=${AMC0_PREFIX},PORT=bsaPort,BSAKEY=FCSTATUS,SECN=FCSTATUS")

# ************************************************************************
# **** Load TPR Triggers db **********************************************
dbLoadRecords("db/tprTrig.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=00,DEV_PREFIX=${AMC0_PREFIX}:TRG00:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=01,DEV_PREFIX=${AMC0_PREFIX}:TRG01:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=02,DEV_PREFIX=${AMC0_PREFIX}:TRG02:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=03,DEV_PREFIX=${AMC0_PREFIX}:TRG03:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=04,DEV_PREFIX=${AMC0_PREFIX}:TRG04:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=05,DEV_PREFIX=${AMC0_PREFIX}:TRG05:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=06,DEV_PREFIX=${AMC0_PREFIX}:TRG06:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=07,DEV_PREFIX=${AMC0_PREFIX}:TRG07:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=08,DEV_PREFIX=${AMC0_PREFIX}:TRG08:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=09,DEV_PREFIX=${AMC0_PREFIX}:TRG09:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=10,DEV_PREFIX=${AMC0_PREFIX}:TRG10:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=11,DEV_PREFIX=${AMC0_PREFIX}:TRG11:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=12,DEV_PREFIX=${AMC0_PREFIX}:TRG12:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=13,DEV_PREFIX=${AMC0_PREFIX}:TRG13:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=14,DEV_PREFIX=${AMC0_PREFIX}:TRG14:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=FC01,INST=0,SYS=SYS2,NN=15,DEV_PREFIX=${AMC0_PREFIX}:TRG15:,PORT=trig")


# *************************************************************************
# **** Load message status   **********************************************
dbLoadRecords("db/msgStatus.db","carrier_prefix=${AMC_CARRIER_PREFIX},DESC=Communications Diagnostics,BPM_LOCA=314,LOCA=$(UNIT),AREA=GUNB")


# *************************************************************************
# **** Load MPS scale factor **********************************************
dbLoadRecords("db/mps_scale_factor.db", "P=${AMC0_PREFIX},PROPERTY=CHARGE,EGU=pC,PREC=8,SLOPE=0.0078125,OFFSET=0")
dbLoadRecords("db/mps_scale_factor.db", "P=${AMC0_PREFIX},PROPERTY=DIFF,EGU=pC,PREC=8,SLOPE=0.0078125,OFFSET=0")

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

# ************************************************************
# **** System command for Temperature Chassis on Ethercat ****
# Setup Real-time priorities after iocInit for driver threads
system("/bin/su root -c `pwd`/rtPrioritySetup.cmd")

# Start loading configuration file
dbpf AMCC:${AREA}:${UNIT}:saveConfigFile "/tmp/configDump.yaml"
dbpf AMCC:${AREA}:${UNIT}:saveConfigRoot "mmio"
dbpf AMCC:${AREA}:${UNIT}:saveConfig 1
dbpf AMCC:${AREA}:${UNIT}:loadConfigFile "yaml/AmcCarrierBcm_project.yaml/config/defaultsFC.yaml"
dbpf AMCC:${AREA}:${UNIT}:loadConfigRoot "mmio"
# We should never load the configuration file after autosave already changed
# the parameters. Uncomment the line below only if you are sure about what you
# are doing.
#dbpf AMCC:${AREA}:${UNIT}:loadConfig 1
