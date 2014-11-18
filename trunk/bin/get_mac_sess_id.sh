#!bin/sh

Id=0
content=0
mac=`echo $1 | tr "[A-Z]" "[a-z]"`
dir=$2
begin_match=0
cat $dir | while read line
do
    if [[ "$line" == Id:* ]]; then
        Id=`echo $line | awk 'gsub(/[:,;]/, " ") {print $2}'`
        begin_match="on"
        continue
    fi

    if [[ $begin_match == on ]]; then 
        content=`echo $line | awk 'gsub(/[\,]/, " ") {print $1}'`
        begin_match="off"
        if [ "$content" == "$mac" ]; then
            echo $Id
            break
        fi
    fi
done
