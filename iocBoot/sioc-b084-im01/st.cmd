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
#epicsEnvSet("PREFIX","B084:IM01")

epicsEnvSet("AREA","B084")

# BCM-TORO in crate 1, slot 5, AMC 0  - Since this prototype is in Lab 2 of B084 we use it as prefix.
epicsEnvSet("AMC0_PREFIX","TORO:$(AREA):215")

# AMCC in crate 1, slot 5
epicsEnvSet("AMC_CARRIER_PREFIX","AMCC:$(AREA):215")

# Dictionary file for manual (empty string if none)
epicsEnvSet("DICT_FILE", "yaml/bcm_01_20170313140632.dict")


# *****************************************************
# **** Environment variables for Toroid on  Bergoz ****

epicsEnvSet("BERGOZ0_P","$(AMC0_PREFIX):")
epicsEnvSet("BERGOZ0_R","")
epicsEnvSet("BERGOZ0_PORT","L0")
epicsEnvSet("BERGOZ0_TTY","/dev/ttyACM0")
epicsEnvSet("BERGOZ0_SERIALNUM_EXPECT","40")
epicsEnvSet("STREAM_PROTOCOL_PATH","${TOP}/db")

# Temperature xfer: ESLO, EOFF
epicsEnvSet("ESLO","$(ESLO=0.01)")
epicsEnvSet("EOFF","$(EOFF=273.15)")

# *******************************************************************
# **** Environment variables for Temperature Chassis on Ethercat ****

# System Location:
epicsEnvSet(FAC,"SYS2")
epicsEnvSet("LOCA","B084")
epicsEnvSet("TEMP_IOC_NAME","SIOC:${LOCA}:FC01")


# *********************************************
# **** Environment variables for IOC Admin ****

epicsEnvSet(IOC_NAME,"SIOC:$(AREA):IM01")

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

# ************************************
# **** Driver setup for YCPSWAsyn ****

## Configure the Yaml Loader Driver
# cpswLoadYamlFile(
#    Yaml Doc,                  # Path to the YAML hierarchy description file
#    Root Device,               # Root Device Name (optional; default = 'root')
#    YAML Path,                 #directory where YAML includes can be found (optional)
#    IP Address,                # OPTIONAL: Target FPGA IP Address. If not given it is taken from the YAML file
# ==========================================================================================================
cpswLoadYamlFile("${YAML_FILE}", "NetIODev", "", "${FPGA_IP}")

# ====================================
# Setup BSA Driver
# ====================================
# add BSA PVs
addBsa("CHRG",       "uint32")
addBsa("CHRGUNC",    "uint32")
addBsa("RAWSUM",     "uint32")
addBsa("CHRGFLOAT",  "float32")
addBsa("TOROSTATUS", "uint32")

# BSA driver for yaml
bsaAsynDriverConfigure("bsaPort", "mmio/AmcCarrierCore/AmcCarrierBsa","strm/AmcCarrierDRAM/dram")

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
drvAsynSerialPortConfigure("$(BERGOZ0_PORT)","$(BERGOZ0_TTY)",0,0,0)


# **********************************************************
# **** Driver setup for Temperature Chassis on Ethercat ****

# Init EtherCAT: To support Real Time fieldbus
# EtherCAT AsynDriver must be initialized in the IOC startup script before iocInit
# ecAsynInit("<unix_socket>", <max_message>)
# unix_socket = path to the unix socket created by the scanner
# max_message = maximum size of messages between scanner and ioc
ecAsynInit("/tmp/sock1", 1000000)

# ====================================
# Setup TprTrigger Driver
# ====================================
tprTriggerAsynDriverConfigure("trig", "mmio/AmcCarrierCore")
tprPatternAsynDriverConfigure("pattern", "mmio/AmcCarrierCore", "Lcls1TimingStream")

# ===========================================
#               ASYN MASKS
# ===========================================

# **********************************
# **** Asyn Masks for YCPSWAsyn ****

#asynSetTraceMask(${PORT},, -1, 9)


# *******************************
# **** Asyn Masks for Bergoz ****

#asynSetTraceIOMask("$(BERGOZ0_PORT)",-1,0x2)
#asynSetTraceMask("$(BERGOZ0_PORT)",-1,0x9)


# ===========================================
#               DB LOADING
# ===========================================

# ***************************
# **** Load YCPSWAsyn db ****

#Save/Load configuration related records
dbLoadRecords("db/saveLoadConfig.db", "P=${AMC_CARRIER_PREFIX}, PORT=${CPSW_PORT}, SAVE_FILE=/tmp/configDump.yaml, LOAD_FILE=yaml/defaultsToro05-21-18.yaml, SAVE_ROOT=mmio, LOAD_ROOT=mmio")

# Manually create records
dbLoadRecords("db/bcm.db", "P=${AMC0_PREFIX}, PORT=${CPSW_PORT}, AMC=0")
dbLoadRecords("db/carrier.db", "P=${AMC_CARRIER_PREFIX}, PORT=${CPSW_PORT}")

