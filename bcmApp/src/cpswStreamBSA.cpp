#include <iostream>
#include <iomanip>
#include <string>
#include <vector>
#include <cmath>

#include <epicsThread.h>
#include <alarm.h>
#include <epicsTime.h>

#include "cpswStreamBSA.h"
#include "streamDataType.h"
#include "bcmBSA.h"

#include <cpsw_api_user.h>
#include "yamlLoader.h"

static void C_streamTask(void *p) {
    CpswStreamBSA* pStreamBSA = CpswStreamBSA::getInstance();
    pStreamBSA->streamTask();
}

// Singleton design pattern: initialize class instance pointer to null.
CpswStreamBSA* CpswStreamBSA::instance = 0;

// Get the instance pointer for the class. If it is the first time,
// create a new one.
CpswStreamBSA* CpswStreamBSA::getInstance() {
    if (instance == 0) {
        instance = new CpswStreamBSA();
    }

    return instance;
}

CpswStreamBSA::CpswStreamBSA() {
    counterPacketsToDump = 0;
}

// This is the name of the stream responsible to send BSA data from the ATCA
// to the network. The name is defined in the yaml file, and is sent to the
// object as a parameter in st.cmd.
void CpswStreamBSA::setStreamName(std::string strmName) {  
    streamName = strmName; 
}

int CpswStreamBSA::fireStreamTask() {
    epicsThreadCreate(streamName.c_str(), epicsThreadPriorityHigh + 3,
                  epicsThreadGetStackSize(epicsThreadStackMedium),
                  (EPICSTHREADFUNC) C_streamTask, NULL);

    return 0;
}

void CpswStreamBSA::streamTask() {
    uint8_t buf[STREAM_LENGTH];
    uint32_t count = 0;

    stream_t* streamData;
    payload_t AMC;
    epicsTimeStamp timeStamp;

    // Will receive a struct that is hold inside a map
    bsaData_t* pBsaData;

    // Counters for loop
    int iii, jjj; 
    std::size_t aaa; // To get rid of compiler warning messages
    int buf_idx;

    epicsTimeStamp* timeStampAux = (epicsTimeStamp*) malloc(sizeof(epicsTimeStamp));

    // Get instance of the object that sends the data to the BSA core
    BcmBSA* pBcmBSA = BcmBSA::getInstance();

    // Get stream according to the stream name informed in the IOC shell
    Path p = cpswGetRoot();
    Path strm_name = p->findByName(streamName.c_str());
    Stream stream = IStream::create(strm_name);
    
    while (1) {
        // Receive stream from the firmware and write it in buf
        count = stream->read(buf, sizeof(buf), 50000);
        //epicsTime before = epicsTime::getCurrent();
        
        if (count != STREAM_LENGTH) {
            // Do something?
        } else {
            // Map buf's content with the stream structure
            streamData = (stream_t*) buf;
            timeStamp = streamData->timingHeader.time;
            
            // Dump contents of BSA stream, case the user run the command on
            // the IOC shell. The user can choose how many sequence packets he
            // wants to be shown.
            if (counterPacketsToDump) {
                printf("\nBSA stream dump - %d packets remaining", counterPacketsToDump-1); 
                for (aaa=0; aaa<STREAM_LENGTH;++aaa) {
                    if (!(aaa % 4)) {
                        printf("\n%lu   ", aaa/4);
                    }
                    // Fix for endianess
                    buf_idx = static_cast<int>(4*floor(aaa/4.0)+3-aaa%4);
                    printf ("%02X ", buf[buf_idx]);
                }
                --counterPacketsToDump;
                printf("\n");
            }

            /*
             * Somehow, the word order for timestamp in data stream has been swapped.
             * We are going to swap the word order in software side until firmware fix it.
             */
            timeStampAux->nsec = timeStamp.secPastEpoch;
            timeStampAux->secPastEpoch  = timeStamp.nsec;

            // Loop through iii AMC cards and jjj ADC inputs in each card.
            // There are 2 AMC cards and we will read 3 inputs from each one.
            // As the data structure that comes from the firmware is not
            // flexible we will use magic numbers here. Changing numbers of AMC
            // cards and inputs would need not only change this magic numbers,
            // but also the data structures and the ifs and switches below.
            for (iii = 0; iii < NUM_AMC_CARDS; ++iii) {
                // Depending on the AMC and ADC being read, we need to
                // access different data from different positions of
                // the stream.
                AMC = (0 == iii) ? streamData->AMC0_Data : streamData->AMC1_Data;

                for (jjj = 0; jjj < NUM_ADC_AVAIL; ++jjj) {
                    pBsaData = pBcmBSA->getBsaDataStruct(iii, jjj);
                    // If the the BSA channel for this AMC and ADC was not
                    // created, do nothing. Each bunch charge board will
                    // use some or all inputs, depending on the sector it
                    // is installed. So, no concerns if we receive NULL
                    // from getBsaDataStruct.
                    if (NULL != pBsaData) {
                        pBsaData->timeStamp = *timeStampAux;

                        // Now, the alarm status flags.
                        // By default, no alarms
                        pBsaData->stat = epicsAlarmNone; 
                        pBsaData->sevr = epicsSevNone;

                        switch (jjj) {
                            case 0:
                                pBsaData->tmit = pBcmBSA->fixedToDouble(AMC.adc0);
                                break;
                            case 1:
                                pBsaData->tmit = pBcmBSA->fixedToDouble(AMC.adc1);
                                break;
                            case 2:
                                pBsaData->tmit = pBcmBSA->fixedToDouble(AMC.adc2);
                                break;
                        }
                    
                        // TMIT comes from the ATCA in pC units. We need to
                        // convert it to number of electrons, as required by
                        // the BSA users.
                        pBsaData->tmit /= 1.60217662*pow(10,-7);
                    } // if (NULL != pBsaData)
                } // for (jjj = 0; jjj < 2; ++jjj)
            } // for (iii = 0; iii < NUM_AMC_CARDS; ++iii)
            
            // Send data for all the channels to the BSA core
            pBcmBSA->sendData();

            //epicsTime after = epicsTime::getCurrent();
            //epicsTime diff = after - before;
            //printf("Time spent = %f\n", after - before);
        } // else

    } // while (1) 
}

void CpswStreamBSA::setNumberPacketsToDump(int numberOfPackets) {
    counterPacketsToDump = numberOfPackets;
}

CpswStreamBSA::~CpswStreamBSA() {
    delete instance;
}
