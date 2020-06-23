#include <registryFunction.h>
#include <epicsExport.h>
#include <aSubRecord.h>

static long calcTimeArray(aSubRecord *pasub) {
    long i, *clkFreq;
    double sum = 0.0, timeNs;


    clkFreq = (long *)pasub->a;

    // Calculate the time in ns between each sample, giving the clock
    // frequency in Hertz
    timeNs = (1000000000.0 / (double)(*clkFreq)) / 2.0;

    // Build array with the relative time for each sample since the first one
    for (i=0; i < pasub->nova; i++) {
        ((double *)pasub->vala)[i] = sum;
        sum += timeNs;
    }


    return 0; /* process output links */
}

epicsRegisterFunction(calcTimeArray);
