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
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "21000000")

epicsEnvSet("CPSW_PORT","Atca7")

# Yaml File
epicsEnvSet("YAML_FILE", "yaml/AmcCarrierBcm_project.yaml/000TopLevel.yaml")

# FPGA IP address
epicsEnvSet("FPGA_IP", "10.0.1.107")

# Use Automatic generation of records from the YAML definition
# 0 = No, 1 = Yes
epicsEnvSet("AUTO_GEN", 0)

# Automatically generated record prefix
#epicsEnvSet("PREFIX","GUNB:IM01")

epicsEnvSet("AREA","GUNB")

# BCM-TORO in crate 1, slot 7, AMC 0
epicsEnvSet("AMC1_PREFIX","TORO:$(AREA):360")

# AMCC in crate 1, slot 7
epicsEnvSet("AMC_CARRIER_PREFIX","AMCC:$(AREA):360")

# Dictionary file for manual (empty string if none)
epicsEnvSet("DICT_FILE", "yaml/bcm_01_20170313140632.dict")

# Start up enviroment variable 
epicsEnvSet("STARTUP","/usr/local/lcls/epics/iocCommon/${IOC_NAME}")
# ***********************************************************************
# **** Environment variables for MPS ************************************
epicsEnvSet("MPS_PORT",   "mpsPort")
epicsEnvSet("MPS_APP_ID", "0x06")
epicsEnvSet("MPS_PREFIX", "MPLN:GUNB:MP01:5")

# ***********************************************************************
# **** Environment variables for Temperature Chassis on Ethercat ********

# System Location:
epicsEnvSet("TEMP_IOC_NAME","SIOC:$(AREA):IM01")

# ***********************************************************************
# **** Environment variables for IOC Admin ******************************
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):IM01")

# ***********************************************************************
# **** Environment variables for bergoz detection  **********************
# Serial number for bergoz
epicsEnvSet("IM01","2C")

cd(${TOP}/iocBoot/${IOC})
system("./getBergozLocation.sh ")
< /data/im01_path
cd(${TOP})


# **********************************************************************
# **** Environment variables for Toroid on  Bergoz *********************

epicsEnvSet("BERGOZ0_P","$(AMC1_PREFIX):")
epicsEnvSet("BERGOZ0_R","")
epicsEnvSet("BERGOZ0_PORT","L0")
epicsEnvSet("BERGOZ0_TTY","$(IM01_PATH)")
epicsEnvSet("BERGOZ0_SERIALNUM_EXPECT","44")
epicsEnvSet("STREAM_PROTOCOL_PATH","${TOP}/db")

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
cpswLoadYamlFile("${YAML_FILE}", "NetIODev", "", "${FPGA_IP}")

# **********************************************************************
# **** Setup BSA Driver*************************************************
# add BSA PVs
addBsa("CHRG",       "uint32")
addBsa("CHRGUNC",    "uint32")
addBsa("RAWSUM",     "uint32")
addBsa("CHRGFLOAT",  "float32")
addBsa("TOROSTATUS", "uint32")
# BSA driver for yaml
bsaAsynDriverConfigure("bsaPort", "mmio/AmcCarrierCore/AmcCarrierBsa","strm/AmcCarrierDRAM/dram")

# **********************************************************************
# **** Setup MPS Driver ************************************************
# LCLS2MPSCPASYNConfig(
#    Port Name,                 # the name given to this port driver
#    App ID,                    # Application ID
#    Record name Prefix,        # Record name prefix
#    AppType bay0,              # Bay 0 Application type (BPM, BLEN)
#    AppType bay1,              # Bay 1 Application type (BPM, BLEN)
#    MPS Root Path              # OPTIONAL: Root path to the MPS register area
L2MPSASYNConfig("${MPS_PORT}","${MPS_APP_ID}", "${MPS_PREFIX}", "${AMC1_PREFIX}", "", "")

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


