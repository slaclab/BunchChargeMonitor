TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#========================================

#=====================================================
# Path to "NON EPICS" External PACKAGES: USER INCLUDES
#======================================================
# Support for CPSW
USR_INCLUDES = -I$(BOOST_INCLUDE) -I$(CPSW_FRAMEWORK_INCLUDE) -I$(YAML_INCLUDE) -I$(L2MPS_INCLUDE)
USR_INCLUDES += -I$(CPSW_DEVICE_LIBRARY_INCLUDE)
USR_INCLUDES += -I$(YAMLREADER_INCLUDE)
USR_INCLUDES += -I$(COMMONATCA_INCLUDE)
USR_INCLUDES += -I$(HPSTPR_INCLUDE)
USR_INCLUDES += -I$(BSA_INCLUDE)
#=====================================================

# Support needed for ethercat
USR_INCLUDES += -I$(ZLIB_INCLUDE)
USR_INCLUDES += -I$(XZ_INCLUDE)
USR_INCLUDES += -I$(LIBXML2_INCLUDE)

# Support Perl C regular expression library
USR_INCLUDES += -I$(PCRE_INCLUDE)



#======================================================
# PATH TO "NON EPICS" EXTERNAL PACKAGES: USER LIBRARIES
#======================================================
z_DIR             = $(ZLIB_LIB)
lzma_DIR          = $(XZ_LIB)
xml2_DIR          = $(LIBXML2_LIB)

pcre_DIR          = $(PCRE_LIB)
l2Mps_DIR         = $(L2MPS_LIB)

# Support for CPSW
cpsw_DIR          = $(CPSW_FRAMEWORK_LIB)
deviceLib_DIR     = $(CPSW_DEVICE_LIBRARY_LIB)
boost_system_DIR  = $(BOOST_LIB)
yaml-cpp_DIR      = $(YAML_LIB)
hpstpr_DIR        = $(HPSTPR_LIB)
yamlReader_DIR    = $(YAMLREADER_LIB)
commonATCA_DIR    = $(COMMONATCA_LIB)
bsa_DIR           = $(BSA_LIB)

# =====================================================

# ======================================================
# LINK "NON EPICS" EXTERNAL PACKAGE LIBRARIES STATICALLY
#=======================================================
USR_LIBS_Linux += yamlReader
USR_LIBS_Linux += deviceLib
USR_LIBS_Linux += cpsw
USR_LIBS_Linux += yaml-cpp
USR_LIBS_Linux += boost_system
USR_LIBS_Linux += hpstpr
USR_LIBS_Linux += l2Mps
USR_LIBS_Linux += commonATCA
USR_LIBS_Linux += bsa 
USR_LIBS_Linux += xml2 
USR_LIBS_Linux += z 
USR_LIBS_Linux += lzma 
USR_LIBS_Linux += pcre

#======================================================

# ================================================
# Build the IOC application
# ================================================
# This will attempt to build an IOC application 
# for every target including the host computer.
# These lines will build ONLY for cross target
PROD_IOC_linuxRT-x86_64 = bcm
PROD_IOC = $(PROD_IOC_$(T_A))

# Ethercat for temperature chassis
bcm_INCLUDES += $(ECASYN)/include
bcm_DBD += ecAsyn.dbd

# bcm.dbd will be created and installed
DBD += bcm.dbd

# bcm.dbd will be made up from these files:
bcm_DBD += bcmDrv.dbd
bcm_DBD += base.dbd
bcm_DBD += devIocStats.dbd
bcm_DBD += asSupport.dbd
# Include dbd files from all support applications:
bcm_DBD += asyn.dbd
bcm_DBD += drvAsynIPPort.dbd
bcm_DBD += drvAsynSerialPort.dbd
bcm_DBD += caPutLog.dbd
bcm_DBD += $(CEXP_DBDS)
bcm_DBD += pvxsIoc.dbd
blen_DBD += crossbarControl.dbd
blen_DBD += tprTriggerAsynDriver.dbd
blen_DBD += tprPatternAsynDriver.dbd

