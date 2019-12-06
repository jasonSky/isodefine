#!/bin/sh


#===============================================================================
#
#          FILE:  setup_mongoDB.sh
# 
#         USAGE:  setup_mongoDB.sh <DB_NAME=[ids-server|ids-demand-ns]>
# 
#   DESCRIPTION:  script to setup mongoDB for ids server.
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

echo "MONGODB_HOST : $MONGODB_HOST"

if [[ $DB_NAME != "ids-server" && $DB_NAME != "ids-demand-ns" ]]; then
 echo "Usage: $0 <DB_NAME=[ids-server|ids-demand-ns]>"
 exit
fi

if [[ $MONGODB_HOST == "127.0.0.1" ]]; then
##mongod start with noauth.
 systemctl stop mongod
 sed -i 's/^auth=true$/#auth=true/g' /etc/mongod.conf 
 systemctl start mongod
fi

##create mongod admin user
mongo --host $MONGODB_HOST <<EOF
use admin
db.addUser("ids","ids")
show users
exit
EOF

if [[ $MONGODB_HOST == "127.0.0.1" ]]; then
##create database and user.
 systemctl stop mongod
 sed -i 's/^#auth=true$/auth=true/g' /etc/mongod.conf
 systemctl start mongod
fi

mongo  --host $MONGODB_HOST <<EOF
use admin
db.auth("ids","ids")
use $DB_NAME
db.addUser("ids","ids")
show users
exit
EOF

