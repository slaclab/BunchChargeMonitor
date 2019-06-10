#ifndef BCM_BSA_H
#define BCM_BSA_H

#include <vector>
#include <map>
#include <string>

#include "BsaApi.h"

// Number of bits for the integer part and fraction part of the fixed point
// numbers that arrive through the stream. The first bit is the signal.
#define INT_SIZE 12
#define INT_MASK 0x7FF80000
#define FRAC_SIZE 19
#define FRAC_MASK 0x7FFFF
// Must devide by 1,000,000 to transform numbers until 0x7FFFF into the decimal
// part
#define FRAC_DIVIDER 1000000.0
#define SIG_MASK 0x80000000
// There are 2 AMC cards and we will read 3 inputs from each one.
// As the data structure that comes from the firmware is not
// flexible, changing this numbers only here will have no effect.
// Changing numbers of AMC cards and inputs would need not only 
// change this constants, but also the data structures and ifs 
// and switches in the implementation code.
#define NUM_AMC_CARDS 2
#define NUM_ADC_AVAIL 3


// Data to be sent to BSA channels
typedef struct bsaData_t {
    epicsTimeStamp timeStamp;
    double         tmit;
    int            amcNumber;
    int            adcNumber;
    BsaChannel     bsaChannel;
    BsaStat        stat;
    BsaSevr        sevr;
} bsaData_t;

class BcmBSA {
private:
    std::map<std::string, bsaData_t> bsaDataHash;
    std::string buildKey(int amcNumber, int adcNumber);
    // Singleton design pattern: here is the pointer for the only instance of
    // this class.
    static BcmBSA* instance;
    // Private constructor for Singleton design pattern
    BcmBSA();
    // Private copy constructor and copy assignment operator, to avoid someone
    // to clone the object (we want only one instance)
    BcmBSA(const BcmBSA&);
    BcmBSA& operator=(const BcmBSA&);
public:
    ~BcmBSA();
    // Singleton method to retrieve pointer to the only object that can be
    // instantiated from this class.
    static BcmBSA* getInstance();
    int createChannel(const char *stationName, int amcNumber, int adcNumber);
    bsaData_t* getBsaDataStruct(int amcNumber, int adcNumber);
    void sendData();
    double fixedToDouble(int fixedPoint);
};

#endif // BCM_BSA_H
