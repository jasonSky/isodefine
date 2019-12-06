%define VERSION  0.4.2
%define RELEASE  0
%define _unpackaged_files_terminate_build       0

Name: openscep
License: GNU
Version: %{VERSION}
Release: %{RELEASE}
Summary:  OpenSCEP server
Vendor: Open Source
URL: http://openscep.othello.ch
AutoReq: no
AutoProv: yes
#Requires: httpd >= 2.2.15 perl-CGI >= 3.49 openssl >= 1.0.0
Requires: openssl >= 0.9.8a openldap-devel >= 2.4.23
Group: Application/System
#BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}
#BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}
Source: openscep-0.4.2.tar.gz
PREFIX: /usr/local/openscep

%description

%prep
mkdir -p $RPM_BUILD_ROOT
%setup -q

%build

%install
make DESTDIR=$RPM_BUILD_ROOT SUBDIR="scep_server" install

%clean
rm -rf $RPM_BUILD_ROOT

%post
if [ ! -f /usr/local/openscep/etc/SCEPRootCA.pem ]; then
	/usr/local/openscep/bin/OpenSCEPSetupRootCA.sh
fi

if [ ! -f /usr/local/openscep/etc/cacert.pem ]; then
	/usr/local/openscep/bin/OpenSCEPSetupIntermediateCA.sh
fi

if [ ! -f /etc/pki/tls/certs/localhost.crt ]; then
	/usr/local/openscep/bin/Generate_apache_cert.sh -f	
fi

cp /usr/local/openscep/bin/pkiclient.exe /var/www/cgi-bin/

if [ -x %{PREFIX}/sbin/openscepsetup ]
then
   %{PREFIX}/sbin/openscepsetup
fi

if [ -f /etc/syslog.conf ]; then
	if  ! grep local2 /etc/syslog.conf > /dev/null 2>&1; then
 		echo "local2.*        /var/log/scep.log" >> /etc/syslog.conf
		service syslog restart
	fi
elif [ -f /etc/rsyslog.conf ]; then
	if  ! grep local2 /etc/rsyslog.conf > /dev/null 2>&1; then
		echo "local2.*        /var/log/scep.log" >> /etc/rsyslog.conf
		service rsyslog restart
	fi
fi

%preun



%files
%defattr(-,root,root)
%dir 
/usr/local/openscep
/usr/local/openscep/*