# ***********************************************************************
# **** Driver setup for Bergoz ******************************************
# Set up ASYN ports
# drvAsynIPPortConfigure port ipInfo priority noAutoconnect noProcessEos
drvAsynSerialPortConfigure("$(BERGOZ0_PORT)","$(BERGOZ0_TTY)",0,0,0)


# ***********************************************************************
# **** Driver setup for Temperature Chassis on Ethercat *****************
# Init EtherCAT: To support Real Time fieldbus
# EtherCAT AsynDriver must be initialized in the IOC startup script before iocInit
# ecAsynInit("<unix_socket>", <max_message>)
# unix_socket = path to the unix socket created by the scanner
# max_message = maximum size of messages between scanner and ioc
ecAsynInit("/tmp/sock1", 1000000)

# ***********************************************************************
# **** Setup TprTrigger Driver ******************************************
tprTriggerAsynDriverConfigure("trig", "mmio/AmcCarrierCore")

# ***********************************************************************
# **** Setup TprPattern driver ******************************************
#This driver needs to be loaded only for LCLS1 devices
#tprPatternAsynDriverConfigure("pattern", "mmio/AmcCarrierCore", "Lcls1TimingStream")


# ===========================================
#               ASYN MASKS
# ===========================================

# ***********************************************************************
# **** Asyn Masks for YCPSWAsyn *****************************************
#asynSetTraceMask(${PORT},, -1, 9)


# ***********************************************************************
# **** Asyn Masks for Bergoz ********************************************
#asynSetTraceIOMask("$(BERGOZ0_PORT)",-1,0x2)
#asynSetTraceMask("$(BERGOZ0_PORT)",-1,0x9)


# ===========================================
#               DB LOADING
# ===========================================

# ************************************************************************
# **** Load YCPSWAsyn db *************************************************

#Save/Load configuration related records
dbLoadRecords("db/saveLoadConfig.db", "P=${AMC_CARRIER_PREFIX}, PORT=${CPSW_PORT}, SAVE_FILE=/tmp/configDump.yaml, LOAD_FILE=yaml/defaultsToro05-21-18.yaml, SAVE_ROOT=mmio, LOAD_ROOT=mmio")

# Manually create records
dbLoadRecords("db/bcm.db", "P=${AMC1_PREFIX}, PORT=${CPSW_PORT}, AMC=0")
dbLoadRecords("db/carrier.db", "P=${AMC_CARRIER_PREFIX}, PORT=${CPSW_PORT}")

# Parse IP address
dbLoadRecords("db/ipAddr.db", "P=${AMC_CARRIER_PREFIX}, SRC=SrvRemoteIp")
dbLoadRecords("db/swap.db",   "P=${AMC_CARRIER_PREFIX}, SRC=SrvRemotePort, DEST=SrvRemotePortSwap")

# *******************************
# **** Load message status   ****
dbLoadRecords("db/msgStatus.db","carrier_prefix=${AMC1_PREFIX}")

# Automatic initialization
dbLoadRecords("db/monitorFPGAReboot.db", "P=${AMC_CARRIER_PREFIX}, KEY=-66686157")

# ***********************************************************************
# **** Load TPR Triggers db *********************************************
dbLoadRecords("db/tprTrig.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=00,DEV_PREFIX=${AMC1_PREFIX}:TRG00:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=01,DEV_PREFIX=${AMC1_PREFIX}:TRG01:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=02,DEV_PREFIX=${AMC1_PREFIX}:TRG02:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=03,DEV_PREFIX=${AMC1_PREFIX}:TRG03:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=04,DEV_PREFIX=${AMC1_PREFIX}:TRG04:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=05,DEV_PREFIX=${AMC1_PREFIX}:TRG05:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=06,DEV_PREFIX=${AMC1_PREFIX}:TRG06:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=07,DEV_PREFIX=${AMC1_PREFIX}:TRG07:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=08,DEV_PREFIX=${AMC1_PREFIX}:TRG08:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=09,DEV_PREFIX=${AMC1_PREFIX}:TRG09:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=10,DEV_PREFIX=${AMC1_PREFIX}:TRG10:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=11,DEV_PREFIX=${AMC1_PREFIX}:TRG11:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=12,DEV_PREFIX=${AMC1_PREFIX}:TRG12:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=13,DEV_PREFIX=${AMC1_PREFIX}:TRG13:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=14,DEV_PREFIX=${AMC1_PREFIX}:TRG14:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=GUNB,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=15,DEV_PREFIX=${AMC1_PREFIX}:TRG15:")

