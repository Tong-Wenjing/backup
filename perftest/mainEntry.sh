#!/bin/sh 

MAIL_LOG="/var/log/maillog"
SCRIPT_FOLDER="/root/perf/"
LOG_PATH="/root/PerfTestRes/"
AVG_FOLDER="average/"
BACKUP_FOLDER="backup/"
REALTIME_FOLDER="realtime/"
SUMMARY_FOLDER="summary/"
HTML_RESULT_FOLDER="htmlresult/"
CPU_STAT="cpuStat_`date +%Y%m%d%H%M%S`"
MEM_STAT="memStat_`date +%Y%m%d%H%M%S`"
IO_STAT="ioStat_`date +%Y%m%d%H%M%S`"
QUE_STAT="queStat_`date +%Y%m%d%H%M%S`"
PAGE_STAT="pageStat_`date +%Y%m%d%H%M%S`"
SWAP_STAT="swapStat_`date +%Y%m%d%H%M%S`"
DISK_STAT="diskStat_`date +%Y%m%d%H%M%S`"
SYS_SUM="sys_summary_`date +%Y%m%d%H%M%S`"
DB_SUM="db_summary_`date +%Y%m%d%H%M%S`"


INC_QUE="incQueue"
ACT_QUE="actQueue"
DEF_QUE="defQueue"
ATOP_LOG="atop_`date +%Y%m%d%H%M%S`.log"

#Commands
CPU_IDLE="sar -u 1 1 | grep Avg | awk '{print $8}'"
MEM_USAG="sar -r 1 1 | grep Avg"
IO_WAIT="sar -u 1 1 | grep Ave | awk '{print $6}'"
INC_QUE_NUM="find /var/spool/postfix/incoming/ -type f | wc -l"
ACT_QUE_NUM="find /var/spool/postfix/active/ -type f | wc -l"
DEF_QUE_NUM="find /var/spool/postfix/defer/ -type f | wc -l"
ATOP_WRI="atop -1 2 -w "
ATOP_REA="atop -r "
ATOP_PID="ps -ef | grep 'atop -1 2' | grep -v grep | awk '{print \$2}'"

PSQL="/opt/trend/ddei/PostgreSQL/bin/psql ddei sa -c "
##Clean DB
TC_POLICY_EVENT="truncate table tb_policy_event;"
TC_TASK_HISTORY="truncate table tb_sandbox_tasks_history;"
TC_TASK_DETAIL="truncate table tb_sandbox_task_details;"
TC_FILE_ANALYZE="truncate table tb_sandbox_report_file_analyze;"
TC_IMAGES="truncate table tb_sandbox_report_images;"
TC_ACCESS_RECORD="truncate table tb_sandbox_report_access_records;"
TC_ACCESS_URL="truncate table tb_sandbox_report_access_urls;"
TC_VIOLATED_EVENT="truncate table tb_sandbox_report_violated_events;"
TC_SYS_BEHAVIOR="truncate table tb_sandbox_report_system_behaviors;"
TC_MSG_TRACING="truncate table tb_msg_tracing;"
TC_OBJ_FILE="truncate table tb_object_file;"
TC_OBJ_URL="truncate table tb_object_url;"
TC_OBJ_HOST="truncate table tb_object_host;"

##summary data
TOTAL_EMAILS="select count(*) from tb_msg_tracing;"
TOTAL_EMAIL_ATTACH="select count(*) from tb_msg_tracing where attach_count=1"
ELAPSE_TIME="select max(out_timestamp)-min(in_timestamp) from tb_msg_tracing where delivery_status='sent';"
TOTAL_SBX_ATTCH="select count(*) from tb_sandbox_tasks_history;"
SBX_HIGH_RISK_DECT="select count(*) from tb_sandbox_tasks_history where overall_severity=3;"
SBX_MID_RISK_DECT="select count(*) from tb_sandbox_tasks_history where overall_severity=2;"
SBX_LOW_RISK_DECT="select count(*) from tb_sandbox_tasks_history where overall_severity=1;"
SBX_NO_RISK_DECT="select count(*) from tb_sandbox_tasks_history where overall_severity=0;"
ATSE_PRE_FILTERED="select count(*) from tb_policy_event where threat_type in (1,2);"
ANALYZE_TIME="select max(scan_time)-min(submit_time) from tb_sandbox_tasks_history;"
SBX_ANALYZE_STAT="select (max(analyze_time)-min(analyze_start_time)) as sc_analyze_time, (max(analyze_time)-min(analyze_start_time))/count(*) as overall_analyze_time, sum(analyze_time-analyze_start_time)/count(*) as avg_analyze_time_per_file from tb_sandbox_report_file_analyze group by image_id;"

