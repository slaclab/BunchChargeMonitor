import sys
import time
import socket

from datetime import datetime
from epics import PV

import argparse

def process_args(argv):
     parser=argparse.ArgumentParser(description='This script sets the required conditions to recalibrate the bergoz chassis')
     parser.add_argument('AREA', help = 'Area in the tunnle i.e. GUNB, IN10 etc.')
     parser.add_argument('POS', help='location i.e 360, 491 etc.')
     parser.add_argument('IOC_UNIT', help='im01,im02 etc.')
     parser=parser.parse_args()
     
     return parser

def setCalibrationMode(prefix_info, log):
    sig_coefA0 = PV("TORO:{}:{}:0:CoefA0".format(prefix_info.AREA, prefix_info.POS))
    sig_coefA1 = PV("TORO:{}:{}:0:CoefA1".format(prefix_info.AREA, prefix_info.POS))

    response_coefA0 = PV("TORO:{}:{}:1:CoefA0".format(prefix_info.AREA, prefix_info.POS))
    response_coefA1 =PV("TORO:{}:{}:1:CoefA1".format(prefix_info.AREA, prefix_info.POS))
    
    coefA0_sav= sig_coefA0.get(timeout=None)
    coefA1_sav= sig_coefA1.get(timeout=None)
    
    log = log + "\nOriginal CoefA0 = " + str(coefA0_sav)
    log = log + "\nOriginal CoefA1 = " + str(coefA1_sav)
    
    sig_coefA0.put(1)
    sig_coefA1.put(-1)
    
    response_coefA0.put(-1)
    response_coefA1.put(1)
    return log

def calibrateFacet(prefix_info, log):
    #read in the calibration pulse and the toroid response
    signalChrg=PV("TORO:{}:{}:0:Calib_Charge".format(prefix_info.AREA, prefix_info.POS)).get(timeout=None)
    responseChrg=PV("TORO:{}:{}:1:Calib_Charge".format(prefix_info.AREA, prefix_info.POS)).get(timeout=None)
    
    #determine the response ratio
    toroRatio = signalChrg/(2*responseChrg)
    log = log + "\nInput Signal Charge = " + str(signalChrg)
    log = log + "\nToroid Responce Charge = " + str(responseChrg)
    log = log + "\nComputed Toroid Ratio = " + str(toroRatio)
    
    PV("TORO:{}:{}:0:Calib_ratio".format(prefix_info.AREA, prefix_info.POS)).put(toroRatio)
    
    coeficentMag=PV("TORO:{}:{}:0:Calib_Coef_Magnitude".format(prefix_info.AREA, prefix_info.POS)).get(timeout=None)
    
    log = log + "\nComputed Calibration Coeficent = " + str(coeficentMag) + "\n"
    
    return coeficentMag, log

def setCoeficents(prefix_info, magnitude, log):
    sig_coefA0_PV = PV("TORO:{}:{}:0:CoefA0".format(prefix_info.AREA, prefix_info.POS))
    sig_coefA1_PV = PV("TORO:{}:{}:0:CoefA1".format(prefix_info.AREA, prefix_info.POS))
    
    sig_coefA0_PV.put(magnitude)
    sig_coefA1_PV.put(magnitude)
    
    time.sleep(1)
    
    log = log + "\nSetting TORO:{}:{}:0:CoefA0 to {}".format(prefix_info.AREA, prefix_info.POS, sig_coefA0_PV.get(timeout=None))
    log = log + "\nSetting TORO:{}:{}:0:CoefA1 to {}\n".format(prefix_info.AREA, prefix_info.POS, sig_coefA1_PV.get(timeout=None))
    
    return log
    
def save_log(prefix_info,log):
    location = socket.gethostname()
    if location == 'lcls-dev3':
        file_path = "/nfs/slac/g/lcls/epics/ioc/data/sioc-b084-{}/calibration/".format(prefix_info.IOC_UNIT.lower())
    if location == 'facet-srv01':
        file_path = "/u1/facet/epics/ioc/data/sioc-{}-{}/calibration/".format(prefix_info.AREA.lower(), prefix_info.IOC_UNIT.lower())
    
    log_file = open(file_path + time.strftime("%Y-%m-%d_%H-%M-%S"), 'w')
    log_file.write(log)    
    
def main(argv):
    pv_data = process_args(argv)
    log_buffer = "TORO:{}:{} calibration log file {}\n".format(pv_data.AREA, pv_data.POS, 
        datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
    log_buffer = setCalibrationMode(pv_data, log_buffer)
    coefMag, log_buffer = calibrateFacet(pv_data, log_buffer)
    log_buffer = setCoeficents(pv_data, coefMag, log_buffer)
    
    print(log_buffer)
    save_log(pv_data, log_buffer)
    print("Log file saved to $IOC_DATA/sioc-{}-{}/calibration/".format(pv_data.AREA, pv_data.IOC_UNIT.lower()))

if __name__ == "__main__":
    main(sys.argv[1:])
