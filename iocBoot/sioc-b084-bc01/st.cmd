#!../../bin/linuxRT-x86_64/bcm

## You may have to change bcm to something else
## everywhere it appears in this file

< envPaths

# ===========================================
#            ENVIRONMENT VARIABLES
# ===========================================

# Area, to be used in record names
epicsEnvSet("AREA", "IN20")

# FPGA IP address for CPSW
epicsEnvSet("FPGA_IP", "10.0.1.102")

# IOC name for IOC admin
epicsEnvSet(IOC_NAME,"SIOC:${AREA}:IM01")

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

# Raw streams for each bunch charge
dbLoadRecords("db/stream.db", "AREA=${AREA}, POS=215:, PORT=cpsw, AMC=0, CHN=0")
dbLoadRecords("db/stream.db", "AREA=${AREA}, POS=431:, PORT=cpsw, AMC=0, CHN=1")
dbLoadRecords("db/stream.db", "AREA=${AREA}, POS=791:, PORT=cpsw, AMC=0, CHN=2")
dbLoadRecords("db/stream.db", "AREA=${AREA}, POS=971:, PORT=cpsw, AMC=1, CHN=0")
# Calculated waveforms to work with weight function. Each ADC has its own
# position definition, AMC card number, and channel inside AMC.
dbLoadRecords("db/calculatedWF.db", "AREA=${AREA}, POS=215")
dbLoadRecords("db/calculatedWF.db", "AREA=${AREA}, POS=431")
dbLoadRecords("db/calculatedWF.db", "AREA=${AREA}, POS=791")
dbLoadRecords("db/calculatedWF.db", "AREA=${AREA}, POS=971")
dbLoadRecords("db/weightFunction.db", "AREA=${AREA}, POS=215:, PORT=cpsw, AMC=0, CHN=0")
dbLoadRecords("db/weightFunction.db", "AREA=${AREA}, POS=431:, PORT=cpsw, AMC=0, CHN=1")
dbLoadRecords("db/weightFunction.db", "AREA=${AREA}, POS=791:, PORT=cpsw, AMC=0, CHN=2")
dbLoadRecords("db/weightFunction.db", "AREA=${AREA}, POS=971:, PORT=cpsw, AMC=1, CHN=0")
# Database to transform between ticks of samples to time of sample for X axis
# of the weight function. Each ADC has its position. INST=A corresponds to AMC0
# while INST=B corresponds do AMC1.
dbLoadRecords("db/weightFunctionXAxis.db", "AREA=${AREA}, POS=215, INST=A")
dbLoadRecords("db/weightFunctionXAxis.db", "AREA=${AREA}, POS=431, INST=A")
dbLoadRecords("db/weightFunctionXAxis.db", "AREA=${AREA}, POS=791, INST=A")
dbLoadRecords("db/weightFunctionXAxis.db", "AREA=${AREA}, POS=971, INST=B")

# BSA. Configure the PV name for BSA, the AMC number and the ADC number
# inside the AMC. Numbers start from zero.
# bcmBsaConfigure <PV name> <AMC number> <ADC number>
dbLoadRecords("db/Bsa.db", "DEVICE=${PREFIX}:215,ATRB=TMIT")
bcmBsaConfigure "${PREFIX}:215:TMIT" 1 0
dbLoadRecords("db/Bsa.db", "DEVICE=${PREFIX}:431,ATRB=TMIT")
bcmBsaConfigure "${PREFIX}:431:TMIT" 0 0
dbLoadRecords("db/Bsa.db", "DEVICE=${PREFIX}:791,ATRB=TMIT")
bcmBsaConfigure "${PREFIX}:791:TMIT" 0 1
dbLoadRecords("db/Bsa.db", "DEVICE=${PREFIX}:971,ATRB=TMIT")
bcmBsaConfigure "${PREFIX}:971:TMIT" 0 2

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
dbpf ${PREFIX}:-A0AutoRearm 1
dbpf ${PREFIX}:TCORE:MODE LCLS1
dbpf ${PREFIX}:CHN0:EVENTCODE 40
dbpf ${PREFIX}:CHN0:LCLS1ENABLE Enabled
dbpf ${PREFIX}:CHN1:EVENTCODE 40
dbpf ${PREFIX}:CHN1:LCLS1ENABLE Enabled
dbpf ${PREFIX}:TRG8:LCLS1DELAY 542
dbpf ${PREFIX}:TRG8:SOURCE "Channel 0"
dbpf ${PREFIX}:TRG7:SOURCE "Channel 0"
dbpf ${PREFIX}:TRG1:SOURCE "Channel 0"
dbpf ${PREFIX}:TRGA:SOURCE "Channel 0"
dbpf ${PREFIX}:TRGB:SOURCE "Channel 0"
dbpf ${PREFIX}:TRGC:SOURCE "Channel 0"
dbpf ${PREFIX}:TRGD:SOURCE "Channel 0"
dbpf ${PREFIX}:TRG7:LCLS1WIDTH 0
dbpf ${PREFIX}:TRG8:LCLS1WIDTH 0
dbpf ${PREFIX}:TRG1:LCLS1WIDTH 0
dbpf ${PREFIX}:TRGA:LCLS1WIDTH 0
dbpf ${PREFIX}:TRGB:LCLS1WIDTH 0
dbpf ${PREFIX}:TRGC:LCLS1WIDTH 0
dbpf ${PREFIX}:TRGD:LCLS1WIDTH 0
dbpf ${PREFIX}:TRG8:LCLS1ENABLE Enabled
dbpf ${PREFIX}:TRG7:LCLS1ENABLE Enabled
dbpf ${PREFIX}:TRG1:LCLS1ENABLE Enabled
dbpf ${PREFIX}:TRGA:LCLS1ENABLE Enabled
dbpf ${PREFIX}:TRGB:LCLS1ENABLE Enabled
dbpf ${PREFIX}:TRGC:LCLS1ENABLE Enabled
dbpf ${PREFIX}:TRGD:LCLS1ENABLE Enabled
dbpf ${PREFIX}:TRG6:SOURCE "Channel 1"
dbpf ${PREFIX}:TRG6:LCLS1WIDTH 0
dbpf ${PREFIX}:TRG6:LCLS1ENABLE Enabled
#dbpf ${PREFIX}:AutoRearm 1
dbpf ${PREFIX}:AutoRearm 1
dbpf ${PREFIX}:SOFTEVSEL0_EVENTCODE 40
dbpf ${PREFIX}:SOFTEVSEL0_ENABLE Enabled

bcmConfigure "MrBcmBsaStream"
