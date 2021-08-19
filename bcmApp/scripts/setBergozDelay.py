import sys
import time
import epics as e
from statistics import mean

from datetime import datetime


import argparse

def process_args(argv):
     parser=argparse.ArgumentParser(description='This script sets the required conditions to recalibrate the bergoz chassis')
     parser.add_argument('AREA', help = 'Area in the tunnle i.e. GUNB, IN10 etc.')
     parser.add_argument('POS', help='location i.e 360, 491 etc.')
     parser.add_argument('IOC_UNIT', help='im01,im02 etc.')
     parser.add_argument('SAMP_SIZE', type=int ,help='Number of samples to be collected')
     parser=parser.parse_args()
     
     return parser
     
def query_yes_no(question, bypass=False):
    if(bypass):
        return True
    valid = {"yes": True, "y": True, "no": False, "n": False}
    prompt = " [y/n] "

    while True:
        sys.stdout.write(question + prompt)
        choice = input().lower()
        if choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' " "(or 'y' or 'n').\n")
     
def main(argv):
    pv_data = process_args(argv)
    average_PC = []
    
    print("Delay \t Meausured Charge")
    for delay in range(256):
        data = 0
        e.caput("TORO:{}:{}:DELAY_WR".format(pv_data.AREA, pv_data.POS),delay,wait=True)
        for sample in range(pv_data.SAMP_SIZE):
            time.sleep(.1)
            data += int(e.caget("TORO:{}:{}:CHRG.VAL".format(pv_data.AREA, pv_data.POS),use_monitor=False))
        average_PC.append(data/pv_data.SAMP_SIZE)
        print(delay, "\t", average_PC[delay])
    
    print("The max measured charge occured with delay: ", average_PC.index(max(average_PC)))
    
    if(query_yes_no("Would you like to set the Bergoz delay to "+ str(average_PC.index(max(average_PC)))+" y/n:")):
        e.caput("TORO:{}:{}:DELAY_WR".format(pv_data.AREA, pv_data.POS), average_PC.index(max(average_PC)),wait=True)
    else:
        print("To set the Bergoz delay to something else please use the screen")
        print("Please now close this window")
    

if __name__ == "__main__":
    main(sys.argv[1:])
