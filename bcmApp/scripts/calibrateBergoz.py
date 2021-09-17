#Autor          : Taine Eriksen
#Created        : 08/31/2021
#Description    : A converstion of the matlab calibration script from Leonid Sapozhnikov to provide functionality on the display

#utiliites
import sys
import os
import argparse
import datetime

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
     
def query_yes_no(question, bypass=False):

    valid = {"yes": True, "y": True, "no": False, "n": False}
    prompt = " [y/n] "

    while True:
        sys.stdout.write(question + prompt)
        if(bypass):
            sys.stdout.write('\n')
            return True
        choice = input().lower()
        if choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' " "(or 'y' or 'n').\n")


#function to read pv's
def read_voltage_data(prefix, dataPoints, dataType):
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


def read_adc_data(prefix, dataPoints, dataType):
    if(dataType == "adc"):
        postfix = "ADC_COUNT"
    elif(dataType == "voltage"):
        postfix = "DMM_READING"
    else:
        raise NameError
    data = []
    for i in range(dataPoints):
        data_point = e.caget(prefix+":"+postfix+str(i+1))
        data.append(data_point[-1])
        
    return np.array(data, dtype=float)

def cable_convert(raw_cable_coef):
    return 10**(raw_cable_coef/20)

#function to set the existing PVs

def main(argv):
    controls = process_args(argv)
    voltage_data = read_voltage_data(controls.PV_Prefix, controls.Sample_Num, "voltage")
    adc_data = read_adc_data(controls.PV_Prefix, controls.Sample_Num, "adc")
    
    log_str=""
    
    #gunb data
    #voltage_data = np.array([-4.511, -2.519, 0 , 2.52, 4.513])
    #adc_data = np.array([56694, 45994, 32441, 18860, 8128, ])
    
    #sph data
    #voltage_data = np.array([-4.98, -2.995, -0.99 , 0, 0.99, 2.995, 4.98])
    #adc_data = np.array([0xe490, 0xbb38, 0x9158, 0x7cb0, 0x6800, 0x3e27, 0x14b0])
    
    
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
    input("test")
    if(query_yes_no("Would you like to set A0 and LnQCal to these values?")):
        e.caput(prefix+":0:CoefA0", A0)
        e.caput(prefix+":CoefLnQ", LnQCal)
    
    checkoutFile = open(os.path.join("$IOC_DATA", controls.IOC, "/calibration/", "Bergoz_"+str(BergozSN)+"_"+datetime.now().strftime("%d-%m-%Y--%H:%M:%S")), 'w')
    checkoutFile.write(logInfo)
    print("A log file has been written to $IOC_DATA/"+controls.IOC+"/calibration")
    print("This concludes the calibration")
    


if __name__ == "__main__":
    main(sys.argv[1:])
