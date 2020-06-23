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
    int i;
    pasub->pact = 1;

    for (i = 0; i < pasub->noa; i++) {
        ((short *)pasub->vala)[i] = (short)(((unsigned short *)pasub->a)[i] >> 1);
    }

    pasub->pact = 0;

    return 0; /* process output links */
}

epicsRegisterFunction(calcRWF16);
