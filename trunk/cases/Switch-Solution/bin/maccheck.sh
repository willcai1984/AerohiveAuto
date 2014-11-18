#!/bin/sh

mac=$1
maccount=$2
vlanstart=$3
vlan=$vlanstart
vlancount=$4
vlanmax=$[$vlan+$vlancount-1]
logdir=$5
casename=$6
filename=$7
fileid=$8



FPATH=$logdir
ALLLOG=checkmac-$fileid.log

>$FPATH/$ALLLOG
logfile=$FPATH/$ALLLOG

echo "the log file need to check is :$FPATH/$filename">>$logfile
TIME=`date`
echo $TIME >>$logfile
echo "=========" >>$logfile

	/opt/auto_main/bin/searchoperation.pl -f $logdir/$filename -i "$mac" -i "$vlan" -re

	if [ $? -ne 0 ]; then
		echo "this is the first mac and vlan">>$logfile
		echo "mac:$mac vlan:$vlan match failed in first step">>$logfile
		exit 1;
	else
		echo "this is the first mac and vlan">>$logfile
		echo "mac:$mac vlan:$vlan pass">>$logfile
		echo "=========">>$logfile
	fi
incmac() {
      newaddr=`echo $1 | awk --non-decimal-data 'BEGIN {FS=":";OFS=":"}{if(("0x"$3)+1>=65536)$2=sprintf("%04X",("0x"$2)+1);$3=sprintf("%04x",(("0x"$3)+1)%65536);print $0}'`;
      #echo $1 " -> " $newaddr ;
      mac=$newaddr;
}

if [ "$maccount" -eq 1 ];
then 
	for ((i=1;i<$vlancount;i++));
	do 
		vlan=$[$vlan+1];
		echo "increased vlan as :$vlan" >>$logfile
		
		/opt/auto_main/bin/searchoperation.pl -f $logdir/$filename -i "$mac" -i "$vlan" -re;
		if [ $? -ne 0 ];
		then
			echo "mac:$mac vlan:$vlan match failed" >>$logfile
			exit 1;
		else
			echo "mac:$mac vlan:$vlan pass" >>$logfile
			echo "=========" >>$logfile
		fi
		echo "--------$mac $vlan--------" >>$logfile
	done
else
	for ((i=1;i<$maccount;i++));
	do
		incmac "$mac";
		echo "now mac is:$mac" >>$logfile

		if [ "$vlancount" -gt "1" ] && [ "$vlan" -ge "$vlanmax" ];
		then
			vlan=$vlanstart;
			echo "set vlan as start one:$vlan" >>$logfile
		elif [ "$vlancount" -gt "1" ] && [ "$vlan" -lt "$vlanmax" ];
		then
			vlan=$[$vlan+1];
			echo "increased vlan as :$vlan" >>$logfile
		else
			vlan=$vlanstart;
			echo "other case : $vlan" >>$logfile
		fi

		/opt/auto_main/bin/searchoperation.pl -f $logdir/$filename -i "$mac" -i "$vlan" -re;
		
		if [ $? -ne 0 ];
		then
			echo "mac:$mac vlan:$vlan match failed" >>$logfile
			exit 1;
		else
			echo "mac:$mac vlan:$vlan pass" >>$logfile
			echo "=========" >>$logfile
		fi
		
		##/bin/cat "$FPATH"/"$TMPLOG"
		echo "--------$mac $vlan--------" >>$logfile
		##/bin/cat "$FPATH"/"$TMPLOG">>"$FPATH"/"$ALLLOG"
	done
fi