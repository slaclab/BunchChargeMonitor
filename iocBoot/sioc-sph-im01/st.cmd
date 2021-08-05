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

###variables for using yaml downloader
epicsEnvSet("YAML_DIR", "$(IOC_DATA)/$(IOC)/yaml"
epicsEnvSet("TOP_YAML", "$(YAML_DIR)/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "$(YAML_DIR)/config/defaultsToro.yaml")

###need to know which slot the daughter card is in 1 is temporary
epicsEnvSet("AMC1_POS", "1")
epicsEnvSet("IOC_UNIT", "IM01")

# FPGA IP address
epicsEnvSet("FPGA_IP", "10.0.1.104")


# Use Automatic generation of records from the YAML definition
# 0 = No, 1 = Yes
epicsEnvSet("AUTO_GEN", 0)

# Automatically generated record prefix
#epicsEnvSet("PREFIX","SPH:IM01")

AREA
epicsEnvSet("AREA","SPH")
epicsEnvSet("UNIT","365")

epicsEnvSet("AMC0_PREFIX","TORO:$(AREA):$(UNIT)")

# AMCC in crate 1, slot 7
epicsEnvSet("AMC_CARRIER_PREFIX","TORO:$(AREA):$(IOC_UNIT)")

# Dictionary file for manual (empty string if none)
epicsEnvSet("DICT_FILE", "yaml/bcmLCLS2.dict")

# Start up enviroment variable 
epicsEnvSet("STARTUP","/usr/local/lcls/epics/iocCommon/${IOC_NAME}")
# ***********************************************************************
# **** Environment variables for MPS ************************************
epicsEnvSet("MPS_PORT",   "mpsPort")
epicsEnvSet("MPS_APP_ID", "184")
epicsEnvSet("MPS_PREFIX", "MPLN:SPH:MP03:4")

# ***********************************************************************
# **** Environment variables for Temperature Chassis on Ethercat ********

# System Location:
epicsEnvSet("TEMP_IOC_NAME","$(AMC0_PREFIX)")

# ***********************************************************************
# **** Environment variables for IOC Admin ******************************
epicsEnvSet(IOC_NAME,"SIOC:$(AREA):IM01")

# ***********************************************************************
# **** Environment variables for bergoz detection  **********************
# Serial number for bergoz
epicsEnvSet("IM01","2C")

# **********************************************************************
# **** Environment variables for Toroid on  Bergoz *********************

epicsEnvSet("BERGOZ0_P","$(AMC0_PREFIX):")
epicsEnvSet("BERGOZ0_R","")
epicsEnvSet("BERGOZ0_IN_PORT","L0")
epicsEnvSet("BERGOZ0_OUT_PORT","L1")
epicsEnvSet("BERGOZ0_SERIALNUM_EXPECT","38")
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
### changed to yaml downloader
DownloadYamlFile("$(FPGA_IP)", "$(YAML_DIR)")

###to bring up to current standard importing from $IOC_DATA
cpswLoadYamlFile("${TOP_YAML}", "NetIODev", "", "${FPGA_IP}")
cpswLoadConfigFile("${YAML_CONFIG_FILE}", "mmio")



# **********************************************************************
# **** Setup BSA Driver*************************************************
# add BSA PVs
addBsa("CHRG",       "uint32")
addBsa("CHRGUNC",    "uint32")
addBsa("RAWSUM",     "uint32")
addBsa("CHRGFLOAT",  "float32")
addBsa("TOROSTATUS", "uint32")
addBsa("CHRGNOTMIT", "uint32")
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
L2MPSASYNConfig("${MPS_PORT}","${MPS_APP_ID}", "${MPS_PREFIX}", "${AMC0_PREFIX}", "", "")

## Configure asyn port driver
# YCPSWASYNConfig(
#    Port Name,                 # the name given to this port driver
#    Root Path                  # OPTIONAL: Root path to start the generation. If empty, the Yaml root will be used
#    Record name Prefix,        # Record name prefix
#    Use DB Autogeneration,     # Set to 1 for autogeneration of records from the YAML definition. Set to 0 to disable it
#    Load dictionary,           # Dictionary file path with registers to load. An empty string will disable this function
YCPSWASYNConfig("Atca7", "", "", "0", "${DICT_FILE}")


# ===========================================
#	        IDENTIFY Bergoz 
# ===========================================
#cd(${TOP}/bcmApp/scripts/)
#system("./getBergozLocation.sh ")
#< /tmp/im01_path
#cd(${TOP})
#epicsEnvSet("BERGOZ0_TTY","$(IM01_PATH)")

epicsEnvSet("BERGOZ0_TTY","/dev/ttyACM0")


# ***********************************************************************
# **** Driver setup for Bergoz ******************************************
# Set up ASYN ports
# drvAsynIPPortConfigure port ipInfo priority noAutoconnect noProcessEos
drvAsynSerialPortConfigure("$(BERGOZ0_IN_PORT)","$(BERGOZ0_TTY)",0,0,0)
drvAsynSerialPortConfigure("$(BERGOZ0_OUT_PORT)","$(BERGOZ0_TTY)",0,0,0)

# ***********************************************************************
# **** Setup TprTrigger Driver ******************************************
tprTriggerAsynDriverConfigure("trig", "mmio/AmcCarrierCore")

# ***********************************************************************
# **** Setup Crossbar Control Driver ************************************
crossbarControlAsynDriverConfigure("crossbar", "mmio/AmcCarrierCore/AxiSy56040")

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
#asynSetTraceIOMask("$(BERGOZ0_IN_PORT)",-1,0x2)
#asynSetTraceMask("$(BERGOZ0_IN_PORT)",-1,0x9)
#asynSetTraceIOMask("$(BERGOZ0_OUT_PORT)",-1,0x2)
#asynSetTraceMask("$(BERGOZ0_OUT_PORT)",-1,0x9)


# ===========================================
#               DB LOADING
# ===========================================

# ************************************************************************
# **** Load YCPSWAsyn db *************************************************

#Save/Load configuration related records
dbLoadRecords("db/saveLoadConfig.db", "P=${AMC_CARRIER_PREFIX}, PORT=${CPSW_PORT}")

# Manually create records
dbLoadRecords("db/bcmAmc.db", "P=$(AMC0_PREFIX), PORT=$(CPSW_PORT), AMC=0")
dbLoadRecords("db/bcmChan.db", "P=$(AMC0_PREFIX):0, PORT=$(CPSW_PORT), AMC=0, CHAN=0")
dbLoadRecords("db/bcmLCLS2amc.db", "P=$(AMC0_PREFIX), PORT=$(CPSW_PORT), AMC=0")
dbLoadRecords("db/bcmLCLS2chan.db", "P=$(AMC0_PREFIX):0, PORT=$(CPSW_PORT), AMC=0, CHAN=0")

dbLoadRecords("db/carrier.db", "P=${AMC_CARRIER_PREFIX}, PORT=${CPSW_PORT}")
dbLoadRecords("db/iocMeta.db", "AREA=${AREA}, IOC_UNIT=${IOC_UNIT}")

# Parse IP address
dbLoadRecords("db/ipAddr.db", "P=${AMC_CARRIER_PREFIX}, SRC=SrvRemoteIp")
dbLoadRecords("db/swap.db",   "P=${AMC_CARRIER_PREFIX}, SRC=SrvRemotePort, DEST=SrvRemotePortSwap")

# *******************************
# **** Load message status   ****
#dbLoadRecords("db/msgStatus.db","carrier_prefix=${AMC_CARRIER_PREFIX},DESC=Communications Diagnostics,BPM_LOCA=314,LOCA=$(UNIT),AREA=SPH")
#dbLoadRecords("db/monitorFPGAReboot.db", "P=${AMC_CARRIER_PREFIX}, KEY=-66686157")

###*************************
###setting up the stream device
dbLoadRecords("db/streamControl.db", "P=$(AMC0_PREFIX)")

#loads the waveform records
dbLoadRecords("db/waveform.db", "P=$(AMC0_PREFIX),CHAN=0")

dbLoadRecords("db/weightFunctionXAxis.db", "P=$(AMC0_PREFIX),CHAN=0")
dbLoadRecords("db/calculatedWF.db", "P=$(AMC0_PREFIX),CHAN=0")
dbLoadRecords("db/processRawWFHeader.db", "P=$(AMC0_PREFIX),CHAN=0")

dbLoadRecords("db/lcls2Calibration.db", "P=$(AMC0_PREFIX),LOCA=${AREA},IOC_UNIT=IM01,INST=0")

# ***********************************************************************
# **** Load TPR Triggers db *********************************************
dbLoadRecords("db/tprTrig.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=00,DEV_PREFIX=${AMC0_PREFIX}:TRG00:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=01,DEV_PREFIX=${AMC0_PREFIX}:TRG01:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=02,DEV_PREFIX=${AMC0_PREFIX}:TRG02:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=03,DEV_PREFIX=${AMC0_PREFIX}:TRG03:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=04,DEV_PREFIX=${AMC0_PREFIX}:TRG04:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=05,DEV_PREFIX=${AMC0_PREFIX}:TRG05:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=06,DEV_PREFIX=${AMC0_PREFIX}:TRG06:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=07,DEV_PREFIX=${AMC0_PREFIX}:TRG07:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=08,DEV_PREFIX=${AMC0_PREFIX}:TRG08:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=09,DEV_PREFIX=${AMC0_PREFIX}:TRG09:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=10,DEV_PREFIX=${AMC0_PREFIX}:TRG10:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=11,DEV_PREFIX=${AMC0_PREFIX}:TRG11:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=12,DEV_PREFIX=${AMC0_PREFIX}:TRG12:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=13,DEV_PREFIX=${AMC0_PREFIX}:TRG13:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=14,DEV_PREFIX=${AMC0_PREFIX}:TRG14:,PORT=trig")
dbLoadRecords("db/tprDeviceNamePV.db","LOCA=${AREA},IOC_UNIT=IM01,INST=0,SYS=SYS2,NN=15,DEV_PREFIX=${AMC0_PREFIX}:TRG15:,PORT=trig")

# ***********************************************************************
# **** Load Bergoz db ***************************************************
dbLoadRecords("db/devBergozBCM.db" "P=$(BERGOZ0_P),R=$(BERGOZ0_R),PORT=$(BERGOZ0_IN_PORT),PORT_OUT=$(BERGOZ0_OUT_PORT),A=-1")
dbLoadRecords("db/asynRecord.db" "P=$(BERGOZ0_P),R=asyn,PORT=$(BERGOZ0_IN_PORT),ADDR=-1,OMAX=0,IMAX=0")

# ************************************************************************
# **** Load BSA driver DB ************************************************
dbLoadRecords("db/bsa.db", "DEV=$(AMC0_PREFIX),PORT=bsaPort,BSAKEY=CHRG,SECN=CHRG")
dbLoadRecords("db/bsa.db", "DEV=$(AMC0_PREFIX),PORT=bsaPort,BSAKEY=CHRGUNC,SECN=CHRGUNC")
dbLoadRecords("db/bsa.db", "DEV=$(AMC0_PREFIX),PORT=bsaPort,BSAKEY=RAWSUM,SECN=RAWSUM")
dbLoadRecords("db/bsa.db", "DEV=$(AMC0_PREFIX),PORT=bsaPort,BSAKEY=CHRGFLOAT,SECN=CHRGFLOAT")
dbLoadRecords("db/bsa.db", "DEV=$(AMC0_PREFIX),PORT=bsaPort,BSAKEY=TOROSTATUS,SECN=TOROSTATUS")
dbLoadRecords("db/bsa.db", "DEV=$(AMC0_PREFIX),PORT=bsaPort,BSAKEY=CHRGNOTMIT,SECN=CHRGNOTMIT")

# ************************************************************************
# **** Load MPS scale factor *********************************************
#dbLoadRecords("db/mps_scale_factor.db", "P=${AMC0_PREFIX},PROPERTY=CHARGE,EGU=pC,PREC=8,SLOPE=0.0078125,OFFSET=0")
#dbLoadRecords("db/mps_scale_factor.db", "P=${AMC0_PREFIX},PROPERTY=DIFF,EGU=pC,PREC=8,SLOPE=0.0078125,OFFSET=0")

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

# Deactivate trigger in order to stop unsolicited messages from Bergoz
dbpf TPR:${AREA}:IM01:0:CH01_SYS2_TCTL 0

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

# Start loading configuration file
dbpf TORO:${AREA}:${IOC_UNIT}:saveConfigFile "/tmp/configDump.yaml"
dbpf TORO:${AREA}:${IOC_UNIT}:saveConfigRoot "mmio"
dbpf TORO:${AREA}:${IOC_UNIT}:saveConfig 1
dbpf TORO:${AREA}:${IOC_UNIT}:loadConfigFile "yaml/AmcCarrierBcm_project.yaml/config/defaultsToro.yaml"
dbpf TORO:${AREA}:${IOC_UNIT}:loadConfigRoot "mmio"
# We should never load the configuration file after autosave already changed
# the parameters. Uncomment the line below only if you are sure about what you
# are doing.
#dbpf TORO:${AREA}:${IOC_UNIT}:loadConfig 1
dbpf TORO:${AREA}:${UNIT}:Temp.EGU K
dbpf TORO:${AREA}:${UNIT}:TempAmp.EGU K
dbpf TORO:${AREA}:${UNIT}:TempElc.EGU K
dbpf TORO:${AREA}:${UNIT}:READ_PARMS 1

# Reactivate trigger to restart unsolicited messages from Bergoz
epicsThreadSleep 1
dbpf TPR:${AREA}:IM01:0:CH01_SYS2_TCTL 1