# ***********************************************************************
# **** Load Bergoz db ***************************************************
dbLoadRecords("db/devBergozBCM.db" "P=$(BERGOZ0_P),R=$(BERGOZ0_R),PORT=$(BERGOZ0_PORT),A=-1")
dbLoadRecords("db/asynRecord.db" "P=$(BERGOZ0_P),R=asyn,PORT=$(BERGOZ0_PORT),ADDR=-1,OMAX=0,IMAX=0")
dbLoadRecords("db/TempMonitoring_TORO.db", "P=$(BERGOZ0_P)$(BERGOZ0_R),ESLO=$(ESLO),EOFF=$(EOFF), DEVICE=${TEMP_IOC_NAME}")

# ***********************************************************************
# **** Load message status   ********************************************
dbLoadRecords("db/msgStatus.db","carrier_prefix=${AMC1_PREFIX}")

# ***********************************************************************
# **** Load db for Temperature Chassis on Ethercat **********************
# Load the database templates for the EtherCAT components
# dbLoadRecords("db/<template_name_for slave_module>, <pass_in_macros>")
dbLoadRecords("db/EK1101.template", "DEVICE=${AMC1_PREFIX}:BCM_EK1101,PORT=COUPLER0,SCAN=1 second")
dbLoadRecords("db/EL3202-0010.template", "DEVICE=${AMC1_PREFIX}:TEMP1,PORT=Node1,SCAN=1 second")
dbLoadRecords("db/EL3202-0010.template", "DEVICE=${AMC1_PREFIX}:TEMP2,PORT=Node2,SCAN=1 second")
dbLoadRecords("db/EL3202-0010.template", "DEVICE=${AMC1_PREFIX}:TEMP3,PORT=Node3,SCAN=1 second")

# ************************************************************************
# **** Load BSA driver DB ************************************************
dbLoadRecords("db/bsa.db", "DEV=$(AMC1_PREFIX),PORT=bsaPort,BSAKEY=CHRG,SECN=CHRG")
dbLoadRecords("db/bsa.db", "DEV=$(AMC1_PREFIX),PORT=bsaPort,BSAKEY=CHRGUNC,SECN=CHRGUNC")
dbLoadRecords("db/bsa.db", "DEV=$(AMC1_PREFIX),PORT=bsaPort,BSAKEY=RAWSUM,SECN=RAWSUM")
dbLoadRecords("db/bsa.db", "DEV=$(AMC1_PREFIX),PORT=bsaPort,BSAKEY=CHRGFLOAT,SECN=CHRGFLOAT")
dbLoadRecords("db/bsa.db", "DEV=$(AMC1_PREFIX),PORT=bsaPort,BSAKEY=TOROSTATUS,SECN=TOROSTATUS")

# ************************************************************************
# **** Load MPS scale factor *********************************************
dbLoadRecords("db/mps_scale_factor.db", "P=${AMC1_PREFIX},PROPERTY=CHARGE,EGU=pC,PREC=8,VAL=0.0078125")
dbLoadRecords("db/mps_scale_factor.db", "P=${AMC1_PREFIX},PROPERTY=DIFF,EGU=pC,PREC=8,VAL=0.0078125")

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

# *********************
# **** Bergoz dbpf ****

# Save the TTY device name
dbpf $(BERGOZ0_P)$(BERGOZ0_R)TTY_RD $(BERGOZ0_TTY)

# Save the expected BERGOZ serial number
dbpf $(BERGOZ0_P)$(BERGOZ0_R)SERIALNUM_EXPECT $(BERGOZ0_SERIALNUM_EXPECT)

