#!/bin/sh 

SAMPLE=/root/CheckRule
SUBMIT_CLI='python /var/log/u-sandbox/usandbox/cli/usbxcli.py op-submitsample '
TASK_ID=/root/taskid.list
USBOX_LOG=/var/log/u-sandbox/log/usandbox.log
RESULT=/root/result.txt
PSQL="/usr/bin/psql -d usboxdb -U usboxdbuser -c"


>$TASK_ID
>$USBOX_LOG

count=1
ls $SAMPLE | while read file
do
	if [ $count -gt 50 ]
	then
		exit
	fi
	echo "Submit file : $file"
	$SUBMIT_CLI "$SAMPLE/$file" | awk 'NR==1{print $3}' >> $TASK_ID 
	count=$((count+1))
	#sleep 1
done


finish_count=0
while [ $finish_count -lt 50 ]
do
	sleep 300
	finish_count=`python u-sandbox/usandbox/cli/usbxcli.py op-getstatus --all | grep complete | wc -l`
done

echo -e " Minimum Submitedtime | Maximum Finishedtime | Time Cost" > $RESULT
result=`$PSQL "select min(submittedtime),max(finishedtime),(max(finishedtime)-min(submittedtime)) from tbl_task_history" | awk "NR==3{print}"`
echo -e "$result" >> $RESULT

cd /root
ftp -u test 10.64.49.20 << EOF
bin
put $RESULT
bye
no
<< EOF
