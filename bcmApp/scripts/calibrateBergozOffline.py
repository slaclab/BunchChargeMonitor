#Autor          : Taine Eriksen
#Created        : 08/31/2021
#Description    : A converstion of the matlab calibration script from Leonid Sapozhnikov to provide functionality on the display

#utiliites
import sys
import os
import argparse
from datetime import datetime
import socket

import epics as e

#data analysis
from scipy import stats
import numpy as np
import matplotlib.pyplot as plt

def process_args(argv):
     parser=argparse.ArgumentParser(description='This script will read the epics records from a bergoz calibraion, generate a log file and update the coeficents')
     parser.add_argument("-PV_Prefix", type=str, required=True, help='The prefix for this toroid i.e. TORO:GUNB:360')
     parser.add_argument("-Sample_Num", type=int, required=True, help='The number of datapoints that are configured in the epics database')
     parser.add_argument("-IOC", type=str, required=True, help="The IOC name")
     parser=parser.parse_args()
     
     return parser


#function to read pv's
def read_data(prefix, dataPoints, dataType):
    if(dataType == "adc"):
        postfix = "ADC_COUNT"
    elif(dataType == "voltage"):
        postfix = "DMM_READING"
    else:
        raise NameError
    data = []
    for i in range(dataPoints):
        data_point = e.caget(prefix+":"+postfix+str(i+1))
        data.append(data_point)
        
    return np.array(data, dtype=float)  

def cable_convert(raw_cable_coef):
    return 10**(raw_cable_coef/20)

#function to set the existing PVs

def main(argv):
    controls = process_args(argv)
    voltage_data = read_data(controls.PV_Prefix, controls.Sample_Num, "voltage")
    adc_data = read_data(controls.PV_Prefix, controls.Sample_Num, "adc")
    
    log_str=""

    #spd 
    voltage_data = [-4.496, -3.002, -0.993, 0., 0.992, 3.003, 4.499]
    adc_data = [56236.12, 49944.69, 37550.46, 32258., 26966.8, 16232.37, 8261.65]
    
    #sps
    #voltage_data = [-4.6435, -3.042, -1.031, 0., 1.034, 3.041, 4.535]
    #adc_data = [56895.52, 48424.18, 37744.14, 32264.4,  26783.78, 16090.3, 8166.92]

    #sph 
    #voltage_data = [-4.533, -3.037, -1.029,  0., 1.03, 3.034, 4.531]
    #adc_data = [56174.55, 48183.04, 37438.28, 31931.47, 26409.95, 15658.7, 7684.77]

    log_str += "Voltage Readings = "+str(voltage_data)+"\n"
    log_str += "ADC Readings = "+str(adc_data)+"\n"
    
    #plt.scatter(adc_data, voltage_data)
    
    #Bergoz serial Number
    BergozSN = e.caget(controls.PV_Prefix+":SERIALNUM_RD")
    #AMC serial number
    AmcSN = e.caget(controls.PV_Prefix+":AMC_SN")
    #Conditioning Board serial number
    CbSN = e.caget(controls.PV_Prefix+":CON_BOARD_SN")
    #bergoz calibration value ucal
    Ucal = e.caget(controls.PV_Prefix+":UCAL")
    #bergoz calibration ccal
    Qcal = e.caget(controls.PV_Prefix+":QCAL")
    #cable attenuation when bergoz tested it
    Closs_raw = e.caget(controls.PV_Prefix+":BergozCableAttenuation")
    #our measured cable attuniation
    Uloss_raw = e.caget(controls.PV_Prefix+":ActualCableAttenuation")
    
    Closs = cable_convert(float(Closs_raw))
    Uloss = cable_convert(float(Uloss_raw))

    slope, intercept, r_value, p_value, std_err = stats.linregress(adc_data, voltage_data)
    
    log_str += "Fitted Slope = "+str(slope) +"\n"
    log_str += "Fitted Intercept = "+str(intercept) +"\n"
    log_str += "R^2 value = "+str(r_value**2) +"\n"
    
    A0 =  np.log(10)*slope/float(Ucal)
    LnQCal = np.log(float(Qcal)*(float(Uloss)/float(Closs))) + np.log(10)*intercept/float(Ucal)

    log_str += "Calculated A0 = "+str(A0) +"\n"
    log_str += "Calculated LnQCal = "+str(LnQCal) +"\n"
    
    print(log_str)
    print("If you would like to update the coeficents please use the coeficents screen")
    
    host = socket.gethostname()
    
    if(host == 'lcls-dev3'):
        iocData = "/nfs/slac/g/lcls/epics/ioc/data/"
    else:
        iocData = "/u1/lcls/epics/ioc/data/"
    
    checkoutFile = open(iocData+ controls.IOC+ "/calibration/"+ "Bergoz"+str(BergozSN)+"_"+datetime.now().strftime("%d-%m-%Y__%H--%M--%S"), 'w')
    checkoutFile.write(log_str)
    print("A log file has been written to $IOC_DATA/"+controls.IOC+"/calibration")
    print("This concludes the calibration")
    


if __name__ == "__main__":
    main(sys.argv[1:])