##Sandbox queue statistic
TIME_OUT="select count(*) from tb_sandbox_tasks_history where status=4;"
SBX_QUE="select count(*) from tb_sandbox_tasks where submit_time is null;"

MAX_ID=0

calcAvgSysRes()
{
	#calculate average CPU usage
	AVG_IDLE_USAGE=`cat $LOG_PATH$AVG_FOLDER$CPU_STAT | sed 's/ \+/:/g' | cut -d':' -f9`
	AVG_TOTAL=`expr 100-${AVG_IDLE_USAGE}|bc`
	AVG_USER=`cat $LOG_PATH$AVG_FOLDER$CPU_STAT | sed 's/ \+/:/g' | cut -d':' -f4`
	AVG_SYSTEM=`cat $LOG_PATH$AVG_FOLDER$CPU_STAT | sed 's/ \+/:/g' | cut -d':' -f6`
	AVG_IO=`cat $LOG_PATH$AVG_FOLDER$CPU_STAT | sed 's/ \+/:/g' | cut -d':' -f7`
	
	#calculate average memory usage
	AVG_MEM_USAGE=`cat $LOG_PATH$AVG_FOLDER$MEM_STAT | sed 's/ \+/:/g' | cut -d':' -f4`
	AVG_FREE_USAGE=`cat $LOG_PATH$AVG_FOLDER$MEM_STAT | sed 's/ \+/:/g' | cut -d':' -f3`
	AVG_BUF_USAGE=`cat $LOG_PATH$AVG_FOLDER$MEM_STAT | sed 's/ \+/:/g' | cut -d':' -f6`
	AVG_CACHE_USAGE=`cat $LOG_PATH$AVG_FOLDER$MEM_STAT | sed 's/ \+/:/g' | cut -d':' -f7`
	
	USED_MEM=`expr $(($AVG_MEM_USAGE - $AVG_BUF_USAGE - $AVG_CACHE_USAGE)) / 1024 / 1024 | bc`
	FREE_MEM=`expr $(($AVG_FREE_USAGE + $AVG_BUG_USAGE + $AVG_CACHE_USAGE)) / 1024 / 1024 | bc`
	BUF_MEM=$(echo "scale=2;$AVG_BUF_USAGE/1024/1024" | bc)
	CACHE_MEM=`expr $AVG_CACHE_USAGE / 1024 / 1024 | bc`	
	
	#calculate average disk IO usage
	AWAIT=`cat $LOG_PATH$AVG_FOLDER$DISK_STAT | grep sda | sed 's/ \+/:/g' | cut -d':' -f9`
	SVCTM=`cat $LOG_PATH$AVG_FOLDER$DISK_STAT | grep sda | sed 's/ \+/:/g' | cut -d':' -f10`
	UTIL=`cat $LOG_PATH$AVG_FOLDER$DISK_STAT | grep sda | sed 's/ \+/:/g' | cut -d':' -f11`

	#calculate page in/out
	PAGE_IN=`cat $LOG_PATH$AVG_FOLDER$PAGE_STAT | sed 's/ \+/:/g' | cut -d':' -f3`
	PAGE_OUT=`cat $LOG_PATH$AVG_FOLDER$PAGE_STAT | sed 's/ \+/:/g' | cut -d':' -f4`
	

	echo "=========CPU Usage==========" > $1
	echo -e "Avg.CPU total usage(Total 100%):\t$AVG_TOTAL" >> $1
	echo -e "Avg.CPU User time(Total 100%):\t$AVG_USER" >> $1 
	echo -e "Avg.CPU System time(Total 100%):\t$AVG_SYSTEM" >> $1 
	echo -e "Avg.CPU IO wait(Total 100%):\t$AVG_IO" >> $1
	echo "=======Memory Usage=========" >> $1
	echo -e "Avg.Memory used(GB):\t$USED_MEM" >> $1 
	echo -e "Avg.Memory freed(GB):\t$FREE_MEM"	>> $1 
	echo -e "Avg.Memory buffered(GB):\t$BUF_MEM" >> $1 
	echo -e "Avg.Memory cached(GB):\t$CACHE_MEM" >> $1
	echo "=======Disk IO Usage========" >> $1
	echo -e "Avg.Disk await time(ms):\t$AWAIT" >> $1
	echo -e "Avg.Disk svctm time(ms):\t$SVCTM" >> $1
	echo -e "Avg.Disk %util(%):\t$UTIL" >> $1
	echo "========Page Usage==========" >> $1
	echo -e "Avg.Page in(KB/s):\t$PAGE_IN" >> $1
	echo -e "Avg.Page out(KB/s):\t$PAGE_OUT" >> $1
}

