%define VERSION  7.0.62
%define RELEASE  0
%define _unpackaged_files_terminate_build       0
%define debug_package %{nil}

Name: tomcat
License: GNU
Version: %{VERSION}
Release: %{RELEASE}
Summary:  A customized tomcat7
Vendor: NQ Mobile Inc.
URL: http://www.nq.com
AutoReq: no
AutoProv: yes
Requires: jdk,coreutils,initscripts,Maintenance
Group: Application/System
Source: tomcat7.tar.gz

%description

%prep
mkdir -p $RPM_BUILD_ROOT
%setup -q

%build

%install
sh install.sh $RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT
rm -rf $RPM_BUILD_DIR/%{name}-%{version}

%pre

if [ ! -d /opt/emm/emm5.3/tomcat ];then
   mkdir -p /opt/emm/emm5.3/tomcat
fi

 groupadd tomcat
 useradd -g tomcat -d /opt/emm/emm5.3/tomcat -s /sbin/nologin tomcat

%post

 chown -R tomcat:tomcat /opt/emm/emm5.3/tomcat
 chown -R tomcat:tomcat /etc/init.d/tomcat
 service tomcat start
 chkconfig tomcat on

%preun
service tomcat stop > /dev/null 2>&1

%postun  
 userdel tomcat
 if [ -f /var/mail/tomcat ];then
    rm -f /var/mail/tomcat 
 fi

%files
#%defattr(-,tomcat,tomcat)
%defattr(-,root,root)

%dir 
/opt/emm/*
/etc/init.d/*