# Parse IP address
dbLoadRecords("db/ipAddr.db", "P=${AMC_CARRIER_PREFIX}, SRC=SrvRemoteIp")
dbLoadRecords("db/swap.db",   "P=${AMC_CARRIER_PREFIX}, SRC=SrvRemotePortSwap, DEST=SrvRemotePort")

# Automatic initialization
dbLoadRecords("db/monitorFPGAReboot.db", "P=${AMC_CARRIER_PREFIX}, KEY=-66686157")

# ******************************
# **** Load TPR Triggers db ****
dbLoadRecords("db/tprTrig.db","LOCA=B084,IOC_UNIT=IM01,INST=0")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=00,DEV_PREFIX=${AMC0_PREFIX}:TRG00:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=01,DEV_PREFIX=${AMC0_PREFIX}:TRG01:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=02,DEV_PREFIX=${AMC0_PREFIX}:TRG02:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=03,DEV_PREFIX=${AMC0_PREFIX}:TRG03:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=04,DEV_PREFIX=${AMC0_PREFIX}:TRG04:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=05,DEV_PREFIX=${AMC0_PREFIX}:TRG05:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=06,DEV_PREFIX=${AMC0_PREFIX}:TRG06:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=07,DEV_PREFIX=${AMC0_PREFIX}:TRG07:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=08,DEV_PREFIX=${AMC0_PREFIX}:TRG08:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=09,DEV_PREFIX=${AMC0_PREFIX}:TRG09:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=10,DEV_PREFIX=${AMC0_PREFIX}:TRG10:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=11,DEV_PREFIX=${AMC0_PREFIX}:TRG11:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=12,DEV_PREFIX=${AMC0_PREFIX}:TRG12:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=13,DEV_PREFIX=${AMC0_PREFIX}:TRG13:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=14,DEV_PREFIX=${AMC0_PREFIX}:TRG14:")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=B084,IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=15,DEV_PREFIX=${AMC0_PREFIX}:TRG15:")


# ************************
# **** Load Bergoz db ****

dbLoadRecords("db/devBergozBCM.db" "P=$(BERGOZ0_P),R=$(BERGOZ0_R),PORT=$(BERGOZ0_PORT),A=-1")
dbLoadRecords("db/asynRecord.db" "P=$(BERGOZ0_P),R=asyn,PORT=$(BERGOZ0_PORT),ADDR=-1,OMAX=0,IMAX=0")
#######dbLoadRecords("db/TempMonitoring_TORO.db", "P=$(BERGOZ0_P)$(BERGOZ0_R),ESLO=$(ESLO),EOFF=$(EOFF)")
dbLoadRecords("db/TempMonitoring_TORO.db", "P=$(BERGOZ0_P)$(BERGOZ0_R),ESLO=$(ESLO),EOFF=$(EOFF), DEVICE=${TEMP_IOC_NAME}")

# *****************************************************
# **** Load db for Temperature Chassis on Ethercat ****

# Load the database templates for the EtherCAT components
# dbLoadRecords("db/<template_name_for slave_module>, <pass_in_macros>")
dbLoadRecords("db/EK1101.template", "DEVICE=${TEMP_IOC_NAME}:BCM_EK1101,PORT=COUPLER0,SCAN=1 second")
dbLoadRecords("db/EL3202-0010.template", "DEVICE=${TEMP_IOC_NAME}:BCM_EL3202_1,PORT=ANALOGINPUT1,SCAN=1 second")
dbLoadRecords("db/EL3202-0010.template", "DEVICE=${TEMP_IOC_NAME}:BCM_EL3202_2,PORT=ANALOGINPUT2,SCAN=1 second")

# ****************************
# **** Load BSA driver DB ****

dbLoadRecords("db/bsa.db", "DEV=$(AMC0_PREFIX),PORT=bsaPort,BSAKEY=CHRG,SECN=CHRG")
dbLoadRecords("db/bsa.db", "DEV=$(AMC0_PREFIX),PORT=bsaPort,BSAKEY=CHRGUNC,SECN=CHRGUNC")
dbLoadRecords("db/bsa.db", "DEV=$(AMC0_PREFIX),PORT=bsaPort,BSAKEY=RAWSUM,SECN=RAWSUM")
dbLoadRecords("db/bsa.db", "DEV=$(AMC0_PREFIX),PORT=bsaPort,BSAKEY=CHRGFLOAT,SECN=CHRGFLOAT")
dbLoadRecords("db/bsa.db", "DEV=$(AMC0_PREFIX),PORT=bsaPort,BSAKEY=TOROSTATUS,SECN=TOROSTATUS")


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
dbpf $(BERGOZ0_P)$(BERGOZ0_R)TTY_RD $(BERGOZ0_TTY)

# Save the expected BERGOZ serial number
dbpf $(BERGOZ0_P)$(BERGOZ0_R)SERIALNUM_EXPECT $(BERGOZ0_SERIALNUM_EXPECT)

# ************************************************************
# **** System command for Temperature Chassis on Ethercat ****
# Setup Real-time priorities after iocInit for driver threads
system("/bin/su root -c `pwd`/rtPrioritySetup.cmd")
