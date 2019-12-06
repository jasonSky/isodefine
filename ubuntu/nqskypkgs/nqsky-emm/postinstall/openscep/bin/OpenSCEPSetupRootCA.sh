#! /bin/sh
#
# set up a CA suitable for OpenSCEP
#
# (c) 2011 Websense,.Inc.
#
#
openscepdir="/usr/local/openscep/etc/"
SUBJ="/O=NQ/OU=Dev/C=CN/CN=InternalCA/"
caowner=apache
cagroup=apache
rootkey=${openscepdir}/SCEPRootKey.pem
rootcert=${openscepdir}/SCEPRootCA.pem
csr=${openscepdir}/csr.pem
certchain=${openscepdir}/certchain.pem

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

# does the configuration directory exists?
if [ ! -d ${openscepdir} ]
then
	mkdir -p ${openscepdir}
	chmod +t ${openscepdir}
	#chown ${caowner} ${openscepdir}
	#chgrp ${cagroup} ${openscepdir}
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


# if cacert and cakey exist, stop at this point
if [ -r ${rootcert} -o -r ${rootkey} ]
then
	if [ -z "${force}" ]
	then
		echo certificates:${rootcert} exist, remove or use -f flag >&2
		exit 1
	else
		echo overwriting certificates
	fi
fi

#creating root ca
# 1. create key
openssl genrsa -out ${rootkey} 2048
# 3. issue a self-signed ca cert
openssl req -new -x509 -subj $SUBJ -config ${openscepdir}/openscep.cnf -days 3652 -key ${rootkey} -out ${rootcert}
cat ${rootcert} > ${certchain}
#rm -f $csr
exit 0
