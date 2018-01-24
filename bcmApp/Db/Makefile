TOP=../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

#----------------------------------------------------
#  Optimization of db files using dbst (DEFAULT: NO)
#DB_OPT = YES

#----------------------------------------------------
# Create and install (or just install)
# databases, templates, substitutions like this

# ATCA
## For automatic generated records
DB_INSTALLS += $(YCPSWASYN)/db/ai.template
DB_INSTALLS += $(YCPSWASYN)/db/ao.template
DB_INSTALLS += $(YCPSWASYN)/db/longin.template
DB_INSTALLS += $(YCPSWASYN)/db/longout.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_in.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_out.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_8_in.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_8_out.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_in_float.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_out_float.template
DB_INSTALLS += $(YCPSWASYN)/db/mbbi.template
DB_INSTALLS += $(YCPSWASYN)/db/mbbo.template
DB_INSTALLS += $(YCPSWASYN)/db/bo.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_stream16.template
DB_INSTALLS += $(YCPSWASYN)/db/waveform_stream32.template

# Keithley
DB_INSTALLS += $(KEITHLEY6482)/db/asynRecord.db
DB_INSTALLS += $(KEITHLEY6482)/db/devKeithley6482.db
DB_INSTALLS += $(KEITHLEY6482)/db/devKeithley6482.proto
DB_INSTALLS += $(KEITHLEY6482)/db/zeroCorrect.db

# Bergoz
DB_INSTALLS += $(BERGOZBCM_RF_ASYN)/db/asynRecord.db
DB_INSTALLS += $(BERGOZBCM_RF_ASYN)/db/devBergozBCM.db
DB_INSTALLS += $(BERGOZBCM_RF_ASYN)/db/devBergozBCM.proto

# Temperature Chassis
DB_INSTALLS += $(ECASYN)/db/EK1101.template
DB_INSTALLS += $(ECASYN)/db/EL3202-0010.template

# BSA
DB_INSTALLS += $(BSADRIVER)/db/bsa.db

# User-defined functions
DB += stream_size.template
DB += TempMonitoring_TORO.db
DB += Filter.db
DB += bcm.db
DB += carrier.db
DB += ipAddr.db

# For byte swapping
DB += swap.db

# ========================================
# Install timing/event related databases
# ========================================
#DB_INSTALLS += $(EVENT)/db/EvrPmc.db
#DB_INSTALLS += $(EVENT)/db/EvrPci.db
#DB_INSTALLS += $(EVENT)/db/Pattern.db
#DB_INSTALLS += $(EVENT)/db/PCI-trig.db
#DB_INSTALLS += $(EVENT)/db/PMC-trig.db
#DB_INSTALLS += $(EVENT)/db/VME-trig.db
#DB_INSTALLS += $(EVENT)/db/VME-TTB-trig.db
#DB_INSTALLS += $(EVENT)/db/Bsa.db
#
# For event module BSA Test
#DB += bsaSimulator.db

# For temperature transfer
DB += xfer.db

# For statistics
DB += acalcStats.db

# For saving and loading yaml configuration
DB += saveLoadConfig.db

# For automatic initialization (requires saveLoadConfig.db)
DB += monitorFPGAReboot.db

# For manually created record
DB += RegisterIn.template
DB += RegisterOut.template
DB += RegisterOutRBV.template
DB += RegisterArrayChar.template
DB += RegisterArrayIn.template
DB += RegisterArrayOut.template
DB += RegisterEnumBIn.template
DB += RegisterEnumMBBIn.template
DB += RegisterEnumBOut.template
DB += RegisterEnumBOutRBV.template
DB += RegisterEnumMBBOut.template
DB += RegisterEnumMBBOutRBV.template
DB += RegisterDoubleIn.template
DB += RegisterDoubleOut.template
DB += RegisterDoubleOutRBV.template
DB += RegisterCommand.template
DB += RegisterStream.template
DB += RegisterStream16.template
DB += RegisterDoubleInLimits.template

# Install Common databases needed by All IOCs
# ========================================================
# Install databases from iocAdmin package
# These databases support IOC Health and Monitoring
# ========================================================
# HardIOC using RTEMS
#DB_INSTALLS += $(IOCADMIN)/db/iocAdminRTEMS.db
# SoftIOC
DB_INSTALLS += $(IOCADMIN)/db/iocAdminSoft.db

DB_INSTALLS += $(IOCADMIN)/db/iocAdminScanMon.db
DB_INSTALLS += $(IOCADMIN)/db/iocScanMonSum.db
DB_INSTALLS += $(IOCADMIN)/db/iocScanMon.db
IOCRELEASE_DB += iocRelease.db

# Install Database to support reading the status of the autosave package:
DB_INSTALLS += $(AUTOSAVE)/db/save_restoreStatus.db

# =======================================================================

#----------------------------------------------------
# If <anyname>.db template is not named <anyname>*.template add
# <anyname>_TEMPLATE = <templatename>

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

