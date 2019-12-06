#!/bin/sh

#===============================================================================
#
#          FILE:  setup_main.sh
#
#         USAGE:  ./setup_main.sh <EMMServerIP> <DeployMODE=[premise|cloud]>
#
#   DESCRIPTION:  script to config ids on all-in-one machine.
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  FAN BIN
#       VERSION:  1.0
#       CREATED:  03/11/2016 16:26:36 CST
#      REVISION:  ---
#===============================================================================

#check parameter
if [ $# == 2 ]; then
	MONGODB_HOST="127.0.0.1"
elif [ $# == 3 ]; then
	MONGODB_HOST=$3
else
	echo "Usage: $0 <EMMSERVERIP> <DeployMODE=[premise|cloud]> [MONGODB_HOST]"
	exit
fi

SERVER_IP=$1

if [ $2 = "premise" ]; then
DB_NAME=ids-server
elif [ $2 = "cloud" ]; then
DB_NAME=ids-demand-ns
else
 echo "Usage: $0 <EMMSERVERIP> <DeployMODE=[premise|cloud]>"
 exit
fi


echo "***************************************************************************";
echo "			setup mongoDB 						 ";
echo "***************************************************************************";
./setup_mongoDB.sh $DB_NAME $MONGODB_HOST > tmp
isOK=`grep "$DB_NAME.ids" tmp|wc -c`
if [ $isOK -eq 0 ]; then
	echo "FAIL:SETUP MONGODB";
	exit;
fi 
echo "SUCCESS:SETUP MONGODB";


echo "***************************************************************************";
echo "			setup IDS 						 ";
echo "***************************************************************************";
./setup_ids.sh  $DB_NAME $MONGODB_HOST > tmp
isOK=`grep "Install Successful" tmp |wc -c`
if [ $isOK -eq 0 ]; then
	echo "FAIL:SETUP IDS";
	exit;
fi
echo "SUCCESS:SETUP IDS";


echo "***************************************************************************";
echo "			setup ids.properties					 ";
echo "***************************************************************************";
./fetch_mongoDB.sh $DB_NAME $MONGODB_HOST > fetch_mongoDB
./update_backend_idsconf.sh $SERVER_IP $MONGODB_HOST
cat /opt/emm/current/config/backend/ids.properties


echo "***************************************************************************";
echo "*			restart	tomcat						*";
echo "***************************************************************************";
systemctl restart tomcat
