if [ hostname = "lcls-dev3" ]
then 
    source /afs/slac/g/lcls/package/anaconda/envs/python3.7env/bin/activate
fi

if [ hostname = "lcls-srv01" ]
then
    source /usr/local/lcls/package/anaconda/envs/python3.7env/bin/activate
fi
export PYTHONPATH=$TOOLS/python/toolbox

python $APP/BunchChargeMonitor/current/bcmApp/scripts/calibrateBergoz.py -PV_Prefix=$1 -Sample_Num=$2 -IOC=$3
