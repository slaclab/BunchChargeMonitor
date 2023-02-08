if [ "$HOSTNAME" = lcls-dev3 ]
then 
    source /afs/slac/g/lcls/package/anaconda/envs/python3.7env/bin/activate
fi

if [ "$HOSTNAME" = lcls-srv01 ]
then
    source /usr/local/lcls/package/anaconda/envs/python3.7env/bin/activate
fi
export PYTHONPATH=$TOOLS/python/toolbox

#python $TOOLS/script/calibrateBergoz.py -PV_Prefix=TORO:SPH:365 -Sample_Num=7 -IOC=sioc-sph-im01
#python $TOOLS/script/calibrateBergoz.py -PV_Prefix=TORO:SPS:605 -Sample_Num=7 -IOC=sioc-sps-im01
python $TOOLS/script/calibrateBergoz.py -PV_Prefix=TORO:SPD:695 -Sample_Num=7 -IOC=sioc-spd-im01
