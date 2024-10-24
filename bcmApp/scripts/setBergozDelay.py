import sys
import time
import epics as e

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
    delay_list = []
    
    print("Delay \t Meausured Charge")
    delay = 0
    counter = 0
    try:
        while(delay <256):
            data = 0
            e.caput("TORO:{}:{}:DELAY_WR".format(pv_data.AREA, pv_data.POS),delay,wait=True)
            for sample in range(pv_data.SAMP_SIZE):
                time.sleep(.1)
                data += int(e.caget("TORO:{}:{}:CHRG.VAL".format(pv_data.AREA, pv_data.POS),use_monitor=False))
            averaged_data = data/pv_data.SAMP_SIZE
            if(averaged_data < 30):
                delay += 10
            elif(averaged_data < 40):
                delay += 5
            else:
                delay += 1
                
            average_PC.append(averaged_data)
            delay_list.append(delay)
            print(delay, "\t", average_PC[counter])
            counter += 1
            
    except KeyboardInterrupt:
        print("You have stoped program execution")
    
    max_index = average_PC.index(max(average_PC))
    max_delay = delay_list[max_index]
        
    print("The max measured charge occured with delay: ", max_delay)
        
    if(query_yes_no("Would you like to set the Bergoz delay to "+ str(max_delay)+" y/n:")):
        e.caput("TORO:{}:{}:DELAY_WR".format(pv_data.AREA, pv_data.POS), max_delay,wait=True)
    else:
        print("To set the Bergoz delay to something else please use the screen")
        print("Please now close this window")

    

if __name__ == "__main__":
    main(sys.argv[1:])
