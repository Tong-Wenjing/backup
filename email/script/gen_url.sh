#!/bin/sh

NORMAL_URL="http://cdcbbs.tw.trendnet.org/viewpro.php?uid="
UNRATED_URL="http://www.ddei.com/"
RESULT_LOC="$PWD/../samples/"


if [ -f $RESULT_LOC/formalized_url ]
then
    >$RESULT_LOC/formalized_url
fi

i=0
j=0
while true
do
    tmp=$RANDOM
    ret=`echo "scale=0;$tmp%2" | bc -l`

    if [ $ret -eq 1 ]
    then
        i=$((i+1)) 
        if [ $i -le 10447 ]
        then
            tmp_nor_url=$NORMAL_URL$i
            url_sha1_value=`echo $tmp_nor_url | sha1sum -t | cut -d" " -f1`
            echo "$url_sha1_value-$tmp_nor_url" >> $RESULT_LOC/formalized_url
        else
            break
        fi
    else
        j=$((j+1))
        if [ $j -le 323 ]
        then
            tmp_unrated_url=$UNRATED_URL$j.htm
            url_sha1_value=`echo $tmp_unrated_url | sha1sum -t | cut -d" " -f1`
            echo "$url_sha1_value-$tmp_unrated_url" >> $RESULT_LOC/formalized_url
        fi
    fi
done


