#!../../bin/linuxRT-x86_64/bcm

## You may have to change bcm to something else
## everywhere it appears in this file

< envPaths

# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# Area, to be used in record names
epicsEnvSet("AREA", "LI24")

# IOC_UNIT, to be used in record names
epicsEnvSet("IOC_UNIT", "IM01")

# IOC_AREA: some records are related to carriers and AMC cards that provide
# features for more than one actual area. This variable is the area that is
# in the name of the IOC.
epicsEnvSet("IOC_AREA", "LI24")

# FPGA IP address for CPSW
epicsEnvSet("FPGA_IP", "10.24.1.104")

cd ${TOP}

< iocBoot/common/bcmCommon.cmd

# ===========================================
#               ASYN MASKS
# ===========================================

# ***********************************
# * Asyn Masks for all Asyn drivers *

#asynSetTraceMask(cpsw, -1, 9)
#asynSetTraceMask(crossbar, -1, 9)
#asynSetTraceMask(trig, -1, 9)
#asynSetTraceMask(pattern, -1, 9)

# ===========================================
#               DB LOADING
# ===========================================

# Individual ADC features
dbLoadRecords("db/adc.db", "AREA=LI24, POS=708, PORT=cpsw, AMC=0, CHN=0")
dbLoadRecords("db/adc.db", "AREA=LI25, POS=236, PORT=cpsw, AMC=0, CHN=1")

# Raw streams for each bunch charge (one per ADC)
dbLoadRecords("db/stream.db", "AREA=LI24, POS=708, PORT=cpsw, AMC=0, CHN=0")
dbLoadRecords("db/stream.db", "AREA=LI25, POS=236, PORT=cpsw, AMC=0, CHN=1")

# Calculated waveforms to work with weight function. Each ADC has its own
# position definition, AMC card number, and channel inside AMC.
dbLoadRecords("db/calculatedWF.db", "P=TORO:LI24:708")
dbLoadRecords("db/calculatedWF.db", "P=TORO:LI25:236")
dbLoadRecords("db/autoAdjustCoef.db", "P=TORO:LI24:708")
dbLoadRecords("db/autoAdjustCoef.db", "P=TORO:LI25:236")
dbLoadRecords("db/weightFunction.db", "AREA=LI24, POS=708, PORT=cpsw, AMC=0, CHN=0")
dbLoadRecords("db/weightFunction.db", "AREA=LI25, POS=236, PORT=cpsw, AMC=0, CHN=1")
dbLoadRecords("db/processRawWFHeader.db", "AREA=LI24, POS=708, PORT=cpsw, AMC=0, CHN=0")
dbLoadRecords("db/processRawWFHeader.db", "AREA=LI25, POS=236, PORT=cpsw, AMC=0, CHN=1")

# Database to transform between ticks of samples to time of sample for X axis
# of the weight function. Each ADC has its position. INST=A corresponds to AMC0
# while INST=B corresponds do AMC1.
dbLoadRecords("db/weightFunctionXAxis.db", "AREA=LI24,POS=708,INST=A,IOC_UNIT=${IOC_UNIT},IOC_AREA=${IOC_AREA}")
dbLoadRecords("db/weightFunctionXAxis.db", "AREA=LI25,POS=236,INST=A,IOC_UNIT=${IOC_UNIT},IOC_AREA=${IOC_AREA}")

# BSA. Configure the PV name for BSA, the AMC number and the ADC number
# inside the AMC. Numbers start from zero.
# bcmBsaConfigure <PV name> <AMC number> <ADC number>
dbLoadRecords("db/Bsa.db", "DEVICE=TORO:LI24:708,ATRB=TMIT,SINK_SIZE=1")
bcmBsaConfigure "TORO:LI24:708:TMIT" 0 0
dbLoadRecords("db/Bsa.db", "DEVICE=TORO:LI25:236,ATRB=TMIT,SINK_SIZE=1")
bcmBsaConfigure "TORO:LI25:236:TMIT" 0 1

# ===========================================
#           SETUP AUTOSAVE/RESTORE
# ===========================================

# ===========================================
#               IOC INIT
# ===========================================
iocInit()

crossbarControl "FPGA" "BP"

# Turn on caPutLogging:
# Log values only on change to the iocLogServer:
caPutLogInit("${EPICS_CA_PUT_LOG_ADDR}")
caPutLogShow(2)

# This is just for test purposes. Must be deleted before first release.
#dbpf ${PREFIX}:A_AutoRearm 1

bcmConfigure "MrBcmBsaStream"

< iocBoot/common/start_restore_soft.cmd
