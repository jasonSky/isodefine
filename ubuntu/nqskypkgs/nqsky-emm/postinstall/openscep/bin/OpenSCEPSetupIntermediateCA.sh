#! /bin/sh 
#
# set up a CA suitable for OpenSCEP
#
# (c) 2011 Nq Inc.
#
#

openscepdir="/usr/local/openscep/etc"
while getopts ":d:f" opt;
do
      case $opt in
            f)
            force=1
            ;; 
            d)        
            openscepdir=$OPTARG;;
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

caowner=apache
cagroup=apache
rootkey=${openscepdir}/SCEPRootKey.pem
rootcert=${openscepdir}/SCEPRootCA.pem
scepkey=${openscepdir}/cakey.pem
scepcert=${openscepdir}/cacert.pem
SUBJ="/O=NQ/OU=Dev/C=CN/CN=SCEPCA/"

# does the configuration directory exists?
if [ ! -d ${openscepdir} ]
then
	mkdir -p ${openscepdir}
	chmod +t ${openscepdir}
	#chown ${caowner} ${openscepdir}
	#chgrp ${cagroup} ${openscepdir}
fi

# does the configuration file exists? 
if [ ! -r ${openscepdir}/openscep.cnf ]
then
      echo configuration file ${openscepdir}/openscep.cnf does not exist >&2
      exit 1
fi

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


#generate a random seed file
rm -rf ${openscepdir}/.rnd
${openssl} rand -rand /etc/passwd:/etc/hosts:/etc/services:/etc/inetd.conf \
	-out ${openscepdir}/.rnd 2048
#chown ${caowner}:${cagroup} ${openscepdir}/.rnd

# make sure all the directories exist
if [ ! -e ${rootkey} -o  ! -e ${rootcert} ]
then
  echo "root certificate (${rootkey}, ${rootcert}) is not exist."
  exit 1
fi

# if cacert and cakey exist, stop at this point
if [ -r ${scepcert} -o -r ${scepkey} ]
then
	if [ -z "${force}" ]
	then
		echo certificates exist, remove or use -f flag >&2
		exit 1
	else
		echo overwriting certificates
	fi
fi
rm -f ${openscepdir}/serial
> ${openscepdir}/index.txt
#chown ${caowner} ${openscepdir}/index.txt
#chgrp ${cagroup} ${openscepdir}/index.txt

trap "rm -f ${openscepdir}/careq.pem" 0 1 2 15

# create ca certificate
# 1. create a request, due to the option -nodes, the key will not be
#    encrypted
${openssl} req -new -newkey rsa:2048 					\
	-config ${openscepdir}/openscep.cnf 				\
	-out ${openscepdir}/careq.pem -keyout ${scepkey}	\
	-nodes -subj $SUBJ

# 2. create final signed with root ca certificate
${openssl} x509 -req -in ${openscepdir}/careq.pem			\
	-CAkey ${rootkey} -CA ${rootcert}	\
	-CAserial ${openscepdir}/serial -CAcreateserial			\
	-extfile ${openscepdir}/openscep.cnf -extensions v3_ca		\
	-days 3652 -out ${scepcert}
${openssl} x509 -in ${scepcert} 				\
	-out ${openscepdir}/cacert.der -outform DER
#
#
# create an empty crl
${openssl} ca -config ${openscepdir}/openscep.cnf -gencrl              \
       -crldays 10                                                     \
       -cert ${scepcert}                                \
       -keyfile ${scepkey}                              \
       -out ${openscepdir}/crl.pem
${openssl} crl -in ${openscepdir}/crl.pem                              \
       -out ${openscepdir}/crl.der -outform DER

# that's it
exit 0
