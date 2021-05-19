#This function fills the BCM trigger name
#Argument 1 is the position GUNB/IN10/LI20 etc
#Argument 2 is the iocInstance $2/IM02 etc
function bcm_name_trig() {
     caput TPR:$1:$2:0:TPRTRIG00.DESC 'SMA of AMC0'
     caput TPR:$1:$2:0:TPRTRIG01.DESC 'DOUT0 LEMO of AMC0'
     caput TPR:$1:$2:0:TPRTRIG02.DESC 'DOUT1 LEMO of AMC0'
     caput TPR:$1:$2:0:TPRTRIG03.DESC 'SMA of AMC1'
     caput TPR:$1:$2:0:TPRTRIG04.DESC 'DOUT0 LEMO of AMC1'
     caput TPR:$1:$2:0:TPRTRIG05.DESC 'DOUT1 LEMO of AMC1'
     caput TPR:$1:$2:0:TPRTRIG06.DESC 'BSA stream from ATCA to CPU'
     caput TPR:$1:$2:0:TPRTRIG07.DESC 'Playback of simulated output waveform'
     caput TPR:$1:$2:0:TPRTRIG08.DESC 'Playback of trigger for DaqMux'
     caput TPR:$1:$2:0:TPRTRIG09.DESC 'Playback of freeze trigger for DaqMux'
     caput TPR:$1:$2:0:TPRTRIG10.DESC 'Acquisition for ADC0 on AMC0'
     caput TPR:$1:$2:0:TPRTRIG11.DESC 'Acquisition for ADC1 on AMC0'
     caput TPR:$1:$2:0:TPRTRIG12.DESC 'Acquisition for ADC2 on AMC0'
     caput TPR:$1:$2:0:TPRTRIG13.DESC 'Acquisition for ADC0 on AMC1'
     caput TPR:$1:$2:0:TPRTRIG14.DESC 'Acquisition for ADC1 on AMC1'
     caput TPR:$1:$2:0:TPRTRIG15.DESC 'Acquisition for ADC2 on AMC1'
}

