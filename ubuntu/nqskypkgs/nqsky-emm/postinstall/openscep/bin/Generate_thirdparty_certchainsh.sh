#! /bin/sh 
#
# set up a http server cert for apache, and do all configuration
#
# (c) 2012 NetQin Inc.
#
#

openscepdir=/usr/local/openscep/etc

while getopts ":f" opt;
do
      case $opt in
            f)
            force=1
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

rootcert=${openscepdir}/ThirdPartyRootCA.pem
intermediatecert=${openscepdir}/ThirdPartyIntermediateCert.pem
nqRootCA=${openscepdir}/SCEPRootCA.pem
nqRootKey=${openscepdir}/SCEPRootKey.pem
thirdpartyCa=${openscepdir}/ThirdPartyCA.pem
thirdpartyKey=${openscepdir}/ThirdPartyKey.pem
chain=${openscepdir}/certchain.pem

cat ${thirdpartyCa} > ${nqRootCA}
cat ${thirdpartyKey} > ${nqRootKey}

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
if [ ! -e ${rootcert} ]
then
  echo "Third Party root certificate (${rootcert} is not exist."
  exit 1
fi

if [ ! -e ${intermediatecert} ]
then
  echo "Third Party intermediatecert certificate (${intermediatecert} is not exist."
  exit 1
fi

if [ ! -e ${nqRootCA} ]
then
  echo "NetQin Root certificate (${nqRootCA} is not exist."
  exit 1
fi

cat ${intermediatecert} > ${chain}
cat ${rootcert} >> ${chain}

exit 0
