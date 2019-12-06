#!/bin/sh
#try-to-standarlize
mkdir -p /usr/local/java 
ln -sf /usr/local/jdk18 /usr/local/java/default 

#mkdir -p /usr/local/tomcat
#ln -sf /usr/local/tomcat7 /usr/local/tomcat/default 

#configuration
mkdir -p /etc/nqsky.d
mkdir -p /etc/nqsky.d/emm
#mkdir -p /etc/nqsky.d/emm/{proxygrant,backend,pushd,pushsvc}

#logs
#EMM_LOG_DIR=/var/log/nqsky/emm
#mkdir -p ${EMM_LOG_DIR}
#compability link
#ln -sf /opt/Platform_java/log ${EMM_LOG_DIR}/platform
#ln -sf /usr/local/tomcat/default/logs ${EMM_LOG_DIR}/backend
#ln -sf /usr/local/tomcat/default/logs ${EMM_LOG_DIR}/nqclientupdate

#mcm logs
#ln -sf /opt/mcmServer/logs ${EMM_LOG_DIR}/mcm

#license server logs
#ln -sf /opt/licenseServer/logs ${EMM_LOG_DIR}/license-srv

#job manager logs
#ln -sf /opt/jobmanager/logs ${EMM_LOG_DIR}/jobmgr

#pushd logs
#mkdir -p ${EMM_LOG_DIR}/pushd
#ln -sf /var/logs/pushd.log ${EMM_LOG_DIR}/pushd/pushd.log

#remote control server logs
#ln -sf /opt/channelServer/logs ${EMM_LOG_DIR}/channel-srv

#proxy grant server logs
#ln -sf /opt/proxyGrant/logs/ ${EMM_LOG_DIR}/proxygrant

mkdir -p ${EMM_LOG_DIR}/scep
ln -sf /var/log/message.log ${EMM_LOG_DIR}/scep/message.log
ln -sf /var/log/scep.log ${EMM_LOG_DIR}/scep/scep.log

#nginx
ln -sf /var/log/nginx ${EMM_LOG_DIR}/nginx

#mysql
mkdir -p ${EMM_LOG_DIR}/mysql
ln -sf /var/lib/mysql/localhost.err ${EMM_LOG_DIR}/mysql/localhost.err

#tomcat
#ln -sf /usr/local/tomcat/default/logs ${EMM_LOG_DIR}/tomcat

#redis
ln -sf /var/log/redis ${EMM_LOG_DIR}/redis

#activemq, also includes kahadb data 
ln -sf /usr/local/apache-activemq-5.8.0/data ${EMM_LOG_DIR}/activemq
