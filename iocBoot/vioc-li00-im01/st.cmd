#!../../bin/linuxRT-x86_64/bcm

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

# PV prefix
epicsEnvSet("PREFIX","yamlIOC1")
epicsEnvSet("CPSW_PORT","Atca2")


# *****************************************************
# **** Environment variables for Toroid on  Bergoz ****

epicsEnvSet("P_BERGOZ","$(P=TORO:)")
epicsEnvSet("R","$(R=LI00:IM01:)")
epicsEnvSet("BERGOZ_PORT","$(PORT=L0)")
epicsEnvSet("BERGOZ_TTY","$(BERGOZ_TTY=/dev/ttyACM0)")
epicsEnvSet("SERIALNUM_EXPECT","$(SERIALNUM_EXPECT=40)")

# Temperature xfer: ESLO, EOFF
epicsEnvSet("ESLO","$(ESLO=0.01)")
epicsEnvSet("EOFF","$(EOFF=273.15)")


# ***********************************************************
# **** Environment variables for Faraday Cup on Keithley ****

epicsEnvSet("P_KEITHLEY","$(P=FARC:)")
#epicsEnvSet("R","LI0:BP01:")
epicsEnvSet("K6487_ADDRESS","$(K6487_ADDRESS=ts-b084-nw01:2110)")
epicsEnvSet("K6487_PROTOCOL","$(K6487_PROTOCOL=TCP)")
epicsEnvSet("STREAM_PROTOCOL_PATH","${TOP}/db")


# *******************************************************************
# **** Environment variables for Temperature Chassis on Ethercat ****

# System Location:
epicsEnvSet(FAC,"SYS0")
epicsEnvSet("LOCA","LI00")
epicsEnvSet("TEMP_IOC_NAME","TEMP:${LOCA}:IM01")


# *********************************************
# **** Environment variables for IOC Admin ****

epicsEnvSet(IOC_NAME,"VIOC:LI00:IM01")


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
cd ${TOP}/iocBoot/vioc-li00-im01
YCPSWASYNConfig("${CPSW_PORT}", "../../yaml/AmcCarrierSsrlEth2x_project.yaml/000TopLevel.yaml", "", "10.0.1.104", "${PREFIX}", 40)
cd ${TOP}

# *********************************
# **** Driver setup for Bergoz ****

# Set up ASYN ports
# drvAsynIPPortConfigure port ipInfo priority noAutoconnect noProcessEos
drvAsynSerialPortConfigure("$(BERGOZ_PORT)","$(BERGOZ_TTY)",0,0,0)


# ***********************************
# **** Driver setup for Keithley ****

# drvAsynIPPortConfigure port ipInfo priority noAutoconnect noProcessEos
drvAsynIPPortConfigure("L1","$(K6487_ADDRESS)",0,0,0)


# **********************************************************
# **** Driver setup for Temperature Chassis on Ethercat ****

# Init EtherCAT: To support Real Time fieldbus
# EtherCAT AsynDriver must be initialized in the IOC startup script before iocInit
# ecAsynInit("<unix_socket>", <max_message>)
# unix_socket = path to the unix socket created by the scanner
# max_message = maximum size of messages between scanner and ioc

#ecAsynInit("/tmp/sock1", 1000000)


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


# *********************************
# **** Asyn Masks for Keithley ****

#asynSetTraceIOMask("L1",-1,0x2)
#asynSetTraceMask("L1",-1,0x9)


# ===========================================
#               DB LOADING
# ===========================================

# ***************************
# **** Load YCPSWAsyn db ****

## Load record instances
dbLoadRecords("db/verifyDefaults.db", "P=${PREFIX}, KEY=3")


# ************************
# **** Load Bergoz db ****

dbLoadRecords("db/devBergozBCM.db" "P=$(P_BERGOZ),R=$(R),PORT=$(BERGOZ_PORT),A=-1")
dbLoadRecords("db/asynRecord.db" "P=$(P_BERGOZ),R=asyn,PORT=$(BERGOZ_PORT),ADDR=-1,OMAX=0,IMAX=0")
dbLoadRecords("db/TempMonitoring_TORO.db", "P=$(P_BERGOZ)$(R),ESLO=$(ESLO),EOFF=$(EOFF)")


# **************************
# **** Load Keithley db ****
dbLoadRecords ("db/devKeithley6487.db" "P=$(P_KEITHLEY),R=$(R),PORT=L1,A=-1,NELM=1000")
dbLoadRecords ("db/asynRecord.db" "P=$(P_KEITHLEY),R=$(R),PORT=L1,ADDR=-1,OMAX=0,IMAX=0")


# *****************************************************
# **** Load db for Temperature Chassis on Ethercat ****

# Load the database templates for the EtherCAT components
# dbLoadRecords("db/<template_name_for slave_module>, <pass_in_macros>)
dbLoadRecords("db/EK1101.template", "DEVICE=TEMP:LI00:,PORT=COUPLER0,SCAN=1 second")
dbLoadRecords("db/EL3202-0010.template", "DEVICE=TEMP:LI00,PORT=ANALOGINPUT,SCAN=1 second")


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


# ************************
# **** YCPSWAsyn dbpf ****

# This register gives timeout errors when it is read.
# For now let's not read it until this problem is fixed
# register path: /mmio/AmcCarrierSsrlRtmEth/AmcCarrierCore/Axi24LC64FT/MemoryArray
dbpf ${PREFIX}:C:A24LC64FT:MemoryArray:Rd.SCAN "Passive"


# *********************
# **** Bergoz dbpf ****

# Save the TTY device name
dbpf $(P_BERGOZ)$(R)TTY_RD $(BERGOZ_TTY)

# Save the expected BERGOZ serial number
dbpf $(P_BERGOZ)$(R)SERIALNUM_EXPECT $(SERIALNUM_EXPECT)

# ************************************************************
# **** System command for Temperature Chassis on Ethercat ****
# Setup Real-time priorities after iocInit for driver threads
system("/bin/su root -c `pwd`/rtPrioritySetup.cmd")
