#
APID=$1
if [ "$APID" == "ap1" ]; then
	echo -n $2
elif [ "$APID" == "ap2" ]; then
	echo -n $3
elif [ "$APID" == "ap3" ]; then
	echo -n $4
fi
