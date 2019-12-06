%define VERSION  5.3.0.159
%define RELEASE  0
%define _unpackaged_files_terminate_build       0
%define debug_package %{nil}

Name: AppServer
License: GNU
Version: %{VERSION}
Release: %{RELEASE}
Summary: NQ MDM AppServer
Vendor: NQ Mobile Inc.
URL: http://www.nq.com
AutoReq: no
AutoProv: yes
#Requires: tomcat
Group: Application/System
Source: AppServer.tar.gz


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
%post
chkconfig AppServer on
service AppServer start
%preun
service AppServer stop
chkconfig AppServer off
%files
%defattr(-,root,root)
#%defattr(-,tomcat,tomcat)
%dir 
/opt/emm/*
/etc/init.d/*
