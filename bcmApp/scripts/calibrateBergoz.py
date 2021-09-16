#Autor          : Taine Eriksen
#Created        : 08/31/2021
#Description    : A converstion of the matlab calibration script from Leonid Sapozhnikov to provide functionality on the display

#utiliites
import sys
import os
import argparse

import epics as e

#data analysis
from scipy import stats
import numpy as np
import matplotlib.pyplot as plt

def process_args(argv):
     parser=argparse.ArgumentParser(description='This script will read the epics records from a bergoz calibraion, generate a log file and update the coeficents')
     parser.add_argument("-PV_Prefix", type=str, required=True, help='The prefix for this toroid i.e. TORO:GUNB:360')
     parser.add_argument("-Sample_Num", type=int, required=True, help='The number of datapoints that are configured in the epics database')
     parser=parser.parse_args()
     
     return parser


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
    
  
#function to compute the regresion

#function to set the existing PVs

def main(argv):
    controls = process_args(argv)
    voltage_data = read_voltage_data(controls.PV_Prefix, controls.Sample_Num, "voltage")
    adc_data = read_adc_data(controls.PV_Prefix, controls.Sample_Num, "adc")

    print(voltage_data)
    print(adc_data)

if __name__ == "__main__":
    main(sys.argv[1:])
