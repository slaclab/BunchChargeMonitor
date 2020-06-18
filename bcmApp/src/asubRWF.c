#include <registryFunction.h>
#include <epicsExport.h>
#include <aSubRecord.h>

static long calcRWF16(aSubRecord *pasub) {
    /*
     * Convert a list of 32 bit values into a list (twice the size) of unsigned 16 bit values.
     *
     * The lower 2 bytes come first. ex:
     * 0xcdcdabab should become (0xabab, 0xcdcd) in that order.
     */
    pasub->pact = 1;

    for (int i = 0; i < pasub->nova; i += 2) {
        pasub->vala[i] = pasub->a[i] & 0xffff; 
        pasub->vala[i+1] = pasub->a[i] >> 16;  
    }

    pasub->pact = 0;

    return 0; /* process output links */
}

epicsRegisterFunction(calcRWF16);
