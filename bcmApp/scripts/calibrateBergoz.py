import sys

from epics import PV

import argparse

def process_args(argv):
     parser=argparse.ArgumentParser(description='This script sets the required conditions to recalibrate the bergoz chassis')
     parser.add_argument('AREA', help = 'Area in the tunnle i.e. GUNB, IN10 etc.')
     parser.add_argument('POS', help='location i.e 360, 491 etc.')
     parser.add_argument('IOC_UNIT', help='which ioc in that location i.e. IM01,IM02 ect.')
     parser=parser.parse_args()
     
     return parser

def calibrateBergoz(prefix_info):
    #pv's needed
    trig0=PV("TPR:{}:{}:0:TRG00_SYS2_TCTL".format(prefix_info.AREA, prefix_info.IOC_UNIT))
    chan0=PV("TPR:{}:{}:0:CH00_SYS2_TCTL".format(prefix_info.AREA, prefix_info.IOC_UNIT))
    calib=PV("TPR:{}:{}:0:CH06_FIXEDRATE".format(prefix_info.AREA, prefix_info.IOC_UNIT))
    trig3=PV("TORO:{}:{}:TLR3:SelSrc".format(prefix_info.AREA, prefix_info.POS))
    trig4=PV("TORO:{}:{}:TLR4:SelSrc".format(prefix_info.AREA, prefix_info.POS))
    trig5=PV("TORO:{}:{}:TLR5:SelSrc".format(prefix_info.AREA, prefix_info.POS))
    trig7=PV("TORO:{}:{}:TLR7:SelSrc".format(prefix_info.AREA, prefix_info.POS))
    
    print("Setting Calibration Mode")
    
    trig0_sav = trig0.get()
    chan0_sav = chan0.get()
    calib_sav = calib.get()
    trig3_sav = trig3.get()
    trig4_sav = trig4.get()
    trig5_sav = trig5.get()
    trig7_sav = trig7.get()   
    
    #need to check when the ioc is back online that these are correctly getting gathered
    print(trig0_sav)
    print(chan0_sav)
    print(calib_sav)
    print(trig3_sav)
    print(trig4_sav)
    print(trig5_sav)
    print(trig7_sav)
    
    #check these are the correct possitions once the ioc is back online
    trig0.put(0)
    chan0.put(0)
    calib.put(1)
    trig3.put(2)
    trig4.put(2)
    trig5.put(2)
    trig7.put(2)
    
    print("Calibration Complete")
    
    
    print("Reseting to PV's to there Original Possition")
    
    trig0.put(trig0_sav)
    chan0.put(chan0_sav)
    calib.put(calib_sav)
    trig3.put(trig3_sav)
    trig4.put(trig4_sav)
    trig5.put(trig5_sav)
    trig7.put(trig7_sav)

def main(argv):
    pv_data = process_args(argv)
    calibrateBergoz(pv_data)

if __name__ == "__main__":
    main(sys.argv[1:])
