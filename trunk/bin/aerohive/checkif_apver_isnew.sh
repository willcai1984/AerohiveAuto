
if [[ $# < 4 ]]; then
        echo Usage: checkif_ap_verisnew.sh -v ap-version-file -i image-version-file
        exit 1
fi

AP_VER=`grep Version $2 |awk '{print $3}'|sed 's/r/./'`
IMG_VERX=`grep Reversion $4 |awk '{print $2}'`
IMG_VER=$(echo $IMG_VERX|cut -d. -f1,2,3)

if [ "$AP_VER" != "$IMG_VER" ]; then
	echo "no (version not same: $AP_VER <> $IMG_VER)"
	exit
fi

AP_DATE=`grep "Build time:" $2 |awk '{print $3" "$4" "$5" "$6}'|cut -c1-14`
IMG_DATE=`grep "DATE: " $4 |awk '{print $2" "$3" "$4" "$5}'|cut -c1-14`

if [ "$AP_DATE" != "$IMG_DATE" ]; then
        echo "no (date not same: $AP_DATE <> $IMG_DATE)"
	exit
fi

echo yes
