#!/bin/bash
PATH=/sbin:/usr/sbin:/bin:/usr/bin

if [ ! -z $1 ]; then
	TARGET_PATH=$1
	echo TARGET_PATH=$TARGET_PATH
else
	TARGET_PATH='/'
fi


mkdir -p ${TARGET_PATH}/usr/local/
cp -ax apache-activemq-5.8.0 ${TARGET_PATH}/usr/local/


mkdir -p ${TARGET_PATH}/etc/init.d/
/bin/cp -f activemq ${TARGET_PATH}/etc/init.d/
