source $TOOLS/script/use_pydm.sh
export PYDM_DISPLAYS_PATH=$TOOLS/pydm/display/
pydm --hide-nav-bar -m "AREA=IN10,POS=431,UNIT=1,INST=0,CHAN=IM10431,IOC_UNIT=IM02,IOC=sioc-b084-im02, CPU=cpu-b084-sp17, CRATE=shm-b084-sp17-2, TYPE=TORO" bcm_main.py & 
