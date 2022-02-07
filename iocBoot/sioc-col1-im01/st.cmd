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

epicsEnvSet("IOC_UNIT", "IM01")

# FPGA IP address
epicsEnvSet("FPGA_IP", "10.0.1.106")


# Use Automatic generation of records from the YAML definition
# 0 = No, 1 = Yes
epicsEnvSet("AUTO_GEN", 0)

# Automatically generated record prefix
#epicsEnvSet("PREFIX","COL1:IM01")

#Area
epicsEnvSet("AREA","COL1")
epicsEnvSet("UNIT","125")


# BCM-TORO in crate 1, slot 6, AMC 0
epicsEnvSet("AMC0_PREFIX","TORO:$(AREA):$(UNIT)")

# AMCC in crate 1, slot 6
epicsEnvSet("AMC_CARRIER_PREFIX","TORO:$(AREA):$(IOC_UNIT)")

# Dictionary file for manual (empty string if none)
epicsEnvSet("DICT_FILE", "firmware/bcmLCLS2.dict")

# Start up enviroment variable 
epicsEnvSet("STARTUP","/usr/local/lcls/epics/iocCommon/${IOC_NAME}")
# ***********************************************************************
# **** Environment variables for MPS ************************************
epicsEnvSet("MPS_PORT",   "mpsPort")
epicsEnvSet("MPS_APP_ID", "41")
epicsEnvSet("MPS_PREFIX", "MPLN:BC1B:MP01:6")

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
epicsEnvSet("BERGOZ0_SERIALNUM_EXPECT","36")
epicsEnvSet("STREAM_PROTOCOL_PATH","${TOP}/db")


epicsEnvSet("TEMP_IOC", "SIOC:${AREA}:IM02")
epicsEnvSet("TEMP_NODE", "3")
epicsEnvSet("TEMP_MODULE", "1")
epicsEnvSet("TEMP_ELEC_NODE", "2")
epicsEnvSet("TEMP_ELEC_MODULE", "1")
epicsEnvSet("TEMP_AMP_NODE", "3")
epicsEnvSet("TEMP_AMP_MODULE", "2")

epicsEnvSet("TEMP_BERGOZ_SRC", "${TEMP_IOC}:${TEMP_BERGOZ_NODE}:INPUT${TEMP_BERGOZ_MODULE}:VALUE")

epicsEnvSet("TEMP_SRC", "${TEMP_IOC}:${TEMP_NODE}:INPUT${TEMP_MODULE}:VALUE")
epicsEnvSet("TEMP_ELEC_SRC", "${TEMP_IOC}:${TEMP_ELEC_NODE}:INPUT${TEMP_ELEC_MODULE}:VALUE")
epicsEnvSet("TEMP_AMP_SRC", "${TEMP_IOC}:${TEMP_AMP_NODE}:INPUT${TEMP_AMP_MODULE}:VALUE")

epicsEnvSet("ETHER_CAT_SCALE", "0.01")
epicsEnvSet("ETHER_CAT_OFFSET","273.15")

epicsEnvSet("TEMP_FPGA_SCALE", "0.1224058") #to convert from the fpga reading to kelvin
epicsEnvSet("TEMP_FPGA_OFFSET", "0")
epicsEnvSet("TEMP_ELEC_SCALE", "1")
epicsEnvSet("TEMP_ELEC_OFFSET", "0")
epicsEnvSet("TEMP_TORO_SCALE", "$(ETHER_CAT_SCALE)")
epicsEnvSet("TEMP_TORO_OFFSET", "$(ETHER_CAT_OFFSET)")
epicsEnvSet("TEMP_AMP_SCALE", "$(ETHER_CAT_SCALE)")
epicsEnvSet("TEMP_AMP_OFFSET", "$(ETHER_CAT_OFFSET)")
epicsEnvSet("TEMP_BERGOZ_SCALE", "$(ETHER_CAT_SCALE)")
epicsEnvSet("TEMP_BERGOZ_OFFSET", "$(ETHER_CAT_OFFSET)")

cd $(TOP)

< iocBoot/common/bcmLCLS2Common.cmd

