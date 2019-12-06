#!/bin/sh
SCRIPT=$(readlink -f $0)
BASEPATH=$(dirname ${SCRIPT})
#nationskymgmt user needs rbash, who is a restricted user.
ln -sf /bin/bash /bin/rbash

echo 'export PATH=$HOME/bin' >> /home/Nationskymgt/.bash_profile
mkdir -p /home/Nationskymgt/bin
cp $BASEPATH/help /home/Nationskymgt/bin/
ln -s /usr/sbin/ifconfig /home/Nationskymgt/bin/ifconfig
ln -s /usr/bin/ping /home/Nationskymgt/bin/ping
ln -s /usr/bin/tracepath /home/Nationskymgt/bin/tracepath
ln -s /usr/bin/cat /home/Nationskymgt/bin/cat
ln -s /usr/bin/tailf /home/Nationskymgt/bin/tailf
ln -s /usr/bin/tail /home/Nationskymgt/bin/tail
ln -s /usr/bin/vi /home/Nationskymgt/bin/vi
ln -s /usr/bin/grep /home/Nationskymgt/bin/grep
ln -s /usr/bin/ps /home/Nationskymgt/bin/ps
ln -s /usr/bin/ls /home/Nationskymgt/bin/ls
ln -s /usr/bin/telnet /home/Nationskymgt/bin/telnet
ln -s /usr/bin/clear /home/Nationskymgt/bin/clear


echo "enable -n alias bg bind break builtin caller command compgen complete compopt continue declare dirs disown echo enable eval exec export false fc fg getopts hash help history jobs kill let local logout mapfile popd pushd pwd read readarray readonly return set shift shopt source suspend test times trap true type typeset ulimit umask unalias unset wait " >> /home/Nationskymgt/.bash_profile

cat > /home/Nationskymgt/bin/emmnetwork << EOF
#!/bin/bash
/usr/bin/sudo /usr/bin/emmnetwork
EOF

cat > /home/Nationskymgt/bin/emmconfig << EOF
#!/bin/bash
/usr/bin/sudo /usr/bin/emmconfig \$1 \$2
EOF

cat > /home/Nationskymgt/bin/emmfirewall << EOF
#!/bin/bash
echo "Please input insideproxy ip"
/usr/bin/sudo sh /usr/local/bin/nqutils/emm/config_firewall.sh \$1
EOF

cat > /home/Nationskymgt/bin/emmport << EOF
#!/bin/bash
/usr/bin/sudo /usr/bin/emmport
EOF

cat > /home/Nationskymgt/bin/nqskymdm << EOF
#!/bin/bash
/usr/bin/sudo /usr/bin/nqskymdm
EOF

cat > /home/Nationskymgt/bin/emmims << EOF
#!/bin/bash
if [ "\$1" == "" ]; then
        echo "Error: no argument"
        echo "Usage: emmims <emmserverip>"
        exit 1
