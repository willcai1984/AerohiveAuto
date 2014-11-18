if [ $# -ne 1 ]; then
	echo "Usage: $0 filename"
	exit 1
fi

num=`grep "Mounting local file systems" $1|wc -l`
echo num=$num

if [ $num -eq 1 ]; then
	exit 0
else
	exit 1
fi
