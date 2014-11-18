#!/bin/sh

FPATH=/tmp
ALLLOG=sendvlan-all.log
TMPLOG=sendvlan.log

consname=$1
vlancount=$2
vlanstart1=$3
allowvlan=$4
vlanstart2=$5
vlanstart3=$6
vlanstart4=$7

>$FPATH/$ALLLOG
>$FPATH/$TMPLOG

if [ "$allowvlan" != "1" ];
then
	for ((i=$vlanstart1;i<$[$vlanstart1+$vlancount];i++));
	do
        >$FPATH/$TMPLOG

        /usr/bin/python /opt/auto_main/bin/console.py -w 1 -i 782 -o 60 -d localhost \
        -e $consname -u admin -p aerohive -m AH-[a-z0-9A-Z-]*# -w 0 -z $TMPLOG \
        -l $FPATH -v "vlan $i"

        /bin/cat $FPATH/$TMPLOG
        TIME=`date`
        echo "--------$TIME--------">>$FPATH/$ALLLOG
        /bin/cat $FPATH/$TMPLOG>>$FPATH/$ALLLOG
        #echo "sleep 1s"
        #/bin/sleep 
	done
else
	echo "allow vlan config"
	if [ "$consname" != "hzswtb8_sys-SR2148P" ];
	then 
		interface=23
		echo "interface 23"
	else
		interface=47
		echo "interface 47"
	fi

	if [ "$vlanstart1" != "" ];
	then 
		/usr/bin/python /opt/auto_main/bin/console.py -w 1 -i 782 -o 60 -d localhost \
			-e $consname -u admin -p aerohive -m AH-[a-z0-9A-Z-]*# -w 0 -z $TMPLOG \
			-l $FPATH -v "interface e1/$interface switchport trunk allow vlan $vlanstart1 - $[$vlanstart1+$vlancount-1]"
			
		/bin/cat $FPATH/$TMPLOG
        TIME=`date`
        echo "--------$TIME--------">>$FPATH/$ALLLOG
        /bin/cat $FPATH/$TMPLOG>>$FPATH/$ALLLOG
	fi

	if [ "$vlanstart2" != "" ];
	then
		/usr/bin/python /opt/auto_main/bin/console.py -w 1 -i 782 -o 60 -d localhost \
			-e $consname -u admin -p aerohive -m AH-[a-z0-9A-Z-]*# -w 0 -z $TMPLOG \
			-l $FPATH -v "interface e1/$interface switchport trunk allow vlan $vlanstart2 - $[$vlanstart2+$vlancount-1]"
	fi

	if [ "$vlanstart3" != "" ];
	then
		/usr/bin/python /opt/auto_main/bin/console.py -w 1 -i 782 -o 60 -d localhost \
			-e $consname -u admin -p aerohive -m AH-[a-z0-9A-Z-]*# -w 0 -z $TMPLOG \
			-l $FPATH -v "interface e1/$interface switchport trunk allow vlan $vlanstart3 - $[$vlanstart3+$vlancount-1]"
	fi

	if [ "$vlanstart4" != "" ];
	then 
		/usr/bin/python /opt/auto_main/bin/console.py -w 1 -i 782 -o 60 -d localhost \
			-e $consname -u admin -p aerohive -m AH-[a-z0-9A-Z-]*# -w 0 -z $TMPLOG \
			-l $FPATH -v "interface e1/$interface switchport trunk allow vlan $vlanstart4 - $[$vlanstart4+$vlancount-1]"
	fi
fi
exit 0;