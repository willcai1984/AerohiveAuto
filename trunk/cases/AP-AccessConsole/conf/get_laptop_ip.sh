#!/bin/bash
index=0
host=$1
logdir=$2
logfile=$3
bindir=$4
while [ $index -lt 12 ] ; do
       	perl $bindir/stafcmd.pl -d $host  -v "ipconfig /all" -l $logdir   -o $index-$logfile
	   	export result=`perl $bindir/getrmtip.pl -f $logdir/$index-$logfile  -i Wireless -o win -nomask`
		export result=`echo $result | grep 192.168`
		echo $result
		echo =========$result===========$index==================
		if [ "$result" ] ; then
			echo =========$result+++++++++++++++++++++++
			exit 0
		fi
		let index=$index+1;
		sleep 10
done
exit 1;
