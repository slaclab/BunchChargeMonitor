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
DownloadYamlFile("$(FPGA_IP)", "$(YAML_DIR)")
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
listBsa()
bsssAssociateBsaChannels("bsaPort")
bsssAsynDriverConfigure("bsssPort", "mmio/AmcCarrierCore/AmcCarrierBsa/Bsss")


## Set MPS Configuration location
# setMpsConfigurationPath(
#   Path)                   # Path to the MPS configuraton TOP directory
setMpsConfigurationPath("${FACILITY_ROOT}/physics/mps_configuration/current/link_node_db")

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


# Dictionary file for manual (empty string if none)
epicsEnvSet("DICT_FILE1", "firmware/bcmLCLS2.dict")


## Configure asyn port driver
# YCPSWASYNConfig(
#    Port Name,                 # the name given to this port driver
#    Root Path                  # OPTIONAL: Root path to start the generation. If empty, the Yaml root will be used
#    Record name Prefix,        # Record name prefix
#    Use DB Autogeneration,     # Set to 1 for autogeneration of records from the YAML definition. Set to 0 to disable it
#    Load dictionary,           # Dictionary file path with registers to load. An empty string will disable this function
YCPSWASYNConfig("Atca7", "", "", "0", "${DICT_FILE1}")


# ===========================================
#	        IDENTIFY Bergoz 
# ===========================================
cd(${TOP}/bcmApp/scripts/)
system("./getBergozLocation.sh")
< /tmp/im01_path
cd(${TOP})
epicsEnvSet("BERGOZ0_TTY","$(IM01_PATH)")

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

dbLoadRecords("db/carrierLCLS2.db", "P=${AMC_CARRIER_PREFIX}, PORT=${CPSW_PORT}")
dbLoadRecords("db/iocMeta.db", "AREA=${AREA}, IOC_UNIT=${IOC_UNIT}")

# Parse IP address
dbLoadRecords("db/ipAddrParse.db", "P=${AMC_CARRIER_PREFIX}, SRC=SrvRemoteIp, SCAN=10 second")
dbLoadRecords("db/selectStatus.db", "P=${AMC_CARRIER_PREFIX}")
dbLoadRecords("db/bpmBcmDiff.db", "P=${AMC_CARRIER_PREFIX}, BcmChrg=$(AMC0_PREFIX)")
dbLoadRecords("db/swap.db",   "P=${AMC_CARRIER_PREFIX}, SRC=SrvRemotePort, DEST=SrvRemotePortSwap")

# *******************************
# **** Load message status   ****
dbLoadRecords("db/msgStatus.db", "P=${AMC_CARRIER_PREFIX}")
dbLoadRecords("db/bpmSelect.db", "P=${AMC_CARRIER_PREFIX}")
dbLoadRecords("db/monitorFPGAReboot.db", "P=${AMC_CARRIER_PREFIX}, KEY=-66686157")

###*************************
###setting up the stream device
dbLoadRecords("db/streamControl.db", "P=$(AMC0_PREFIX)")

dbLoadRecords("db/waveform.db", "P=$(AMC0_PREFIX),CHAN=0")

dbLoadRecords("db/weightFunctionXAxis.db", "P=$(AMC0_PREFIX),CHAN=0")
dbLoadRecords("db/calculatedWF.db", "P=$(AMC0_PREFIX),CHAN=0")
dbLoadRecords("db/processRawWFHeader.db", "P=$(AMC0_PREFIX),CHAN=0")

dbLoadRecords("db/lcls2BergozMode.db", "P=$(AMC0_PREFIX),LOCA=${AREA},IOC_UNIT=IM01,INST=0, AmcPrefix=${AMC_CARRIER_PREFIX}")
dbLoadRecords("db/lcls2BergozCalibration.db", "P=$(AMC0_PREFIX)")
dbLoadRecords("db/lcls2BergozInfo.db","P=$(AMC0_PREFIX)")

#Temprature monitoring
epicsEnvSet("ETHER_CAT_SCALE", "0.01")
epicsEnvSet("ETHER_CAT_OFFSET","273.15")

epicsEnvSet("TEMP_ATCA_ELEC_SCALE", "1")
epicsEnvSet("TEMP_ATCA_ELEC_OFFSET", "0")
epicsEnvSet("TEMP_TORO_SCALE", "$(ETHER_CAT_SCALE)")
epicsEnvSet("TEMP_TORO_OFFSET", "$(ETHER_CAT_OFFSET)")
epicsEnvSet("TEMP_AMP_SCALE", "$(ETHER_CAT_SCALE)")
epicsEnvSet("TEMP_AMP_OFFSET", "$(ETHER_CAT_OFFSET)")
epicsEnvSet("TEMP_BERGOZ_SCALE", "$(ETHER_CAT_SCALE)")
epicsEnvSet("TEMP_BERGOZ_OFFSET", "$(ETHER_CAT_OFFSET)")

epicsEnvSet("TEMP_FPGA_SCALE", "0.1224058") #to convert from the fpga reading to kelvin
epicsEnvSet("TEMP_FPGA_OFFSET", "0")

