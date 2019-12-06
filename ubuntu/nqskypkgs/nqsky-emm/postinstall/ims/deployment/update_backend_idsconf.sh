#!/bin/sh

#===============================================================================
#
#          FILE:  update_backend_idsconf.sh
#
##   DESCRIPTION:  script to update backend ids.properies using initial data.. 
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

if [ $# == 1 ]; then
	MONGODB_HOST="127.0.0.1"
elif [ $# == 2 ]; then
	MONGODB_HOST=$2
else
	echo "Usage: $0 <EMMSERVERIP>"
exit
fi

SERVER_IP=$1
TOMCAT_DIR=/opt/emm/current/tomcat
IDS_PROPERTIES_FILE=/opt/emm/current/config/backend/ids.properties
BL_API_SCHEMA=http
BL_API_PORT=8080
IDS_API_SCHEMA=http
IDS_API_PORT=8080
IDS_SERVER_SCHEMA=https
IDS_SERVER_PORT=443

echo "MONGODB_HOST $MONGODB_HOST"

tail -4 fetch_mongoDB > config
sed -i '1s/^/ids.tokenagent.clientid=/g' config
sed -i '2s/^/ids.tokenagent.clientcredentials=/g' config
sed -i '3s/^/ids.emmserver.clientid=/g' config
sed -i '4s/^/ids.emmserver.clientcredentials=/g' config

echo "emmserver.api.url=$BL_API_SCHEMA://127.0.0.1:$BL_API_PORT/mdm" >> config
echo "idsserver.api.url=$IDS_API_SCHEMA://127.0.0.1:$IDS_API_PORT/IDS" >>config
echo "emm.server.url=$SERVER_IP" >>config
echo "ids.server.url=$IDS_SERVER_SCHEMA://$SERVER_IP:$IDS_SERVER_PORT/IDS" >> config

#existOrNot=`grep ids.tokenagent.clientid= $IDS_PROPERTIES_FILE |wc -c`

	sed -i '/emmserver.api.url=/d' $IDS_PROPERTIES_FILE 
	sed -i '/idsserver.api.url=/d' $IDS_PROPERTIES_FILE 
	
	sed -i '/emm.server.url=/d' $IDS_PROPERTIES_FILE 
	sed -i '/ids.server.url=/d' $IDS_PROPERTIES_FILE 

	sed -i '/ids.tokenagent.clientid=/d' $IDS_PROPERTIES_FILE 
	sed -i '/ids.tokenagent.clientcredentials=/d' $IDS_PROPERTIES_FILE 
	sed -i '/ids.emmserver.clientid=/d' $IDS_PROPERTIES_FILE 
	sed -i '/ids.emmserver.clientcredentials=/d' $IDS_PROPERTIES_FILE 
	
	cat config>>$IDS_PROPERTIES_FILE
