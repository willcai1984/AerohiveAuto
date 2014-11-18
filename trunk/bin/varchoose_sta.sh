#
STAID=$1
if [ "$STAID" == "sta1" ]; then
	echo -n $2
elif [ "$STAID" == "sta2" ]; then
	echo -n $3
elif [ "$STAID" == "sta3" ]; then
	echo -n $4
fi
