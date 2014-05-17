#!/bin/sh

ROOT_PATH="/root/PerfTestRes/"
REALTIME_FOLDER="realtime/"	
SBX_WAIT_QUE=sbxWaitQueStat_`date +%Y%m%d%H%M%S`
SBX_SUB_QUE=sbxSubQueStat_`date +%Y%m%d%H%M%S` 

>$ROOT_PATH$REALTIME_FOLDER$SBX_WAIT_QUE
>$ROOT_PATH$REALTIME_FOLDER$SBX_SUB_QUE

for i in `seq 1 $1`
do
	#time out
	#TIME_OUT=`/opt/trend/ddei/PostgreSQL/bin/psql ddei sa -c  "select count(*) from tb_sandbox_tasks_history where status=4;"| awk 'NR==3{print}'`
	#if [ $TIME_OUT -ge 1 ]
	#then
	#	#echo "There're ${TIME_OUT} files analysis time out..."
	#	#exit 1
	#fi

	#sandbox queue
	/opt/trend/ddei/PostgreSQL/bin/psql ddei sa -c  "select count(*) from tb_sandbox_tasks where status = 0;"| awk 'NR==3{print}' >> $ROOT_PATH$REALTIME_FOLDER$SBX_WAIT_QUE
	/opt/trend/ddei/PostgreSQL/bin/psql ddei sa -c  "select count(*) from tb_sandbox_tasks where status = 1;"| awk 'NR==3{print}' >> $ROOT_PATH$REALTIME_FOLDER$SBX_SUB_QUE
	#/opt/trend/ddei/PostgreSQL/bin/psql ddei sa -c  "select count(*) from tb_sandbox_tasks where status = 1;"| awk 'NR==3{print}'
	
	sleep $2	
done
