#!/bin/sh
SCRIPT=$(readlink -f $0)
BASEPATH=$(dirname ${SCRIPT})

function start_tomcat() {
  chkconfig tomcat on
  service tomcat restart
}

function start_nginx() {
  systemctl enable nginx.service
}

start_tomcat
start_nginx
cp -f /opt/deployment/log4j.xml /opt/emm/current/tomcat/webapps/IDS/WEB-INF/ 
cd /opt/deployment && /usr/bin/sudo sh setup_main.sh 192.168.199.199 premise

echo 'net.ipv4.tcp_tw_reuse = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_tw_recycle = 1' >> /etc/sysctl.conf
/sbin/sysctl -p
