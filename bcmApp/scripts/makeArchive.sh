#!/bin/sh

rm $IOC_DATA/$1/iocInfo/IOC.pvlist

while ! test -f $IOC_DATA/$1/iocInfo/IOC.pvlist
do
    sleep 1    
done

cat $IOC_DATA/$1/iocInfo/IOC.pvlist | grep -v "wave" | grep -v string | grep -v subArray | grep -v sub | grep -v bsa | grep -v compress | grep -v fanout | grep -v seq | cut -f1 -d "," | sed 's/$/ 10 scan/' > $IOC_DATA/$1/archive/MAIN.archive
cat $IOC_DATA/$1/iocInfo/IOC.pvlist | grep bsa | grep 1H | cut -f1 -d "," | sed 's/$/ 1 scan/' > $IOC_DATA/$1/archive/LCLS1BSA.archive
cat $IOC_DATA/sioc-sph-im01/iocInfo/IOC.pvlist | grep 'BSSSCHNMASK\|BSSSCHNSEVR\|SCUD1\|PIDSCUD1\|SCUD2\|PIDSCUD2\|SCUD3\|PIDSCUD3\|SCS1H\|PIDSCS1H\|SCSTH\|PIDSCSTH\|SCSHH\|PIDSCSHH\|SCH1H\|PIDSCH1H\|SCHTH\|PIDSCHTH\|SCHHH\|PIDSCHHH' |  grep 'CHRG\|CHRGUNC\|RAWSUM\|CHRGFLOAT\|TOROSTATUS\|CHRGNOTMIT' |  grep 'bo\|mbbo\|ai\|int64in' | cut -f1 -d "," | sed 's/$/ 1 scan/' > $IOC_DATA/$1/archive/bsss.archive
