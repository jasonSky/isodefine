#!/bin/sh


#===============================================================================
#
#          FILE:  setup_ids.sh
#
#         USAGE:  setup_ids.sh <DB_NAME=[ids-server|ids-demand-ns]>
#
#   DESCRIPTION:  script to config ids server on all-in-one machine.
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

echo "MONGODB_HOST : $MONGODB_HOST "
if [[ $DB_NAME != "ids-server" && $DB_NAME != "ids-demand-ns" ]]; then
 echo "Usage: $0 <DB_NAME=[ids-server|ids-demand-ns]>"
 exit
fi

SERVER_IP=127.0.0.1
SERVER_PORT=8080
SERVER_PROTOCOL=http
SERVER_URL=$SERVER_PROTOCOL://$SERVER_IP:$SERVER_PORT

curl -c cookie $SERVER_URL/IDS/ids_install


curl -b cookie -d "_action=1&mongoHost=$MONGODB_HOST&mongoPort=27017&dbName=$DB_NAME&dbUsername=ids&dbPassword=ids&filePath=/opt/emm/current/tomcat/upload&idsHost=$SERVER_URL/IDS" $SERVER_URL/IDS/ids_install


if [ $DB_NAME = "ids-server" ]; then
curl -b cookie -d "_action=2&emmLoginUri=$SERVER_URL/mdm/sso/emm/verifyUserLogin&accountLinkingURI=$SERVER_URL/mdm/sso/emm/verifyAccountLinking&asServerUri=$SERVER_URL/IDS/oauth/token&tokenAgentAppKey=85eb1adc90b54999b58d22bea7e2843deU9lOGpj&tokenAgentAppSecret=HCTo9DGGGMuigZpRmM13ilTxc1k97NQgfeOsuufh&emmAppKey=6dea49b4b3674d7485b04dbad9ede6e97FZ5Jnfw&emmAppSecret=10tnZ92c2C1iu7AWsUg85wemp7Sk0PIoMGp3uTY6&adminUsername=NQadmin&adminPassword=Nsky@admin" $SERVER_URL/IDS/ids_install
fi

if [ $DB_NAME = "ids-demand-ns" ]; then
curl -b cookie -d "_action=2&emmTokenURI=http://127.0.0.1:8080/mdm/sso/emm/token&emmTokenUsername=ids0302&emmTokenPassword=4I6wsUVLQ&emmLoginUri=$SERVER_URL/mdm/sso/emm/verifyUserLogin&accountLinkingURI=$SERVER_URL/mdm/sso/emm/verifyAccountLinking&asServerUri=$SERVER_URL/IDS/oauth/token&tokenAgentAppKey=85eb1adc90b54999b58d22bea7e2843deU9lOGpj&tokenAgentAppSecret=HCTo9DGGGMuigZpRmM13ilTxc1k97NQgfeOsuufh&emmAppKey=6dea49b4b3674d7485b04dbad9ede6e97FZ5Jnfw&emmAppSecret=10tnZ92c2C1iu7AWsUg85wemp7Sk0PIoMGp3uTY6&adminUsername=admin&adminPassword=admin" $SERVER_URL/IDS/ids_install
fi


