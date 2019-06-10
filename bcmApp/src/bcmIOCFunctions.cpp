#include <iostream>

#include <iocsh.h>
#include <epicsExport.h>
#include <errlog.h>

#include "cpswStreamBSA.h"
#include "bcmBSA.h"

/******************************************************************************
 * Function to configure the bcm IOC and to fire the thread that reads BSA    
 * stream from the ATCA. It is the last function to be called in st.cmd.
 *
 * Input: stream name of the BSA, as defined in the yaml file.
******************************************************************************/

static int bcmConfigure(const char *streamName) {
    // Create and configure object responsible for monitoring the arrival of
    // BSA stream message and parsing it.
    class CpswStreamBSA* pStreamBSA;
    pStreamBSA = CpswStreamBSA::getInstance();
    pStreamBSA->setStreamName(streamName);
    // Fire the thread that will take care of the message receiving
    pStreamBSA->fireStreamTask();

    return 0;
}

static const iocshArg bcmConfigureArg0 = {"BSA stream name", iocshArgString};
static const iocshArg * const bcmConfigureArgs[] = 
                    { &bcmConfigureArg0 }; 
static const iocshFuncDef bcmConfigureFuncDef = 
                    { "bcmConfigure", 1, bcmConfigureArgs };
static void bcmConfigureCallFunc(const iocshArgBuf * args)
{
    bcmConfigure(args[0].sval);
}


/******************************************************************************
 * Function to configure a BSA channel. For each BSA data that is going to be     
 * stored, we must call this function once.
 *
 * Input: - station name, that is the prefix of the BSA pvs.
 *        - the number of the AMC associated with this BSA channel, starting
            from 0.
          - the number of the ADC inside the AMC, starting from 0.
******************************************************************************/

static int bcmBSAConfigure(const char *stationName, int amcNumber, int adcNumber)
{
    // Create and configure object responsible to create a BSA channel.
    class BcmBSA* pBcmBSA;
    pBcmBSA = BcmBSA::getInstance();

    if (! pBcmBSA->createChannel(stationName, amcNumber, adcNumber)) {
        std::cout << "Created BSA channel " << stationName
                  << " for AMC " << amcNumber << " and ADC "
                  << adcNumber << std::endl;
        return 0;
    }
    else {
        errlogPrintf("AMC number must be 0-1 and ADC number must be 0-2\n");
        return 1;
    }
}

static const iocshArg bsaPvArg0 = { "PV name for BSA", iocshArgString };
static const iocshArg bsaPvArg1 = { "AMC card number [0-1]", iocshArgInt };
static const iocshArg bsaPvArg2 = { "ADC input number [0-2]", iocshArgInt };
static const iocshArg * const bsaPvArgs[] = { &bsaPvArg0, &bsaPvArg1,
                                              &bsaPvArg2 };
static const iocshFuncDef bsaPvFuncDef = {"bcmBsaConfigure", 3, bsaPvArgs };
static void bsaPvCallFunc(const iocshArgBuf * args)
{
    bcmBSAConfigure(args[0].sval, args[1].ival, args[2].ival);
}


/******************************************************************************
 * Dump BSA Stream print the stream to the console in groups of 4 bytes, using
 * the hexadecimal format.
 *
 * Input: number of packets. This is the number of sequential packets that will
 * be dumped.
******************************************************************************/
void bcm_dumpBSAStream(int numberOfPackets)
{
    // Get instance of the stream BSA class
    class CpswStreamBSA* pStreamBSA;
    pStreamBSA = CpswStreamBSA::getInstance();
    pStreamBSA->setNumberPacketsToDump(numberOfPackets);
}

static const iocshArg bcm_dumpBSAStreamArg0 = { "Number of packets to print", 
                                                iocshArgInt };
static const iocshArg *const bcm_dumpBSAStreamArgs[] = {&bcm_dumpBSAStreamArg0};
static const iocshFuncDef bcm_dumpBSAStreamFuncDef = {"bcm_dumpBSAStream", 1, 
                                                       bcm_dumpBSAStreamArgs };

static void bcm_dumpBSAStreamCallFunc(const iocshArgBuf * args)
{
    bcm_dumpBSAStream(args[0].ival);
}



void BcmIOCFunctionsRegistrar(void)
{
    iocshRegister(&bcmConfigureFuncDef, bcmConfigureCallFunc);
    iocshRegister(&bsaPvFuncDef, bsaPvCallFunc);
    iocshRegister(&bcm_dumpBSAStreamFuncDef, bcm_dumpBSAStreamCallFunc);
}

epicsExportRegistrar(BcmIOCFunctionsRegistrar);
