#include <iostream>
#include <sstream>

#include "bcmBSA.h"

// Singleton design pattern: initialize class instance pointer to null.
BcmBSA* BcmBSA::instance = 0;

// Get the instance pointer for the class. If it is the first time,
// create a new one.
BcmBSA* BcmBSA::getInstance() {
    if (instance == 0) {
        instance = new BcmBSA();
    }

    return instance;
}

BcmBSA::BcmBSA() {

}

double BcmBSA::fixedToDouble(int fixedPoint) {
    int int_result;
    double double_result;

    // Extract integer part
    int_result = (fixedPoint & INT_MASK);

    if (fixedPoint & SIG_MASK) {
        // Negative, we must do a two's complement
        int_result = ~(int_result | SIG_MASK) + 1;
    }
    // Shift by the size of the fraction part
    int_result = int_result >> FRAC_SIZE;
    // Transform fraction part into actual fraction
    double_result = int_result + (fixedPoint & FRAC_MASK) / FRAC_DIVIDER;
    // Extract signal
    double_result = (fixedPoint & SIG_MASK) ? -double_result : double_result;

    return double_result;
}

std::string BcmBSA::buildKey(int amcNumber, int adcNumber) {
    // Our map key will be the number of the AMC together 
    // with the number of the ADC
    std::ostringstream key;
    key << amcNumber << adcNumber;

    return key.str();
}

int BcmBSA::createChannel(const char *stationName, int amcNumber, int adcNumber) {
    // AMC number and ADC number must be in the correct interval
    if ((amcNumber >= NUM_AMC_CARDS || amcNumber < 0)
            &&
        (adcNumber >= NUM_ADC_AVAIL || adcNumber < 0)) {
        
        return 1;
    } else {
        // Create BSA channel and save it into the map
        bsaData_t bsaData;

        bsaData.amcNumber = amcNumber;
        bsaData.adcNumber = adcNumber;
        bsaData.tmit = 0;
        bsaData.bsaChannel = BSA_CreateChannel(stationName);

        std::string key = buildKey(amcNumber, adcNumber);
        bsaDataHash[key] = bsaData;

        return 0; 
    }
}

bsaData_t* BcmBSA::getBsaDataStruct(int amcNumber, int adcNumber) {
    std::string key = buildKey(amcNumber, adcNumber);

    std::map<std::string, bsaData_t>::iterator it;
    it = bsaDataHash.find(key);
    if (it == bsaDataHash.end())
        return NULL;
    else
        // it->first is the key, it->second is the data
        return &it->second;
}

// Send all collected data to the BSA core
void BcmBSA::sendData() {
    std::map<std::string, bsaData_t>::iterator it;

    for (it = bsaDataHash.begin(); it != bsaDataHash.end(); ++it) {
        // it->first is the key, it->second is the data
        bsaData_t bsaData = it->second;

        BSA_StoreData(bsaData.bsaChannel, bsaData.timeStamp, bsaData.tmit,
                      bsaData.stat, bsaData.sevr);
    }
}

BcmBSA::~BcmBSA() {
    delete instance;
}

