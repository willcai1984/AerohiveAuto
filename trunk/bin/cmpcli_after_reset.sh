
if [ $# -ne 2 ]; then
	echo "Usage: $0 result-cli-file pre-defined-cli-file"
	exit 1
fi

FILE1=/tmp/cmpcli_$RANDOM.txt
FILE0=/tmp/cmpcli0_$RANDOM.txt
sed -n '/AH.*#show run$/,/AH.*#/p' $1 |sed '1d'|sed '$d' > $FILE1
sed -n '/AH.*#show run$/,/AH.*#/p' $1 |sed '1d'|sed '$d' > $FILE0
grep -v "capwap" $FILE1 | grep -v "console page" | grep -v "interval 5" | grep -v "track-wan.*interface" > $FILE0
echo $2
cat $FILE0
diff $FILE0 $2
ret=$?
rm -f $FILE1
#rm -f $FILE0
exit $ret
