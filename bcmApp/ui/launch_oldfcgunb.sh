source $TOOLS/script/use_pydm.sh
export PYDM_DISPLAYS_PATH=$TOOLS/pydm/display/
pydm --hide-nav-bar -m "AREA=GUNB,POS=999,UNIT=1,INST=0,CHAN=FC01,IOC_UNIT=FC01,IOC=sioc-b084-fc01, CPU=cpu-b084-sp17, CRATE=shm-b084-sp17-2, TYPE=FARC" bcm_main.py & 
