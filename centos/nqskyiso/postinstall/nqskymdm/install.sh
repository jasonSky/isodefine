#!/bin/sh
SCRIPT=$(readlink -f $0)
BASEPATH=$(dirname ${SCRIPT})

function start_mongod() {
  #sudo -u mongod -H sh -c "/usr/bin/mongod -f /etc/mongod.conf --smallfiles &"
  chkconfig mongod on
  service mongod start
}

function start_tomcat() {
  chkconfig tomcat on
  service tomcat restart
}

function start_nginx() {
  systemctl enable nginx.service
}

function sshconfig() {
  sed -i -e "s/Subsystem/#Subsystem/g" /etc/ssh/sshd_config
  echo "Subsystem sftp internal-sftp" >>  /etc/ssh/sshd_config
  dos2unix  /etc/ssh/sshd_config
  systemctl restart sshd
}

start_tomcat
start_mongod
start_nginx
#sleep 90
cp -f /opt/deployment/log4j.xml /opt/emm/current/tomcat/webapps/IDS/WEB-INF/ 
cd /opt/deployment && /usr/bin/sudo sh setup_main.sh 192.168.199.199 premise
#sshconfig

echo 'net.ipv4.tcp_tw_reuse = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_tw_recycle = 1' >> /etc/sysctl.conf
/sbin/sysctl -p
