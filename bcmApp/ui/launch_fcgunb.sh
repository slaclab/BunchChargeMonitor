source $TOOLS/script/use_pydm.sh
export PYDM_DISPLAYS_PATH=$TOOLS/pydm/display/
cat "Work in progress\n"
pydm --hide-nav-bar -m "AREA=GUNB,POS=999,UNIT=1,INST=0,CHAN=DEV_FC,IOC_UNIT=IM01,IOC=sioc-b084-im02, CPU=cpu-b084-sp17, CRATE=shm-b084-sp17-2" bcm_expert.py & 