dbStatic()
{
	#Total processed emails
	TOTAL_PROC_EMAIL=`$PSQL"$TOTAL_EMAILS" -t` 
	
	#Total emails with attachment
	TOTAL_ATTACHMENT=`$PSQL"$TOTAL_EMAIL_ATTACH" -t`

	#Total detections by ATSE
	TOTAL_ATSE_DECT=`$PSQL"$ATSE_PRE_FILTERED" -t`
	
	#Total elapse time
	tmp=`$PSQL"$ELAPSE_TIME" -t`
	ret=$(formatTime $tmp)
	HOUR=`echo $ret | cut -d'|' -f1`
	MIN=`echo $ret | cut -d'|' -f2`
	SEC=`echo $ret | cut -d'|' -f3`	
	TOTAL_ELAPSE_TIME=`expr $(($HOUR * 3600)) + $(($MIN * 60)) + $SEC`
	
	AVG_SPEED_SEC=$(echo "scale=2;$TOTAL_PROC_EMAIL/$TOTAL_ELAPSE_TIME" | bc)
	AVG_SPEED_DAY=$(echo "scale=2;$AVG_SPEED_SEC*86400" | bc)
		
	#Total analyzed files
	TOTAL_SBX_FILE=`$PSQL"$TOTAL_SBX_ATTCH" -t`
	TOTAL_SBX_COMPLETE=$TOTAL_SBX_FILE
	
	#Different risk level
	HIGH_RISK_EMAILS=`$PSQL"$SBX_HIGH_RISK_DECT" -t`
	MID_RISK_EMAILS=`$PSQL"$SBX_MID_RISK_DECT" -t`
	LOW_RISK_EMAILS=`$PSQL"$SBX_LOW_RISK_DECT" -t`
	NO_RISK_EMAILS=`$PSQL"$SBX_NO_RISK_DECT" -t`
	TOTAL_SBX_DECT=`expr $HIGH_RISK_EMAILS + $MID_RISK_EMAILS + $LOW_RISK_EMAILS` 
	
	#analyze time
	tmp=`$PSQL"$ANALYZE_TIME" -t`
	ret=$(formatTime $tmp)
	HOUR=`echo $ret | cut -d'|' -f1`
	MIN=`echo $ret | cut -d'|' -f2`
	SEC=`echo $ret | cut -d'|' -f3`	
	TOTAL_ANALYZE_TIME=`expr $(($HOUR * 3600)) + $(($MIN * 60)) + $SEC`
	
	#Sbx statistic
	tmp=`$PSQL"$SBX_ANALYZE_STAT" -t | cut -d'|' -f1`
	ret=$(formatTime $tmp)
	HOUR=`echo $ret | cut -d'|' -f1`
	MIN=`echo $ret | cut -d'|' -f2`
	SEC=`echo $ret | cut -d'|' -f3`	
	SC_ANALYZE_TIME=`expr $(($HOUR * 3600)) + $(($MIN * 60)) + $SEC`

	tmp=`$PSQL"$SBX_ANALYZE_STAT" -t | cut -d'|' -f2`		
	ret=$(formatTime $tmp)
	HOUR=`echo $ret | cut -d'|' -f1`
	MIN=`echo $ret | cut -d'|' -f2`
	SEC=`echo $ret | cut -d'|' -f3`	
	ANALYZE_TIME_PER_FILE_ALL=`expr $(($HOUR * 3600)) + $(($MIN * 60)) + $SEC`
	
	tmp=`$PSQL"$SBX_ANALYZE_STAT" -t | cut -d'|' -f3`
	ret=$(formatTime $tmp)
	HOUR=`echo $ret | cut -d'|' -f1`
	MIN=`echo $ret | cut -d'|' -f2`
	SEC=`echo $ret | cut -d'|' -f3`
	ANALYZE_TIME_PER_FILE_PER_INS=`expr $(($HOUR * 3600)) + $(($MIN * 60)) + $SEC`

	#Total detections
	TOTAL_DETECTIONS=`expr $TOTAL_ATSE_DECT + $TOTAL_SBX_DECT`

	echo "======Virtual analyze=====" > $1
	echo -e "Total emails:\t$TOTAL_PROC_EMAIL" >> $1
	echo -e "# of emails with attachments:\t$TOTAL_ATTACHMENT" >> $1
	echo -e "Elapse(sec):\t$TOTAL_ELAPSE_TIME" >> $1
	echo -e "Avg.speed(msg/sec):\t$AVG_SPEED_SEC" >> $1 
	echo -e "Avg.speed(msg/day):\t$AVG_SPEED_DAY" >> $1 
	echo -e "# of sandboxed attachments:\t$TOTAL_SBX_FILE" >> $1
	echo -e "# of sandbox completion:\t$TOTAL_SBX_COMPLETE" >>  $1
	echo -e "# of high risk detections:\t$HIGH_RISK_EMAILS" >>$1   
	echo -e "# of medium risk detections:\t$MID_RISK_EMAILS" >>$1
	echo -e "# of low risk detections:\t$LOW_RISK_EMAILS" >>$1
	echo -e "# of no risk detections:\t$NO_RISK_EMAILS" >>$1 
	echo -e "Total analyze time (include queue time)(sec):\t$TOTAL_ANALYZE_TIME" >> $1
	echo -e "Total Sandcastle analyze time(sec):\t$SC_ANALYZE_TIME" >>$1 
	echo -e "Avg.Sandcastle analyze time per file per instance(sec):\t$ANALYZE_TIME_PER_FILE_PER_INS" >> $1
	echo -e "Avg.Sandcastle analyze time per file under all instances(sec):\t$ANALYZE_TIME_PER_FILE_ALL" >> $1
	echo "=======Threat Detection=======" >> $1
	echo -e "Prefiltered:\t$TOTAL_ATSE_DECT" >> $1
	echo -e "Virtual analysis:\t$TOTAL_SBX_DECT" >> $1
	echo -e "Total detections:\t$TOTAL_DETECTIONS" >> $1
}

