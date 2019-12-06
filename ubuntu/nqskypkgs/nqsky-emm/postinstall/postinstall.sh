#!/bin/sh
SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname ${SCRIPT})

function post_vsftpd() {
  echo "==> customizing vsftpd ..."

  groupadd ftpgroup
  useradd -g ftpgroup -d /var/ftp -M mdm -s /sbin/nologin
  echo 'mdm:$6$vYeU3H4H$2Fub7puWpV.slFzp/pDgwwf7EgEeGwc4VeWlQodZsuYolf0..fuPFewtKsVwQaheAOZjciw99YMcmWlFGF/co1' | chpasswd -e

  /usr/bin/mkdir -p /var/ftp/mcm_file
  /usr/bin/chmod -R 777 /var/ftp

  setsebool -P ftpd_full_access on
  setsebool -P sftpd_full_access on
  setsebool -P ftp_home_dir on

  /usr/bin/cp -rf /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.nqsky_bak
  /usr/bin/cp -rf ${SCRIPTPATH}/vsftpd/vsftpd.conf /etc/vsftpd/
  /usr/bin/cp -rf ${SCRIPTPATH}/vsftpd/chroot_list /etc/vsftpd/
}

function post_ims() {
  echo "==> installing ims ..."
  cd ${SCRIPTPATH}/ims
  cp -rf ./deployment /opt
  unzip /opt/deployment/resource/IDS\(premise-kerberosConfig\)-20160608.zip
  cp -r ./IDS.war /opt/emm/current/tomcat/webapps/
  chmod a+x /opt/deployment/*.sh
}

# failed to install in ks.cfg %packages.
function post_mongodb() {
  echo "==> installing mongodb ..."
  cd ${SCRIPTPATH}/mongodb/

  /usr/bin/cp -rf /etc/mongodb.conf /etc/mongodb.conf.bak
  /usr/bin/cp -rf mongodb.conf /etc/mongodb.conf
  service mongodb restart
}

function post_lib64_ZZY() {
  echo "==> installing ZZY ..."
  chmod a+x ${SCRIPTPATH}/lib64_ZZY/{aapt,uuzip_v2,libc++.so}
  cp -f ${SCRIPTPATH}/lib64_ZZY/{aapt,uuzip_v2} /usr/bin
  cp -f ${SCRIPTPATH}/lib64_ZZY/libc++.so /usr/lib64/
  cp -rf ${SCRIPTPATH}/silk-v3 /opt/emm/current/source/
  chmod +x /opt/emm/current/source/silk-v3/converter.sh
  chmod +x /opt/emm/current/source/silk-v3/silk/decoder
}

function post_openscep() {
  echo "==> install openscep"
  cp -rf ${SCRIPTPATH}/openscep /usr/local/
}

############################ MAIN #############################
post_vsftpd
post_redis
post_mongodb
post_ims
post_lib64_ZZY
post_openscep

cp -f $SCRIPTPATH/libmdmcurl.so.4.4.0 /usr/lib64/
ln -s /usr/lib64/libmdmcurl.so.4.4.0 /usr/lib64/libmdmcurl.so
ldconfig
if [ -f /usr/local/bin/bemailconfig.sh ];then
   sh /usr/local/bin/bemailconfig.sh
fi

ln -s /usr/local/bin/premisetocloud /usr/bin/emmcloud
chown -R tomcat:tomcat /opt/emm/current/tomcat/
chown -R tomcat:tomcat /data
chown -R tomcat:tomcat /etc/nginx/conf/nginx.conf
chmod 4777 /usr/sbin/ntpdate
chown -R tomcat:tomcat /usr/local/bin/gen_csh.sh
chown -R tomcat:tomcat /usr/local/bin/gen_csh.sh
chown -R tomcat:tomcat /usr/local/bin/import_cert.sh
chown -R tomcat:tomcat /opt/emm/current/cert/MDM/
chown -R tomcat:tomcat /etc/pki/tls/private/
chown -R tomcat:tomcat /etc/pki/tls/certs/
chown -R tomcat:tomcat /opt/emm/current/source/licenseServer/
chown -R tomcat:tomcat /opt/emm/current/config/global.properties
chown -R tomcat:tomcat /usr/local/etc/dbscript/
chown -R tomcat:tomcat /opt/emm/current/config/backend
chown -R tomcat:tomcat /usr/local/bin/audit_file.sh

mkdir -p /data/logs/aio-upgrade/
chown -R tomcat:tomcat /data/logs/aio-upgrade/
st=`cat /etc/sudoers |grep Defaults |grep requiretty`
sed -i '/'"$st"'/d' /etc/sudoers
if ! grep 'tomcat' /etc/sudoers > /dev/null 2>&1; then
     echo "tomcat        ALL=(ALL)       NOPASSWD: ALL" >>  /etc/sudoers
fi
if ! grep 'nationskymgt' /etc/sudoers > /dev/null 2>&1; then
     echo "nationskymgt   ALL=(ALL)     NOPASSWD: /usr/bin/systemctl,/usr/sbin/service,/usr/bin/kill,/usr/bin/date,/usr/bin/passwd,/usr/bin/emmconfig,/usr/bin/emmims,/usr/bin/emmcloud,/usr/bin/emmnetwork,/usr/bin/sh" >>  /etc/sudoers
fi
if ! grep 'emmupgrade' /etc/sudoers > /dev/null 2>&1; then
     echo "emmupgrade     ALL=(ALL)       NOPASSWD: ALL" >>  /etc/sudoers
fi
dos2unix /etc/sudoers

if [ ! -d /emm/logs ];then
    mkdir -p /emm/logs
fi 
chown -R nationskymgt:nationskymgt /emm/logs

#copy ApacheCerts
\cp -f $SCRIPTPATH/ApacheCerts/localhost.crt /etc/pki/tls/certs/
\cp -f $SCRIPTPATH/ApacheCerts/localhost.key /etc/pki/tls/private/
\cp -rf $SCRIPTPATH/ApacheCerts/etc /usr/local/openscep/
chown -R tomcat:tomcat /etc/pki/tls/private/
chown -R tomcat:tomcat /etc/pki/tls/certs/

#copy sshkey
mkdir -p /home/emmupgrade/.ssh
\cp -f $SCRIPTPATH/id_rsa /home/emmupgrade/.ssh
chmod 700 /home/emmupgrade/.ssh
chmod 600 /home/emmupgrade/.ssh/id_rsa
chown -R emmupgrade:emmupgrade /home/emmupgrade/.ssh

#update emmmem config
function emmmem() {
   meminfo=`grep "MemTotal" /proc/meminfo | awk '{print $2}'`
   function emmoption() {
      echo "==> customizing emmserver ..."
      systemctl stop crond
      for pkg in $(dir /usr/local/bin/MemorySetting/$item); do
         if [ $pkg == "activemq" ];then
            echo "copy $pkg service"
            service activemq stop
            cp -f /usr/local/bin/MemorySetting/$item/$pkg/activemq /etc/init.d/activemq
            chmod a+x /etc/init.d/activemq
            systemctl daemon-reload
         elif [ $pkg == "tomcat" ];then
            echo "copy $pkg service"
            service tomcat stop
            cp -f /usr/local/bin/MemorySetting/$item/tomcat/tomcat /etc/init.d/tomcat
            systemctl daemon-reload
            chmod a+x /etc/init.d/tomcat
            chown tomcat:tomcat /etc/init.d/tomcat
         elif [ $pkg == "mysql" ];then
            echo "copy $pkg service"
            systemctl stop mysqld
            cp -f /usr/local/bin/MemorySetting/$item/mysql/my.cnf /etc/
         else
            echo "copy other service"
            cp -f /usr/local/bin/MemorySetting/$item/$pkg/start.sh /opt/emm/current/source/$pkg/
            chmod a+x /opt/emm/current/source/$pkg/start.sh
            chown tomcat:tomcat /opt/emm/current/source/licenseServer/start.sh
         fi
      done
}
   if [ $meminfo -lt 8000000 ];then
      echo "emmserver 4G config"
      item="4G"
      emmoption
   fi
   if [ $meminfo -gt 8000000 ] && [ $meminfo -lt 16000000 ] ;then
      echo "emmserver 8G config"
      item="8G"
      emmoption
   fi
   if [ $meminfo -gt 16000000 ] && [ $meminfo -lt 32000000 ] ;then
      echo "emmserver 16G config"
      item="16G"
      emmoption
   fi
   if [ $meminfo -gt 32000000 ] && [ $meminfo -lt 64000000 ] ;then
      echo "emmserver 32G config"
      item="32G"
      emmoption
   fi
   if [ $meminfo -gt 64000000 ];then
      echo "emmserver 64G config"
      item="64G"
      emmoption
   fi
}

emmuser() {
  chmod -R o+rw /opt/emm/current/
  chmod -R o+rw /data
  chmod -R o+rw /usr/local/apache-activemq-5.8.0/
  chmod -R o+rw /usr/local/etc/
  chmod -R o+rw /etc/nginx/conf/nginx.conf
  service spider restart
  service licserver restart
  service activemq restart
} 

emmmem
emmuser

cd -
sleep 2
