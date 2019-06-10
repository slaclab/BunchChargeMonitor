#ifndef STREAM_DATATYPE_H
#define STREAM_DATATYPE_H

#include <epicsTypes.h>
#include <epicsTime.h>
#include <sys/time.h>

// For BsaStatus
#define BSA_MESSAGE 0x01

#define STREAM_LENGTH (sizeof(stream_t))

#pragma pack(push)
#pragma pack(1)

typedef struct {
    epicsTimeStamp  time;
    epicsUInt32     mod[6];
    epicsUInt32     edefAvgDoneMask;
    epicsUInt32     edefMinorMask;
    epicsUInt32     edefMajorMask;
    epicsUInt32     edefInitMask;
} timing_header_t;

typedef struct {
    // ADC inputs that receive charge data 
    epicsInt32      adc0;
    epicsInt32      adc1;
    epicsInt32      adc2;
    // Differencial calculation between inputs
    epicsInt32      diff_adc0_adc1;
    epicsInt32      diff_adc0_adc2;
    epicsUInt32     status;
    epicsUInt32     bsaStatus;
    // Four 32-bit words reserved for future use
    epicsUInt32     reservedWords[4];    
} payload_t;

/* This structure represents the entire content of the BSA stream message that
 * comes from the firmware. If the message content is changed, this structure
 * must be updated */
typedef struct {
    // Stream header is not described at the specification.
    epicsUInt64     streamHeader;
    epicsUInt32     headerWord;
    timing_header_t timingHeader;
    payload_t       AMC0_Data;
    payload_t       AMC1_Data;
} stream_t;

#pragma pack(pop)

#endif /* STREAM_DATATYPE_H */

