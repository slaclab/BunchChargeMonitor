if [ hostname = "lcls-dev3" ]
then 
    source /afs/slac/g/lcls/package/anaconda/envs/python3.7env/bin/activate
fi

if [ hostname = "lcls-srv01" ]
then
    source /usr/local/lcls/package/anaconda/envs/python3.7env/bin/activate
fi
export PYTHONPATH=/afs/slac/g/lcls/tools/python/toolbox;
python $TOOLS/script/setBergozDelay.py $1 $2 $3 $4
