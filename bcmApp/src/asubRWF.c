#include <stdio.h>
#include <stdint.h>

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
    int i, j;
    pasub->pact = 1;

    for (i = 0, j = 0; i < pasub->nova-1 && j < pasub->noa; i += 2, j++) {
        ((uint16_t *)pasub->vala)[i] = ((long *)pasub->a)[j] & 0xffff; 
        ((uint16_t *)pasub->vala)[i+1] = ((long *)pasub->a)[j] >> 16;  
    }

    pasub->pact = 0;

    return 0; /* process output links */
}

epicsRegisterFunction(calcRWF16);
