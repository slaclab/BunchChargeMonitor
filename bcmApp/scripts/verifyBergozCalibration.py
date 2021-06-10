import sys
import time

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
    trig0TCTL=PV("TPR:{}:{}:0:TRG00_SYS2_TCTL".format(prefix_info.AREA, prefix_info.IOC_UNIT))
    chan0TCTL=PV("TPR:{}:{}:0:CH00_SYS2_TCTL".format(prefix_info.AREA, prefix_info.IOC_UNIT))
    chan6Rate=PV("TPR:{}:{}:0:CH06_FIXEDRATE".format(prefix_info.AREA, prefix_info.IOC_UNIT))
    calibEnable=PV("TORO:{}:{}:CalibEnable".format(prefix_info.AREA, prefix_info.IOC_UNIT))
    trig3SelSrc=PV("TORO:{}:{}:TLR3:SelSrc".format(prefix_info.AREA, prefix_info.POS))
    trig4SelSrc=PV("TORO:{}:{}:TLR4:SelSrc".format(prefix_info.AREA, prefix_info.POS))
    trig5SelSrc=PV("TORO:{}:{}:TLR5:SelSrc".format(prefix_info.AREA, prefix_info.POS))
    trig7SelSrc=PV("TORO:{}:{}:TLR7:SelSrc".format(prefix_info.AREA, prefix_info.POS))
    
    print("Calibration Starting")
    
    trig0TCTL_sav = trig0TCTL.get()
    chan0TCTL_sav = chan0TCTL.get()
    chan6Rate_sav = chan6Rate.get()
    calibEnable_sav = calibEnable.get()
    trig3SelSrc_sav = trig3SelSrc.get()
    trig4SelSrc_sav = trig4SelSrc.get()
    trig5SelSrc_sav = trig5SelSrc.get()
    trig7SelSrc_sav = trig7SelSrc.get()   
    
    #need to check when the ioc is back online that these are correctly getting gathered
    #print(trig0TCTL_sav)
    #print(chan0TCTL_sav)
    #print(chan6Rate_sav)
    #print(calibEnable_sav)
    #print(trig3SelSrc_sav)
    #print(trig4SelSrc_sav)
    #print(trig5SelSrc_sav)
    #print(trig7SelSrc_sav)
    
    #check these are the correct possitions once the ioc is back online
    trig0TCTL.put(0,timeout=10.0)
    chan0TCTL.put(0,timeout=10.0)
    chan6Rate.put(6,timeout=10.0)
    calibEnable.put(1,timeout=10.0)
    trig3SelSrc.put(2,timeout=10.0)
    trig4SelSrc.put(2,timeout=10.0)
    trig5SelSrc.put(2,timeout=10.0)
    trig7SelSrc.put(2,timeout=10.0)
    
    #print("after setting calibration")
    #print(trig0TCTL.get())
    #print(chan0TCTL.get())
    #print(chan6Rate.get())
    #print(calibEnable.get())
    #print(trig3SelSrc.get())
    #print(trig4SelSrc.get())
    #print(trig5SelSrc.get())
    #print(trig7SelSrc.get())
    
    print("Waiting for calibration to occur")
    
    time.sleep(5)
    
    print("Calibration Complete")
    
    
    print("Reseting to PV's")
    
    trig0TCTL.put(trig0TCTL_sav,timeout=10.0)
    chan0TCTL.put(chan0TCTL_sav,timeout=10.0)
    chan6Rate.put(chan6Rate_sav,timeout=10.0)
    calibEnable.put(calibEnable_sav,timeout=10.0)
    trig3SelSrc.put(trig3SelSrc_sav,timeout=10.0)
    trig4SelSrc.put(trig4SelSrc_sav,timeout=10.0)
    trig5SelSrc.put(trig5SelSrc_sav,timeout=10.0)
    trig7SelSrc.put(trig7SelSrc_sav,timeout=10.0)
    
    #print("After reseting to original possitions")
    #print(trig0TCTL.get())
    #print(chan0TCTL.get())
    #print(calibEnable.get())
    #print(trig3SelSrc.get())
    #print(trig4SelSrc.get())
    #print(trig5SelSrc.get())
    #print(trig7SelSrc.get())

def main(argv):
    pv_data = process_args(argv)
    calibrateBergoz(pv_data)

if __name__ == "__main__":
    main(sys.argv[1:])
