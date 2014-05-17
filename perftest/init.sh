#!/bin/sh

service iptables stop
PID=`ps -ef | grep telnetd | grep -v grep| awk '{print $2}'`

if [ "$PID" == "" ]
then
	/root/perf/telnetd
fi

/opt/trend/ddei/u-sandbox/usandbox/cli/usbxcli.py set-cache --switch off
#if [ "`grep '192.168' /etc/resolv.conf`" == "" ]
#then
#	mv /etc/resolv.conf /etc/resolv.conf.bak
#	cp /root/perf/resolv.conf /etc/
#fi
/root/perf/mainEntry.sh init