formatTime()
{
	HOUR=`echo $1 | cut -d':' -f1`
	MIN=`echo $1 | cut -d':' -f2`
	SEC=`echo $1 | cut -d':' -f3 | cut -d'.' -f1`
	if [ "$HOUR" == "" ]
	then
		HOUR=0
	fi	
	if [ "$MIN" == "" ]
	then
		MIN=0
	fi
	if [ "$SEC" == "" ]
	then
		SEC=0
	fi
	echo "$HOUR|$MIN|$SEC"
}

formatRTRet()
{	
	ls $LOG_PATH$REALTIME_FOLDER | while read file
	do
		#cp $LOG_PATH$REALTIME_FOLDER$file $LOG_PATH$REALTIME_FOLDER$file.bak

		PREFIX=`echo $file | cut -d'_' -f1`
		case $PREFIX in
			cpuStat | ioStat | memStat | queStat | pageStat | swapStat)
				sed -i -e '1,3d' -e '$d' -e 's/ \+/|/g' $LOG_PATH$REALTIME_FOLDER$file
				;;
			diskStat)
				#Format disk usage realtime data
				SUFFIX=`ls $LOG_PATH$REALTIME_FOLDER$file | cut -d'_' -f2`
				cat $LOG_PATH$REALTIME_FOLDER$file | grep 'sda' | sed '$d' > $LOG_PATH$REALTIME_FOLDER/sdaStat_$SUFFIX
				cat $LOG_PATH$REALTIME_FOLDER$file | grep 'DDEI-root' | grep -v 'DDEI-root2' | sed '$d' > $LOG_PATH$REALTIME_FOLDER/rootStat_$SUFFIX
				cat $LOG_PATH$REALTIME_FOLDER$file | grep 'DDEI-app_data' | sed '$d' > $LOG_PATH$REALTIME_FOLDER/appdataStat_$SUFFIX
				sed -i -e 's/ \+/|/g' $LOG_PATH$REALTIME_FOLDER/sdaStat_$SUFFIX
				sed -i -e 's/ \+/|/g' $LOG_PATH$REALTIME_FOLDER/rootStat_$SUFFIX
				sed -i -e 's/ \+/|/g' $LOG_PATH$REALTIME_FOLDER/appdataStat_$SUFFIX
				
				;;
			*)
				;;
		esac
	done
}


