source $TOOLS/script/use_pydm.sh
export PYDM_DISPLAYS_PATH=$TOOLS/pydm/display/
pydm --hide-nav-bar -m "AREA=IN10,POS=791,UNIT=1,INST=IM10791,CHAN=0,IOC_UNIT=IM03,IOC=sioc-b084-im02, CPU=cpu-b084-sp17, CRATE=shm-b084-sp17-2" bcm_expert.py & 
#pydm -m "INST=IM10791,AREA=IN10,POS=791,CHAN=0,UNIT=IM03" bcm_expert.py &
