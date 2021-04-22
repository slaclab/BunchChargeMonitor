source $TOOLS/script/use_pydm.sh
export PYDM_DISPLAYS_PATH=$TOOLS/pydm/display/
pydm --hide-nav-bar -m "AREA=GUNB,POS=360,UNIT=1,INST=0,CHAN=DEV,IOC_UNIT=IM01,IOC=sioc-b084-im01, CPU=cpu-b084-sp17, CRATE=shm-b084-sp17-1, isSC=True" bcm_expert.py &
