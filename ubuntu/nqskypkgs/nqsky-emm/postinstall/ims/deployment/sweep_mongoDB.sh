#!/bin/sh


#===============================================================================
#
#          FILE: sweep_mongoDB.sh
# 
#         USAGE:  sweep_mongoDB.sh <DB_NAME=[ids-server|ids-demand-ns]>
# 
#   DESCRIPTION:  script to sweep mongoDB for ids server when prepare to re-deploy ids.war..
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

if [[ $DB_NAME != "ids-server" && $DB_NAME != "ids-demand-ns" ]]; then
 echo "Usage: $0 <DB_NAME=[ids-server|ids-demand-ns]>"
 exit
fi

##drop database and user.
mongo --host $MONGODB_HOST <<EOF
use admin
db.auth("ids","ids")
use $DB_NAME
db.SystemConfiguration.remove( {} )
db.TokenAgent.remove( {} )
db.EmmServerClient.remove( {} )
db.oauth_client_details.remove( {} )
exit
EOF

