TOP=../..
include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

#----------------------------------------------------
#  Optimization of db files using dbst (DEFAULT: NO)
#DB_OPT = YES
REQ += facet2.req
REQ += lcls2toro.req
REQ += lcls2farc.req
REQ += kiethly.req

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

## For manually created record
DB_INSTALLS += $(YCPSWASYN)/db/RegisterIn.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterOut.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterOutRBV.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterArrayChar.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterArrayIn.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterArrayOut.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterEnumBIn.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterEnumMBBIn.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterEnumBOut.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterEnumBOutRBV.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterEnumMBBOut.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterEnumMBBOutRBV.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterDoubleIn.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterDoubleOut.template
#DB_INSTALLS += $(YCPSWASYN)/db/RegisterDoubleOutRBV.template
DB += RegisterDoubleOutRBV.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterCommand.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterStream.template
DB_INSTALLS += $(YCPSWASYN)/db/RegisterStream16.template
DB_INSTALLS += $(YCPSWASYN)/db/example.substitutions

# Timing (tprTrigger, tprPatter, crossbarControl, event, BSA, BSSS scalr PVs and controls) 
# --------------------------------------------------
DB_INSTALLS += $(TPRTRIGGER)/db/tprTrig.db
DB_INSTALLS += $(TPRTRIGGER)/db/tprDeviceNamePV.db

DB_INSTALLS += $(BSADRIVER)/db/bsa.db

DB_INSTALLS += $(BSADRIVER)/db/bsss.db
DB_INSTALLS += $(BSADRIVER)/db/bsssCtrl.db
DB_INSTALLS += $(BSADRIVER)/db/bsas.db
DB_INSTALLS += $(BSADRIVER)/db/bsasCtrl.db

DB_INSTALLS += $(EVENT)/db/bsaATTREdef_FACET.db

# Keithley
DB_INSTALLS += $(KEITHLEY6482)/db/asynRecord.db
DB_INSTALLS += $(KEITHLEY6482)/db/devKeithley6482.db
DB_INSTALLS += $(KEITHLEY6482)/db/devKeithley6482.proto
DB_INSTALLS += $(KEITHLEY6482)/db/zeroCorrect.db

# Bergoz
DB_INSTALLS += $(BERGOZBCM_RF_ASYN)/db/devBergozBCM.db
DB_INSTALLS += $(BERGOZBCM_RF_ASYN)/db/devBergozBCM.proto

# Temperature Chassis
DB_INSTALLS += $(ECASYN)/db/EK1101.template
DB_INSTALLS += $(ECASYN)/db/EL3202-0010.template

# Autosave
DB_INSTALLS += $(AUTOSAVE)/db/save_restoreStatus.db

# MPS
DB_INSTALLS += $(L2MPSASYN)/db/mps.db
DB_INSTALLS += $(L2MPSASYN)/db/mps_bcm.db
DB_INSTALLS += $(L2MPSASYN)/db/mps_scale_factor.db

# IOC Admin
DB_INSTALLS += $(IOCADMIN)/db/iocAdminSoft.db
DB_INSTALLS += $(IOCADMIN)/db/iocAdminScanMon.db   
IOCRELEASE_DB += iocRelease.db

# User-defined functions
DB += stream_size.template
DB += Filter.db
DB += bcmFACET2amc.db
DB += bcmFACET2chan.db
DB += bcmAmc.db
DB += bcmChan.db
DB += bcmLCLS2amc.db
DB += bcmLCLS2chan.db
DB += carrierLCLS2.db
DB += carrierFACET2.db
DB += ipAddr.db
DB += ipAddrParse.db
DB += streamControl.db
DB += waveform.db
DB += iocMeta.db
DB += fc_calc.db
DB += weightFunctionXAxis.db
DB += calculatedWF.db
DB += processRawWFHeader.db
DB += tempMonitor.db
DB += facet2Calibration.db 
DB += lcls2BergozMode.db
DB += lcls2BergozCalibration.db
DB += lcls2BergozDataPoint.db
DB += lcls2BergozInfo.db
DB += coefScale.db
DB += coefficientScaling.db
DB += farady_cup_coef_calib.db
DB += faradyCupAvgShot.db
# For BCM specific diagnostics
DB += msgStatus.db
DB += bpmSelect.db
DB += selectStatus.db
DB += bpmBcmDiff.db
# For byte swapping
DB += swap.db
# For initialization processing
DB += initBCM.db

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
DB += tempProcess.db

# For statistics
DB += acalcStats.db

# For saving and loading yaml configuration
DB_INSTALLS += $(YCPSWASYN)/db/saveLoadConfig.db

# For automatic initialization (requires saveLoadConfig.db)
DB += monitorFPGAReboot.db

# Install Common databases needed by All IOCs
# ========================================================
# Install databases from iocAdmin package
# These databases support IOC Health and Monitoring
# ========================================================
# Install Database to support reading the status of the autosave package:
DB_INSTALLS += $(AUTOSAVE)/db/save_restoreStatus.db

# =======================================================================

#----------------------------------------------------
# If <anyname>.db template is not named <anyname>*.template add
# <anyname>_TEMPLATE = <templatename>

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

