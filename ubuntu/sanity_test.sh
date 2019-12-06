#!/bin/sh
#nqsky iso sanity check 

############################## utility ##############################
#print INFO level log.
function info() {
    echo "[INFO]  [$(date '+%F-%T')] $1"
}

#print as an separator
function banner() {
    info "==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>"
    info "$1"
    info "==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>==>"
}


#print error msg in red to stderr.
function err(){
    echo -e "\e[31m[ERROR] [$(date '+%F-%T')] $@\e[0m" 1>&2
}

function check_rpm_installed() {
    info "rpm pkg $1 is installed ? ..."
    local pkg="$1"
    rpm -q "${pkg}" &>/dev/null
    if [[ $? -eq 0 ]]; then
        info "YES: $pkg installed"
        return 0
    else
        err "NO: $pkg not installed"
        return 1
    fi
}

function check_cmd() {
  info "cmd $1 is installed ? ..."
  if [[ $(command -v $1) ]]; then
    info "YES: cmd $1 found"
    return 0
  else
    err "NO: cmd $1 not found."
    return 1
  fi
}

function check_service_enabled() {
  info "service $1 is enabled ? ..."
  if [[ $(systemctl is-enabled $1 1>/dev/null 2>&1) -eq 0 ]]; then
    info "YES: service $1 is enabled"
  else
    err "NO: service $1 is disabled"
  fi
}

function check_service_running() {
  info "service $1 is running? ..."
  if [[ $(systemctl status $1 1>/dev/null 2>&1) -eq 0 ]]; then
    info "YES: service $1 is running"
  else
    err "NO: service $1 is not running"
  fi
}

function check_firewall_port() {
  info "Checking firewall port $1 ..."
}

function check_listening_port() {
  info "Checking listening port $1 ..."
  local tmp=tmp.${RANDOM}
  echo exit | telnet localhost $1 &>${tmp}
  grep 'Connection refused' ${tmp} &>/dev/null
  if [[ $? -eq 0 ]]; then
    err "NO: port $1 is not listening"
  else
    info "YES: listening port $1"
  fi
  rm -rf ${tmp}
}

function check_curl() {
  info "curl working ?..."
  check_cmd curl
  if [[ $? -eq 0 ]]; then
    curl www.sina.com.cn 1>/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
      info "YES: curl is GOOD"
    else
      err "NO: curl was broken"
    fi  
  fi
}

function check_mysql() {
  banner "MySQL working ?..."
  PKGS=(MySQL-server MySQL-client)
  for pkg in ${PKGS[@]}; do
    check_rpm_installed $pkg
  done
  check_service_running mysqld
  check_service_running mysqld
  check_listening_port 3306
}

function check_tomcat() {
  banner "Tomcat working ?..."
  PKGS=(tomcat tomcat-native)
  for pkg in ${PKGS[@]}; do
    check_rpm_installed $pkg
  done

  check_service_running tomcat
  check_service_enabled tomcat
  check_listening_port 8080
}

function check_nqskyiso() {
  banner "Checking nq basic iso..."
}

function check_nqsky_common() {
  banner "Checking nqsky-common..."

  check_curl

  # mandatory pkgs
  PKGS=(wget traceroute telnet unzip zip ntp net-tools dos2unix apr apr-util jdk)
  for pkg in ${PKGS[@]}; do
    check_rpm_installed $pkg
  done

  # mandatory cmds
  CMDS=(ifconfig traceroute unzip dos2unix telnet)
  for cmd in ${CMDS[@]}; do
    check_cmd $cmd
  done

  check_mysql
  check_tomcat
}

function check_android_app() {
  banner "android app working ?..."
}

function check_pushd() {
  banner "pushd working ?..."
  PKGS=(liblog4cplus tinyxml)
  for pkg in ${PKGS[@]}; do
    check_rpm_installed $pkg
  done
}

function check_ios_app() {
  banner "ios app working ?..."
  info "Python version ? ..."
  local tmp=tmp.${RANDOM}
  $(python --version &>${tmp})
  grep "Python 2.7.5" ${tmp} &>/dev/null
  if [[ $? -eq 0 ]]; then
    info "YES: Python 2.7.5"
  else
    err "NO:$(python --version), but required 2.7.5"
  fi
  rm -rf ${tmp}
}

function check_nqsky_emm() {
  banner "Checking nqsky-emm..."
  check_android_app
  check_ios_app
  check_pushd
}

########### put this in your .bashrc #####
function sanity() {
  local host=$1
  ssh-copy-id -i /root/.ssh/id_rsa.pub root@${host} &>/dev/null
  rsync -avz -e ssh --progress sanity_test.sh root@${host}:/root; ssh root@${host} '/root/sanity_test.sh'
}
#################################### MAIN #############################
check_nqsky_common
check_nqsky_emm
