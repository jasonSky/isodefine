#!/bin/sh


#===============================================================================
#
#          FILE:  fetch_mongoDB.sh <DB_NAME=[ids-server|ids-demand-ns]>
#
#   DESCRIPTION:  script to fetch mongoDB initial data. 
#                 script will be called by idsconfig.sh.
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

#check parameter
if [ $# == 1 ]; then
	MONGODB_HOST="127.0.0.1"
elif [ $# == 2 ]; then
	MONGODB_HOST=$2
else
	echo "Usage: $0 <DB_NAME=[ids-server|ids-demand-ns]> [MONGODB_HOST]"
	exit
fi

DB_NAME=$1
echo "MONGODB_HOST:$MONGODB_HOST"
if [[ $DB_NAME != "ids-server" && $DB_NAME != "ids-demand-ns" ]]; then
 echo "Usage: $0 <DB_NAME=[ids-server|ids-demand-ns]>"
 exit
fi

mongo --host $MONGODB_HOST <<EOF
use $DB_NAME;
db.auth("ids","ids");
db.oauth_client_details.findOne({"_id":db.TokenAgent.findOne().clientId})._id;
db.oauth_client_details.findOne({"_id":db.TokenAgent.findOne().clientId}).clientSecret;
db.oauth_client_details.findOne({"_id":db.EmmServerClient.findOne().clientId})._id;
db.oauth_client_details.findOne({"_id":db.EmmServerClient.findOne().clientId}).clientSecret;
exit;
EOF
