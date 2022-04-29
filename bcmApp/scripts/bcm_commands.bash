#This function fills the BCM trigger name


#Argument 1 is the position GUNB/IN10/LI20 etc
#Argument 2 is the iocInstance $2/IM02 etc
function bcm_enable_channel() {
     caput TPR:$1:$2:0:CH00_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH01_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH02_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH03_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH04_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH05_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH06_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH07_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH08_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH09_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH10_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH11_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH12_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH13_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH14_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH15_SYS2_TCTL 1
}

#this function will restart all bcm IOCS
function bcm_restart(){
	siocRestart sioc-gunb-im01
	siocRestart sioc-gunb-im02
	siocRestart sioc-col1-im01
	siocRestart sioc-col1-im02
	siocRestart sioc-emit2-im01
	siocRestart sioc-emit2-im02
	siocRestart sioc-sph-im01
	siocRestart sioc-sps-im01
	siocRestart sioc-spd-im01
	siocRestart sioc-spd-im02
}


function bcm_set_triggers() {
     caput TPR:$1:$2:0:CH00_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH01_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH02_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH03_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH04_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH05_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH06_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH07_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH08_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH09_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH10_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH11_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH12_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH13_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH14_SYS2_TCTL 1
	 caput TPR:$1:$2:0:CH15_SYS2_TCTL 1
	 
	 caput TPR:$1:$2:0:TRG00_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG01_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG02_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG03_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG04_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG05_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG06_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG07_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG08_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG09_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG10_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG11_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG12_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG13_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG14_SYS2_TCTL 1
	 caput TPR:$1:$2:0:TRG15_SYS2_TCTL 1

     caput TPR:$1:$2:0:TRG00_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG01_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG02_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG03_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG04_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG05_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG06_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG07_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG08_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG09_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG10_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG11_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG12_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG13_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG14_SYS2_TWID 11
	 caput TPR:$1:$2:0:TRG15_SYS2_TWID 11
	 
	 caput TPR:$1:$2:0:TRG02_SYS2_TDES 124
	 
	 caput TPR:$1:$2:0:CH06_DESTMODE 0
	 
	 caput TPR:$1:$2:0:CH06_DESTMASK 65535
	 
}

function bcm_program_fpga(){
    loc=/usr/local/lcls/package/cpsw/utils/ProgramFPGA/current
    $loc/ProgramFPGA.bash -s SHM-GUNB-SP01-1 -n 7 -c cpu-gunb-sp01 -m $1 &
    $loc/ProgramFPGA.bash -s SHM-GUNB-SP01-1 -n 6 -c cpu-gunb-sp01 -m $1 & #farady cup
    $loc/ProgramFPGA.bash -s shm-bc1b-sp01-1 -n 6 -c CPU-BC1B-SP01 -m $1 &
    $loc/ProgramFPGA.bash -s shm-l2b-sp03-1 -n 5 -c CPU-L2B-SP03 -m $1 &
    $loc/ProgramFPGA.bash -s SHM-SPH-SP03-1 -n 4 -c CPU-SPH-SP03 -m $1 &
    $loc/ProgramFPGA.bash -s SHM-SPS-SP02-1 -n 5 -c CPU-SPS-SP02 -m $1 &
    $loc/ProgramFPGA.bash -s SHM-SPD-SP02-1 -n 3 -c CPU-SPD-SP02 -m $1 &
}

function bcm_crate_firmware(){
    source /usr/local/lcls/package/IPMC/env.sh
    printf "GUNB toroid\n\n"
    amcc_dump_bsi --all SHM-GUNB-SP01-1/7
    printf  "Diag Farady cup\n\n"
    amcc_dump_bsi --all SHM-GUNB-SP01-1/6
    printf  "BC1B toroid\n\n"
    amcc_dump_bsi --all shm-bc1b-sp01-1/6
    printf  "EMIT2 toroid\n\n"
    amcc_dump_bsi --all shm-l2b-sp03-1/5
    printf  "Hard Line toroid\n\n"
    amcc_dump_bsi --all SHM-SPH-SP03-1/4
    printf  "Soft line toroid\n\n"
    amcc_dump_bsi --all SHM-SPS-SP02-1/5
    printf  "Dump line toroid\n\n"
    amcc_dump_bsi --all SHM-SPD-SP02-1/3
}


function bcm_set_chan_timing(){
     caput TPR:$1:$2:0:CH00_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH01_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH02_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH03_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH04_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH05_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH06_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH07_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH08_FIXEDRATE 1
	 caput TPR:$1:$2:0:CH09_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH10_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH11_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH12_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH13_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH14_FIXEDRATE 6
	 caput TPR:$1:$2:0:CH15_FIXEDRATE 6
	 
	 caput TPR:$1:$2:0:CH00_ACRATE 5
	 caput TPR:$1:$2:0:CH01_ACRATE 5
	 caput TPR:$1:$2:0:CH02_ACRATE 5
	 caput TPR:$1:$2:0:CH03_ACRATE 5
	 caput TPR:$1:$2:0:CH04_ACRATE 5
	 caput TPR:$1:$2:0:CH05_ACRATE 5
	 caput TPR:$1:$2:0:CH06_ACRATE 5
	 caput TPR:$1:$2:0:CH07_ACRATE 5
	 caput TPR:$1:$2:0:CH08_ACRATE 5
	 caput TPR:$1:$2:0:CH09_ACRATE 5
	 caput TPR:$1:$2:0:CH10_ACRATE 5
	 caput TPR:$1:$2:0:CH11_ACRATE 5
	 caput TPR:$1:$2:0:CH12_ACRATE 5
	 caput TPR:$1:$2:0:CH13_ACRATE 5
	 caput TPR:$1:$2:0:CH14_ACRATE 5
	 caput TPR:$1:$2:0:CH15_ACRATE 5
}