cleanDB()
{
	#Clean db tables: tb_policy_event, tb_sandbox_tasks_history, tb_sandbox_task_details
	$PSQL"$TC_POLICY_EVENT" >/dev/null&&$PSQL"$TC_TASK_HISTORY" >/dev/null&&$PSQL"$TC_TASK_DETAIL" >/dev/null
	$PSQL"$TC_FILE_ANALYZE" >/dev/null&&$PSQL"$TC_IMAGES" >/dev/null&&$PSQL"$TC_ACCESS_RECORD" >/dev/null&&$PSQL"$TC_ACCESS_URL" >/dev/null&&$PSQL"$TC_VIOLATED_EVENT" >/dev/null&&$PSQL"$TC_SYS_BEHAVIOR" >/dev/null
	$PSQL"$TC_OBJ_FILE" >/dev/null&&$PSQL"$TC_OBJ_URL" >/dev/null&&$PSQL"$TC_OBJ_HOST" >/dev/null
	$PSQL"$TC_MSG_TRACING" >/dev/null
	echo -e "\tTruncate tables successfully..."
	
	#Backup the maximum id in tb_sandbox_report_file_analyze table
	#MAX_ID=`$PSQL"select max(id) from tb_sandbox_report_file_analyze;" | awk 'NR==3{print}'`
	#echo -e "\tMax id is: $MAX_ID"
}


