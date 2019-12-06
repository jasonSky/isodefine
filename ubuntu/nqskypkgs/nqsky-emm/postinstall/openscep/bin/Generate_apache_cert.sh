#! /bin/sh 
#
# set up a http server cert for apache, and do all configuration
#
# (c) 2012 NetQin Inc.
#
#

echo `date`"-----------start Generate_apache_cert-----------" >> /usr/local/openscep/bin/gen.log
openscepdir=/usr/local/openscep/etc

while getopts ":h:f" opt;
do
      case $opt in
            f)
            force=1
            ;; 
            h)        
            hostname=$OPTARG
	    #echo hostname=$hostname
	    ;;
            \?)
            echo "Invalid arguments."
            exit 1
            ;;
            :)
            echo "Option -$OPTARG is requires an argument" 
            exit 1
            ;;
      esac
done

rootkey=${openscepdir}/SCEPRootKey.pem
rootcert=${openscepdir}/SCEPRootCA.pem
key=${openscepdir}/apachekey.pem
cert=${openscepdir}/apachecert.pem
SUBJ_PREFIX="/O=NQ/OU=Dev/C=CN/CN="
SERVER_CERT="/etc/pki/tls/certs/localhost.crt"
SERVER_KEY="/etc/pki/tls/private/localhost.key"
CMD="service nginx restart"
if [[ -z "${hostname}" ]]; then
        hostname=`awk 'BEGIN {FS="hostname="}/hostname/{{print $2}}' /opt/emm/current/config/global.properties`
fi

#hostname $hostname
#FQDN=`hostname --all-fqdns`
FQDN="${hostname}"
#echo FQDN=$FQDN
TRIM_FQDN=`echo $FQDN | grep -o "[^ ]\+\( \+[^ ]\+\)*"`

SUBJ=${SUBJ_PREFIX}$TRIM_FQDN"/"

openssl=/usr/bin/openssl
if [ ! -x "${openssl}" ]
then
	echo "It looks as if the path to the OpenSSL binary is not" >&2
	echo "configured correctly. Please verify that the openssl" >&2
	echo "variable in the scepd section of the OpenSCEP configuration" >&2
	echo "file ${openscepdir}/openscep.cnf points to the correct" >&2
	echo "binary (default /usr/local/ssl/bin/openssl), and run" >&2
	echo "openscepsetup again." >&2
	exit 1
fi

# make sure all the directories exist
if [ ! -e ${rootkey} -o  ! -e ${rootcert} ]
then
  echo "root certificate (${rootkey}, ${rootcert}) is not exist."
  exit 1
fi

if [ ! -f ${openscepdir}/openssl.cnf ]; then
  echo "${openscepdir}/openssl.cnf is not exist."
  exit 1
fi
sed -i "s/^.*DNS.1=.*/DNS.1=${hostname}/" ${openscepdir}/openssl.cnf

# if cert or key exist, stop at this point
if [ -r ${cert} -o -r ${key} ]
then
	if [ -z "${force}" ]
	then
		echo certificates exist, remove or use -f flag >&2
		exit 1
	else
		echo overwriting certificates
	fi
fi

#${openssl} req -new -newkey rsa:1024 -config ${openscepdir}/openscep.cnf -out ${openscepdir}/req.pem -keyout ${key} -subj $SUBJ -nodes
${openssl} req -new -newkey rsa:2048 -out ${openscepdir}/req.pem -keyout ${key} -subj $SUBJ -nodes 2>&1

${openssl} x509 -req -in ${openscepdir}/req.pem	-CAkey ${rootkey} -CA ${rootcert} -days 365 -out ${cert} -CAserial ${openscepdir}/serial -extensions v3_req -extfile ${openscepdir}/openssl.cnf 2>&1
#${openssl} x509 -req -in ${openscepdir}/req.pem	-CAkey ${rootkey} -CA ${rootcert} -days 365 -out ${cert} -CAserial ${openscepdir}/serial 2>&1
#${openssl} x509 -req -in ${openscepdir}/req.pem	-CAkey ${rootkey} -CA ${rootcert} -CAserial ${openscepdir}/serial -CAcreateserial -days 3652 -out ${cert}

cat ${rootkey} >> ${cert}
cp -f ${cert} $SERVER_CERT
cp -f ${key} $SERVER_KEY
$CMD

echo `date`"----------- end Generate_apache_cert-----------" >> /usr/local/openscep/bin/gen.log
exit 0
