import sys
import time
import socket

from datetime import datetime
from epics import caget, caput, camonitor

import argparse

def process_args(argv):
     parser=argparse.ArgumentParser(description='This script sets the required conditions to recalibrate the bergoz chassis')
     parser.add_argument('AREA', help = 'Area in the tunnle i.e. GUNB, IN10 etc.')
     parser.add_argument('POS', help='location i.e 360, 491 etc.')
     parser.add_argument('IOC_UNIT', help='im01,im02 etc.')
     parser=parser.parse_args()
     
     return parser
     
def main(argv):
    pv_data = process_args(argv)
    
    data = []
    
    data = camonitor("TORO:IN10:431:0:TMIT_PC")
    time.sleep(10)
    
    print(data)
    

if __name__ == "__main__":
    main(sys.argv[1:])