init()
{
	#Create perf test monitor result folder
	if [ ! -d ${LOG_PATH} ];then
		mkdir -p ${LOG_PATH}${AVG_FOLDER}
		mkdir -p ${LOG_PATH}${BACKUP_FOLDER}
		mkdir -p ${LOG_PATH}${REALTIME_FOLDER}
		mkdir -p ${LOG_PATH}${SUMMARY_FOLDER}
		cp -r ${SCRIPT_FOLDER}/htmlresult/ ${LOG_PATH}
		echo -e "\tCreate $LOG_PATH folder successfully..."
	fi
	
	#check if atop daemon exist or not,if yes, stop it
	ret=`ps -ef | grep 'atop -1 2' | grep -v grep | awk '{print $2}'`
	if [ "$ret" != "" ];then
		kill -9 $ret
		sleep 2
		echo -e "\tKill pid:$ret"
		echo -e "\tStop atop sucessfully..."
	fi	
	
	#Remove atop logs
	#rm -f ${LOG_PATH}atop*	
	#echo -e "\tRemove atop logs..."
	
	#Clean imss log
	imss_log=/opt/trend/ddei/log/log.imss.`date +%Y%m%d`.0001
	> $imss_log
	chown ddei:ddei $imss_log
	echo -e "\tClean imss debug log successfully..."	
	
	#Clean maillog
	> $MAIL_LOG
    > /opt/trend/ddei/MsgTracing/PostLogBookmark.txt
    > /opt/trend/ddei/MsgTracing/PostLogTimestamp.txt
	echo -e "\tClean postfix maillog successfully..."

	#Clean db tables
	cleanDB
	
	#Clear result file
	rm -f ${LOG_PATH}${REALTIME_FOLDER}/*
	rm -f ${LOG_PATH}${AVG_FOLDER}/*
	rm -f ${LOG_PATH}${BACKUP_FOLDER}/*
	rm -f ${LOG_PATH}${SUMMARY_FOLDER}/*
	#> ${LOG_PATH}${REALTIME_FOLDER}${CPU_STAT}
	#> ${LOG_PATH}${REALTIME_FOLDER}${MEM_STAT}
	#> ${LOG_PATH}${REALTIME_FOLDER}${IO_STAT}
	#> ${LOG_PATH}${REALTIME_FOLDER}${QUE_STAT}
	#> ${LOG_PATH}${REALTIME_FOLDER}${PAGE_STAT}
	#> ${LOG_PATH}${REALTIME_FOLDER}${SWAP_STAT}
	#> ${LOG_PATH}${REALTIME_FOLDER}${DISK_STAT}

	#> ${LOG_PATH}${INC_QUE}
    	#> ${LOG_PATH}${ACT_QUE}
 	#> ${LOG_PATH}${DEF_QUE}	
	echo -e "\tClear result file successfully..."

	#Clean defer queue
	postsuper -d ALL > /dev/null 2>&1
	echo -e "\tClean defer queue successfully..."

	service iptables stop > /dev/null
	echo -e "\tStop iptables successfully..."
	
	PID=`ps -ef | grep telnetd | grep -v grep| awk '{print $2}'`

	if [ "$PID" == "" ]
	then
		./telnetd
	fi
	echo -e "\tStart telnetd successfully..."
	
	/opt/trend/ddei/u-sandbox/usandbox/cli/usbxcli.py set-cache --switch OFF > /dev/null
	echo -e "\tDisable sandbox cache successfully..."

	if [ "`grep '192.168' /etc/resolv.conf`" == "" ]
	then
		mv /etc/resolv.conf /etc/resolv.conf.bak
		cp ./resolv.conf /etc/
		cat /etc/resolv.conf.bak | while read line
		do
			echo $line >> /etc/resolv.conf
		done
	fi
	echo -e "\tModify the resolve.conf successfully..."
	
	#extract bc tool to root(/) folder
	ret=`find /usr/bin/ -name 'bc'`
	if [ "$ret" == "" ]
	then
		unzip -o -d / ./bc-1.06.95-1-i686.pkg.zip > /dev/null
	fi
	echo -e "\tInstall bc tool successfully..."
}

startup()
{
	#Start atop	
	#${ATOP_WRI}${LOG_PATH}${ATOP_LOG} &
	#ret=`ps -ef | grep "atop -1 2" | grep -v grep`
	#if [ "$ret" != " " ];then
	#	echo -e "\tStart atop successfully..."
	#else
	#	echo -e "\tStart atop fail..."
	#	return 0
	#fi 	
	
	#Start sandbox queue stat
	./sbxQueStat.sh $1 $2 &
	echo -e "\tStart sandbox queue stat..."
	
	#Start CPU stat
	sar -u $2 $1 > ${LOG_PATH}${REALTIME_FOLDER}${CPU_STAT} &
	#Start Queue stat
	sar -q $2 $1 > ${LOG_PATH}${REALTIME_FOLDER}${QUE_STAT} &
	#Start Memory stat
	sar -r $2 $1 > ${LOG_PATH}${REALTIME_FOLDER}${MEM_STAT} &
	#Start paging stat
	sar -B $2 $1 > ${LOG_PATH}${REALTIME_FOLDER}${PAGE_STAT} &
	#Start swapping stat
	sar -W $2 $1 > ${LOG_PATH}${REALTIME_FOLDER}${SWAP_STAT} &
	#Start I/O stat
	sar -b $2 $1 > ${LOG_PATH}${REALTIME_FOLDER}${IO_STAT} &
	#Start disk stat
	sar -d $2 $1 -p > ${LOG_PATH}${REALTIME_FOLDER}${DISK_STAT} &
	#Postfix queue stat
	#echo "`find /var/spool/postfix/incoming/ -type f | wc -l 2>/dev/null`" >> ${LOG_PATH}${INC_QUE} 
	#echo "`find /var/spool/postfix/active/ -type f | wc -l 2>/dev/null`" >> ${LOG_PATH}${ACT_QUE} 	
	#echo "`find /var/spool/postfix/defer/ -type f | wc -l 2>/dev/null`" >> ${LOG_PATH}${DEF_QUE} 
	echo -e "\tStart CPU, Memory stat..."
	sleep `expr $1 \* $2`
	
	echo -e "\tMonitor completed..."

}

teardown()
{
	#check if atop daemon exist or not,if yes, stop it
	ret=`ps -ef | grep "atop -1 2" | grep -v grep | awk '{print $2}'`
	#echo "`jobs | grep atop | cut -d ']' -f 1 | sed 's/\[//g'`"
	if [ "$ret" != "" ];then
		kill -9 $ret >/dev/null 2>&1
		sleep 2
		ret=`ps -ef | grep "atop -1 2" | grep -v grep`
		if [ "$ret" == "" ];then
			echo -e "\tStop atop sucessfully..."
		else
			echo -e "\tStop atop fail..."		
		fi
	fi

	#Collect the atop data
	#Mem usage
	#echo "`atop -r ${LOG_PATH}/atop_*| grep MEM | cut -d '|' -f3,4 | sed 's/|//g'|sed 's/[MG]//g'`" >> ${LOG_PATH}${MEM_STAT}
	#echo -e "\tCollect memory stat successfully..."		


	#filter out the average value
	sleep 2
	ls $LOG_PATH$REALTIME_FOLDER | while read file
	do
		grep "Aver" $LOG_PATH$REALTIME_FOLDER$file > /dev/null
		ret=$?
		if [ $ret == 0  ]
		then
			grep "Aver" $LOG_PATH$REALTIME_FOLDER$file > $LOG_PATH$AVG_FOLDER$file
		fi 
	done
	

	#Calculate the average value
	calcAvgSysRes $LOG_PATH$SUMMARY_FOLDER$SYS_SUM
	
	#summary db
	dbStatic $LOG_PATH$SUMMARY_FOLDER$DB_SUM	
		
	#backup db
	/opt/trend/ddei/PostgreSQL/bin/pg_dump -a --insert -t tb_policy_event -t tb_sandbox_tasks_history -t tb_sandbox_task_details -t tb_sandbox_report_file_analyze -t tb_msg_tracing -f $LOG_PATH$BACKUP_FOLDER/db_`date +%Y%m%d%H%M%S`.sql ddei -U sa

	#format the real time result
	formatRTRet

	#Generate the final html result
	${SCRIPT_FOLDER}/parseResult.py
}

collectRes()
{
	#zip statistic files 
	zip -r $1/$2.zip $LOG_PATH >/dev/null
}

main()
{
	#initialize
	echo "Initialize monitor environment..."
	init
	#start to monitor
	echo "Start to monitor..."
	startup $1 $2
	#Collect data and clear the result
	echo "Stop monitor..."
	echo "Wait for teardown..."
	teardown
	sleep 5
	echo "Test completed..."	
}

usage()
{
	echo "mainEntry.sh actions [count, interval] [result_folder] [result_name]"
	echo -e "  actions:"
	echo -e "    init: \tinitialize the environment"
	echo -e "    clean: \tjust clean up the DB before each run"
	echo -e "    start: \tstart the main routines"
	echo -e "    clt: \tcollect the performance result after each run"
	echo -e "  options:"
        echo -e "    count:     \t # of sampling"
	echo -e "    interval:  \t sampling interval"
	echo -e "    result_folder: the folder which is used to store all of the performance results"
	echo -e "    result_name: the file name which includes all of the performance results"
	echo -e "Note:" 
	echo -e "  1. option 'count' and 'interval' should be used together."
	echo -e "  2. action 'clt' should be followed by option 'result_folder' and 'result_name'."
	echo -e "Example:"
	echo -e "\tmainEntry.sh start 100 2  (means do sampling every 2 seconds and total sampling 100 times)"
}

#Main entry
case $1 in
	init) 
		init
		;;
	clean)
		cleanDB
		;;
	start)
		if [ $# -lt 3 ]
		then
			usage
			exit
		fi
		main $2 $3
		;;
	clt)
		if [ $# -lt 3 ]
		then
			usage
			exit
		fi
		collectRes $2 $3
		;;
	calc)
		calcAvgSysRes
		;;
	sumdb)
		dbStatic $2
		;;
	format)
		formatRTRet
		;;
	*) 
		echo "Input parameter error..."
		usage
		exit
		;;
esac
