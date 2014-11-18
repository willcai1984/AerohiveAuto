#!/bin/bash
index=0
host=$1
logdir=$2
logfile=$3

while [ $index -lt 18 ] ; do
	LOGFILE=$index-$logfile
	echo $LOGFILE

	echo ========$index========

	stafcmd.pl -d $host  -v "ipconfig /all" -l $logdir -o $LOGFILE
	echo ========$index====result log is [$LOGFILE] ====

	export result=`getrmtip.pl -f $logdir/$LOGFILE  -i Wireless -o win -nomask`
	echo ========$index====wireless IP is [$result] ====

	RET=`expr x$result : x192.168`

	if [ "$RET" != "0" ] ; then
		echo "get normal wireless IP: $result"
		exit 0
	else
		echo "The wireless IP not start with 192.168, please wait 5s and retry..."
		let index=$index+1;
		sleep 5
	fi
done
exit 1;