epicsEnvSet("TEMP_SRC", "${TEMP_IOC}:${TEMP_NODE}:INPUT${TEMP_MODULE}:VALUE")
epicsEnvSet("TEMP_BERGOZ_ELEC_SRC", "${TEMP_IOC}:${TEMP_BERGOZ_NODE}:INPUT${TEMP_BERGOZ_MODULE}:VALUE")
epicsEnvSet("TEMP_AMP_SRC", "${TEMP_IOC}:${TEMP_AMP_NODE}:INPUT${TEMP_AMP_MODULE}:VALUE")

dbLoadRecords("db/tempProcess.db","P=$(AMC0_PREFIX), R=FPGATemperatureBitShift, SRC=$(AMC0_PREFIX):FPGATemperatureRaw, DEST=, SCALE=0.0625, OFFSET=0")#4 bit shift

dbLoadRecords("db/tempProcess.db","P=$(AMC0_PREFIX), R=TempATCAElcCalc, SRC=$(AMC0_PREFIX):FPGATemperatureBitShift, DEST=${AMC0_PREFIX}:TempATCAElc, SCALE=$(TEMP_FPGA_SCALE), OFFSET=$(TEMP_FPGA_OFFSET)")

dbLoadRecords("db/tempProcess.db","P=$(AMC0_PREFIX), R=TempBergozElcCalc, SRC=${TEMP_BERGOZ_ELEC_SRC}, DEST=${AMC0_PREFIX}:TempBergozElc, SCALE=$(TEMP_BERGOZ_SCALE), OFFSET=$(TEMP_BERGOZ_OFFSET)")
dbLoadRecords("db/tempProcess.db","P=$(AMC0_PREFIX), R=TempToroCalc, SRC=${TEMP_SRC}, DEST=${AMC0_PREFIX}:TempToro, SCALE=$(TEMP_TORO_SCALE), OFFSET=$(TEMP_TORO_OFFSET) ")
dbLoadRecords("db/tempProcess.db","P=$(AMC0_PREFIX), R=TempAmpCalc, SRC=${TEMP_AMP_SRC}, DEST=${AMC0_PREFIX}:TempAmp, SCALE=$(TEMP_AMP_SCALE), OFFSET=$(TEMP_AMP_OFFSET) ")

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
dbLoadRecords("db/mps_scale_factor.db", "P=${AMC0_PREFIX},PROPERTY=CHARGE,EGU=pC,PREC=8,SLOPE=0.0078125,OFFSET=0")
dbLoadRecords("db/mps_scale_factor.db", "P=${AMC0_PREFIX},PROPERTY=DIFF,EGU=pC,PREC=8,SLOPE=0.0078125,OFFSET=0")

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
set_requestfile_path("${TOP}/autosave", "")
set_requestfile_path("${TOP}/iocBoot/${IOC}", "")

# Where to write the save files that will be used to restore
set_savefile_path("/data/${IOC}/autosave")

# Prefix that is use to update save/restore status database
# records
save_restoreSet_UseStatusPVs(1)
save_restoreSet_status_prefix("${IOC_NAME}:")

## Restore datasets
set_pass0_restoreFile("info_settings.sav")
set_pass0_restoreFile("info_positions.sav")
set_pass0_restoreFile("$(IOC).sav")
set_pass1_restoreFile("$(IOC).sav")

# ===========================================
#          CHANNEL ACESS SECURITY
# ===========================================
# This is required if you use caPutLog.
# Set access security filea
# Load common LCLS Access Configuration File
< ${ACF_INIT}

# Load initialization records
dbLoadRecords("db/initBCM.db", "P1=$(AMC0_PREFIX), P2=${BERGOZ0_P}, R=${BERGOZ0_R}")

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
create_monitor_set("$(IOC).req", 5, "")

cd ${TOP}

# *********************
# **** Bergoz dbpf ****

# Save the TTY device name
dbpf $(BERGOZ0_P)$(BERGOZ0_R)TTY_RD $(BERGOZ0_TTY)

# Save the expected BERGOZ serial number
dbpf $(BERGOZ0_P)$(BERGOZ0_R)SERIALNUM_EXPECT $(BERGOZ0_SERIALNUM_EXPECT)

#MPS workaround
dbpf ${MPS_PREFIX}:THR_LOADED 1
dbpf ${MPS_PREFIX}:MPS_EN 1

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
#dbpf TORO:${AREA}:${UNIT}:Temp.EGU K
#dbpf TORO:${AREA}:${UNIT}:TempAmp.EGU K
#dbpf TORO:${AREA}:${UNIT}:TempElc.EGU K
dbpf TORO:${AREA}:${UNIT}:READ_PARMS 1

# Reactivate trigger to restart unsolicited messages from Bergoz
epicsThreadSleep 1
dbpf TPR:${AREA}:IM01:0:CH01_SYS2_TCTL 1

epicsThreadSleep 10
dbpf ${AMC0_PREFIX}:INITBCM.PROC 1

#////////////////////////////////////////#
#Run script to generate archiver files   #
#////////////////////////////////////////#
cd(${TOP}/bcmApp/scripts/)
system("./makeArchive.sh ${IOC} &")
cd(${TOP})
