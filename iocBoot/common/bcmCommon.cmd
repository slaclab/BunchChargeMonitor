# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# ========================================================
# Support Large Arrays/Waveforms; Number in Bytes
# Please calculate the size of the largest waveform
# that you support in your IOC.  Do not just copy numbers
# from other apps.  This will only lead to an exhaustion
# of resources and problems with your IOC.
# The default maximum size for a channel access array is
# 16K bytes.
# ========================================================
# Uncomment and set appropriate size for your application:

# This IOC provides waveforms with the maximum size of 2800 DBR_TIME_DOUBLE
# itens. For 64 bits systems it corresponds to 12 bytes per item.
# 2800 * 12 = 33600.
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","34000")

# IOC name for IOC admin
epicsEnvSet(IOC_NAME,"SIOC:${AREA}:${IOC_UNIT}")

epicsEnvSet("PREFIX","TORO:${AREA}:${IOC_UNIT}")

# PV prefix for AMC specific features
epicsEnvSet("AMC0_PREFIX","GADC:${AREA}:${IOC_UNIT}:A")
epicsEnvSet("AMC1_PREFIX","GADC:${AREA}:${IOC_UNIT}:B")
# PV prefix for ATCA carrier specific features.
epicsEnvSet("AMC_CARRIER_PREFIX","ARRY:${AREA}:${IOC_UNIT}")

# YAML directory
epicsEnvSet("YAML_DIR","${IOC_DATA}/${IOC}/firmware/yaml")
# Yaml File
epicsEnvSet("TOP_YAML","${YAML_DIR}/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "${YAML_DIR}/config/defaults.yaml")

# BSA stream name must be identical to definition in yaml file
epicsEnvSet("BSA_STREAM_YAML_NAME", "MrBcmBsaStream")

# *********************************************
# **** Environment variables for YCPSWASYN ****

# Use Automatic generation of records from the YAML definition.
# Usually it is 0.
# 0 = No, 1 = Yes
epicsEnvSet("AUTO_GEN", 0)

# Dictionary file for manually defined records
epicsEnvSet("DICT_FILE", "yaml/bcmMR.dict")

# ===========================================
#               DBD LOADING
# ===========================================
## Register all support components
dbLoadDatabase("dbd/bcm.dbd",0,0)
bcm_registerRecordDeviceDriver(pdbbase)

# ===========================================
#              DRIVER SETUP
# ===========================================

## Yaml Downloader
DownloadYamlFile("${FPGA_IP}", "${YAML_DIR}")

# Load yaml files do CPSW
cpswLoadYamlFile("${TOP_YAML}", "NetIODev", "", "${FPGA_IP}")
cpswLoadConfigFile("${YAML_CONFIG_FILE}", "mmio", "")

# Driver setup for YCPSWAsyn
# YCPSWASYNConfig(
#    Port Name,                 # the name given to this port driver
#    Root Path                  # OPTIONAL: Root path to start the generation. If empty, the Yaml root will be used
#    Record name Prefix,        # Record name prefix
#    Use DB Autogeneration,     # Set to 1 for autogeneration of records from the YAML definition. Set to 0 to disable it
#    Load dictionary,           # Dictionary file path with registers to load. An empty string will disable this function
YCPSWASYNConfig("cpsw", "", "${PREFIX}:", "${AUTO_GEN}", "${DICT_FILE}")

# Load drivers for TPR trigger, pattern, and crossbar control
crossbarControlAsynDriverConfigure("crossbar", "mmio/AmcCarrierCore/AxiSy56040")
tprTriggerAsynDriverConfigure("trig", "mmio/AmcCarrierCore")
tprPatternAsynDriverConfigure("pattern", "mmio/AmcCarrierCore", "tstream")

# ===========================================
#               DB LOADING
# ===========================================

# Daughter card features
dbLoadRecords("db/daughter.db", "P=${AMC0_PREFIX}, PORT=cpsw, AMC=0")
dbLoadRecords("db/daughter.db", "P=${AMC1_PREFIX}, PORT=cpsw, AMC=1")
dbLoadRecords("db/streamControl.db", "P=${AMC0_PREFIX}")
dbLoadRecords("db/streamControl.db", "P=${AMC1_PREFIX}")

# Carrier features
dbLoadRecords("db/carrier.db", "P=${AMC_CARRIER_PREFIX}, PORT=cpsw")
dbLoadRecords("db/bcmMPS.db", "P=${AMC_CARRIER_PREFIX}")

# Timing crossbar, pattern, and trigger
dbLoadRecords("db/tprTrig.db",      "LOCA=${AREA}, IOC_UNIT=${IOC_UNIT}, INST=2, PORT=trig")
dbLoadRecords("db/tprPattern.db",   "LOCA=${AREA}, IOC_UNIT=${IOC_UNIT}, INST=2, PORT=pattern")
dbLoadRecords("db/crossbarCtrl.db", "DEV=EVR:${AREA}:${IOC_UNIT}, PORT=crossbar")

#Save/Load configuration related records
dbLoadRecords("db/saveLoadConfig.db", "P=${PREFIX}, PORT=cpsw, SAVE_FILE=/tmp/configDump.yaml, LOAD_FILE=${IOC_DATA}/${IOC}/firmware/yaml/config/defaults.yaml")

# Automatic initialization
#dbLoadRecords("db/monitorFPGAReboot.db", "P=${PREFIX}:, KEY=840202")

# **********************************************************************
# **** Load iocAdmin databases to support IOC Health and monitoring ****
dbLoadRecords("db/iocAdminSoft.db","IOC=${IOC_NAME}")
dbLoadRecords("db/iocAdminScanMon.db","IOC=${IOC_NAME}")

# The following database is a result of a python parser
# which looks at RELEASE_SITE and RELEASE to discover
# versions of software your IOC is referencing
# The python parser is part of iocAdmin
dbLoadRecords("db/iocRelease.db","IOC=${IOC_NAME}")

# ===========================================
#          CHANNEL ACESS SECURITY
# ===========================================
# This is required if you use caPutLog.
# Set access security filea
# Load common LCLS Access Configuration File
< ${ACF_INIT}

# ===========================================
#           SETUP AUTOSAVE/RESTORE
# ===========================================
< iocBoot/common/init_restore_soft.cmd

# ===========================================
#           ARCHIVER FILES
# ===========================================
system("cp ${TOP}/archive/${IOC}.archive ${IOC_DATA}/${IOC}/archive")
