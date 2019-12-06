%define VERSION  5.8.0
%define RELEASE  0
%define _unpackaged_files_terminate_build       0
%define debug_package %{nil}

Name: activemq
License: GNU
Version: %{VERSION}
Release: %{RELEASE}
Summary:  A customized activemq with jdk1.6
Vendor: NQ Mobile Inc.
URL: http://www.nq.com
AutoReq: no
AutoProv: yes
Group: Application/System
Source: activemq-5.8.0.tar.gz


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
service activemq start
chkconfig activemq on

%preun
service activemq stop
chkconfig activemq off

%files
%defattr(-,root,root)

%dir 
/etc/init.d/*
/usr/local/*
