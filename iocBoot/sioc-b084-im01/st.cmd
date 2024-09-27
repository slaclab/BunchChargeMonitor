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
epicsEnvSet("YAML_DIR", "$(IOC_DATA)/$(IOC)/yaml")
epicsEnvSet("TOP_YAML", "$(YAML_DIR)/000TopLevel.yaml")
epicsEnvSet("YAML_CONFIG_FILE", "$(YAML_DIR)/config/defaultsToro.yaml")

epicsEnvSet("IOC_UNIT", "IM01")

# FPGA IP address
epicsEnvSet("FPGA_IP", "10.0.1.105")

# Use Automatic generation of records from the YAML definition
# 0 = No, 1 = Yes
epicsEnvSet("AUTO_GEN", 0)

# Automatically generated record prefix
#epicsEnvSet("PREFIX","GUNB:IM01")

# Production area
epicsEnvSet("AREA","GUNB")
epicsEnvSet("UNIT","360")
# Dev area
###epicsEnvSet("AREA","B084")
###epicsEnvSet("UNIT","215")

# BCM-TORO in crate 1, slot 5, AMC 0 - Since this prototype is in Lab 2 of B084
# we use it as prefix.
epicsEnvSet("AMC0_PREFIX","TORO:$(AREA):$(UNIT)")

# AMCC in crate 1, slot 7
epicsEnvSet("AMC_CARRIER_PREFIX","TORO:$(AREA):$(IOC_UNIT)")

# Start up enviroment variable 
epicsEnvSet("STARTUP","/usr/local/lcls/epics/iocCommon/${IOC_NAME}")
# ***********************************************************************
# **** Environment variables for MPS ************************************
epicsEnvSet("MPS_PORT",   "mpsPort")
epicsEnvSet("MPS_APP_ID", "7")
epicsEnvSet("MPS_PREFIX", "MPLN:GUNB:MP01:7")

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
epicsEnvSet("BERGOZ0_SERIALNUM_EXPECT","40")
epicsEnvSet("STREAM_PROTOCOL_PATH","${TOP}/db")

# *********************
# Temprature monitoring
# *********************
#epicsEnvSet("TEMP_IOC", "SIOC:${AREA}:IM03")
epicsEnvSet("TEMP_IOC", "SIOC:B084:IM03")
epicsEnvSet("TEMP_NODE", "1")
epicsEnvSet("TEMP_MODULE", "1")
epicsEnvSet("TEMP_BERGOZ_NODE", "1")
epicsEnvSet("TEMP_BERGOZ_MODULE", "2")
epicsEnvSet("TEMP_AMP_NODE", "2")
epicsEnvSet("TEMP_AMP_MODULE", "1")


cd $(TOP)

< iocBoot/common/bcmLCLS2Common.cmd
# Call this only in dev:
#L2MPSASYNSetManagerHost("lcls-dev3", 0)
