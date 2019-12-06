#!/bin/bash
PATH=/sbin:/usr/sbin:/bin:/usr/bin
custompath=`cat /mdmconfig/Daily/directory`
if [ ! -z $1 ]; then
	TARGET_PATH=$1
	echo TARGET_PATH=$TARGET_PATH
else
	TARGET_PATH='/'
fi

mkdir -p ${TARGET_PATH}/$custompath/tomcat
cp -ax tomcat7/*  ${TARGET_PATH}/$custompath/tomcat/

mkdir -p ${TARGET_PATH}/etc/init.d/
/bin/cp -f tomcat ${TARGET_PATH}/etc/init.d/

