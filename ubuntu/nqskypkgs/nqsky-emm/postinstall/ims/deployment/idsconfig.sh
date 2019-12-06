#!/bin/sh


#===============================================================================
#
#          FILE:  idsconfig.sh
#
#         USAGE:  ./idsconfig.sh <EMMSERVERIP> <DeployMODE=[premise|cloud]>
#
#   DESCRIPTION:  script to config backend ids.properties on all-in-one machine.
#		  script is entrance program, which will call fetch_mongoDB.sh 
#                 and update_backedn_idsconf.sh		
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  FAN BIN
#       VERSION:  1.0
#       CREATED:  03/10/2016 16:26:36 CST
#      REVISION:  ---
#===============================================================================

#check param
if [ $# == 2 ]; then
	MONGODB_HOST="127.0.0.1"
elif [ $# == 3 ]; then
	MONGODB_HOST=$3
else
	echo "Usage: $0 <EMMSERVERIP> <DeployMODE=[premise|cloud]>"
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

./fetch_mongoDB.sh $DB_NAME $MONGODB_HOST > fetch_mongoDB
./update_backend_idsconf.sh $SERVER_IP $MONGODB_HOST
cat /opt/emm/current/config/backend/ids.properties

service tomcat restart