#bcm_DBD += Keithley6482Test.dbd
ifdef AUTOSAVE_ASSUPPORT
bcm_DBD += asSupport.dbd
else
bcm_DBD += asSupport.dbd
endif
bcm_DBD += bcmSupport.dbd

# caf: aCalcout record support
bcm_DBD += sscanSupport.dbd
bcm_DBD += calcSupport.dbd

bcm_DBD += ycpswasyn.dbd
bcm_DBD += bsaAsynDriver.dbd
bcm_DBD += yamlLoader.dbd
bcm_DBD += yamlDownloader.dbd
bcm_DBD += l2MpsAsyn.dbd
bcm_DBD += stream.dbd

# For calculated waveforms
bcm_DBD += calc.dbd

# Ethercat
bcm_DBD += ecAsyn.dbd

# DBD file for tprTrigger
bcm_DBD += tprTriggerAsynDriver.dbd

# DBD file for tprPattern
bcm_DBD += tprPatternAsynDriver.dbd

# needed for ioc Admin support
#The db changed name when moved to version R3.1.15-1.1.0 from  bcm_DBD += iocAdmin.dbd
bcm_DBD += devIocStats.dbd

# ================================================================================
# The system command will be mainly used by linux hosted IOCs
# Very useful for changing kernel thread priorities for kernel drivers
# ================================================================================
bcm_DBD += system.dbd

# ======================================================================
# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
bcm_SRCS += bcm_registerRecordDeviceDriver.cpp

bcm_SRCS_DEFAULT += bcmMain.cpp

bcm_SRCS_vxWorks += -nil-

# ========================================================================
# ========================================================================
# Add locally compiled object code
# For example, subroutines
# ========================================================================
# bcm_SRCS += file1.c
# bcm_SRCS += file2.c
bcm_SRCS += DaqSizeSub.c
#bcm_SRCS += bcmBSA.cpp
#bcm_SRCS += bcmIOCFunctions.cpp
#bcm_SRCS += cpswStreamBSA.cpp
bcm_SRCS += asubWeightXAxis.c
bcm_SRCS += asubRWF.c

# =====================================================
# Link in the libraries from other EPICS modules
# =====================================================
bcm_LIBS += l2MpsAsyn
bcm_LIBS += stream

bcm_LIBS += calc
bcm_LIBS += sscan

# Ethercat (Order of libraries listed is important gor the Gnu Linker)
bcm_LIBS += ecAsyn
bcm_LIBS += scannerlib
bcm_LIBS += rtutils

# Needed to link bsaDriver support
bcm_LIBS += bsaDriver
bsa_DIR = $(BSA_LIB)
bcm_LIBS += bsa

# Library for tprPattern
bcm_LIBS += tprPattern

# Library for tprTrigger
bcm_LIBS += tprTrigger

bcm_LIBS += yamlDownloader
bcm_LIBS += yamlLoader
bcm_LIBS += ycpswasyn

# Needed to link in iocAdmin support
bcm_LIBS += devIocStats
# Needed to link in autosave support
bcm_LIBS += autosave

# Needed to link caPutLog support
bcm_LIBS += caPutLog
bcm_LIBS += seq pv

bcm_LIBS += pvxsIoc
bcm_LIBS += pvxs

# Needed to link cexpsh() support
bcm_LIBS += $(CEXP_LIBS)
bcm_SYS_LIBS += $(CEXP_SYS_LIBS)

# Link Asyn library support.
# Should be last for othe modules that depend on asyn
bcm_LIBS += asyn

# API for tprPattern
hpstpr_DIR = $(HPSTPR_LIB)

# =====================================================================


# ======================================================
# Link libraries from EPICS BASE
# =====================================================
bcm_LIBS += $(EPICS_BASE_IOC_LIBS)

# ==================================================
# Install external epics executable
# Install scanner program from Ethercat epics module
#===================================================
BIN_INSTALLS += $(ECASYN_BIN)/scanner


#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