fi
command1=\`echo "show dbs;" | /usr/bin/mongo 127.0.0.1/admin -u ids -p ids --shell |/usr/bin/grep ids-server\`
command2=\`echo "show dbs;" | /usr/bin/mongo 127.0.0.1/admin -u ids -p ids --shell |/usr/bin/grep ids-demand-ns\`
if [[ ! -z "\${command1}" ]];then
   echo "ids-server"
   cd /opt/deployment && /usr/bin/sudo sh drop_mongoDB.sh ids-server
   /usr/bin/sudo rm -rf /opt/emm/current/tomcat/webapps/IDS
   /usr/bin/sudo service tomcat restart
fi
if [[ ! -z "\${command2}" ]];then
   echo "ids-demand-ns"
   cd /opt/deployment && /usr/bin/sudo sh drop_mongoDB.sh ids-demand-ns
   /usr/bin/sudo rm -rf /opt/emm/current/tomcat/webapps/IDS
   /usr/bin/sudo service tomcat restart
fi

if [[ -z "\${command1}" ]] && [[ -z "\${command2}" ]];then
   if [ -d /opt/emm/current/tomcat/webapps/IDS ];then
      /usr/bin/sudo rm -rf /opt/emm/current/tomcat/webapps/IDS
      /usr/bin/sudo service tomcat restart
   fi
fi

cd /opt/deployment && /usr/bin/sudo sh setup_main.sh \$1 premise
EOF

cat > /home/Nationskymgt/bin/emmcert << EOF
#!/bin/bash
haproxycert() {
if [ ! -d /home/Nationskymgt ];then
   /usr/bin/mkdir -p /home/Nationskymgt
fi
read -p "Please input outsideproxy ip:" proxyIP
/usr/bin/sudo sh /usr/local/openscep/bin/OpenSCEPSetupRootCA.sh -f
/usr/bin/sudo sh /usr/local/openscep/bin/OpenSCEPSetupIntermediateCA.sh -f
/usr/bin/sudo sh /usr/local/openscep/bin/Generate_apache_cert.sh -f -h \$proxyIP
/usr/bin/sudo service tomcat restart
/usr/bin/sudo /usr/bin/cp -f /etc/pki/tls/certs/localhost.crt /home/Nationskymgt/localhost.crt
/usr/bin/sudo sed -i '/^-----BEGIN RSA PRIVATE KEY-----/,/^-----END RSA PRIVATE KEY-----/d' /home/Nationskymgt/localhost.crt
/usr/bin/sudo cat /home/Nationskymgt/localhost.crt /etc/pki/tls/private/localhost.key > /home/Nationskymgt/bmx.pem
#/usr/bin/sudo /usr/bin/openssl dhparam -out dhparams.pem 2048
/usr/bin/sudo cat /usr/local/nginx/conf/dhparams.pem >> /home/Nationskymgt/bmx.pem
}
scpcert() {
read -p "Please input proxy insideip:" proxyIP
read -p "Please input proxy address ssh port(22):" port
#read -p "Please input scp proxy address path:" path
if /usr/bin/sudo grep \$proxyIP  /root/.ssh/known_hosts > /dev/null 2>&1; then
   /usr/bin/sudo /usr/bin/sed -i '/'"\$proxyIP"'/'d /root/.ssh/known_hosts
fi
/usr/bin/sudo scp -P \$port /home/Nationskymgt/bmx.pem Nationskymgt@\$proxyIP:/home/Nationskymgt/
/usr/bin/sudo ssh -p \$port Nationskymgt@\$proxyIP
}
selection=
until [ "\$selection" = "0" ]; do
    echo ""
    echo "1 - creat localhost.cert"
    echo "2 - scp cert to haproxy address"
    #echo "3 - creat client cert"
    echo "0 - Exit program"
    echo ""
    echo -e -n "Enter selection: "
    read selection
    echo ""
case \$selection in
        1 ) haproxycert;;
        2 ) scpcert;;
        #3 ) clientcert;;
        0 ) exit;;
        * ) echo -e "\033[31m Please select correct module ! \033[0m"
esac
done
EOF

cat > /home/Nationskymgt/bin/passwd << EOF
#!/bin/bash
/usr/bin/sudo /usr/bin/passwd Nationskymgt
EOF

cat > /home/Nationskymgt/bin/reboot << EOF
#!/bin/bash
/usr/bin/sudo /usr/sbin/reboot
EOF

cat > /home/Nationskymgt/bin/systemctl << EOF
#!/bin/bash
/usr/bin/sudo /usr/bin/systemctl \$1 \$2
EOF

cat > /home/Nationskymgt/bin/service << EOF
#!/bin/bash
/usr/bin/sudo /usr/sbin/service \$1 \$2
EOF

cat > /home/Nationskymgt/bin/kill << EOF                                                                                                                    
#!/bin/bash                                                                                                                                                    
/usr/bin/sudo /usr/bin/kill \$1 \$2                                                                                                                        
EOF

cat > /home/Nationskymgt/bin/emmcloud << EOF
#!/bin/bash
/usr/bin/sudo sh /usr/local/bin/premisetocloud
EOF

cat > /home/Nationskymgt/bin/emmdate << EOF
#!/bin/bash
function usage()
{
   echo "Usage: args [-q] [-s date time] [-h]"
   echo -e "-q: display emm server date."
   echo -e "-s: set emm server date and time."
   echo -e "-h: help."
}

if [ \$# -lt 1 ]; then
   usage
   exit 1
else
while getopts :qs:h option
      do
         case "\$option" in
               q)
                  /usr/bin/sudo /usr/bin/date
                  ;;
               s)
                  if [ "\$2" == "" ] || [ "\$3" == "" ]; then
                     echo "Error: no argument"
                     echo "date -s <date> <time>"
                     exit 1
                  fi
                  /usr/bin/sudo /usr/bin/date -s "\$2 \$3"
                  /usr/bin/sudo /usr/sbin/hwclock -w
                  /usr/bin/sudo /usr/sbin/hwclock -r
                  ;;
               h)
                  usage
                  exit 1
                  ;;
               ?)
                  echo "Invalid params \$OPTARG"
                  usage
                  exit 1
                  ;;
               *)
                  usage
                  exit 1
                  ;;
         esac
      done
fi
EOF

chown -R Nationskymgt:Nationskymgt /home/Nationskymgt/bin
chmod a+x /home/Nationskymgt/bin/*
