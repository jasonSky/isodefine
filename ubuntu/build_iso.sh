#!/bin/bash 
declare -r SCRIPT=$(readlink -f $0)
declare -r SCRIPTPATH=$(dirname ${SCRIPT})

declare -r WORK_DIR=${SCRIPTPATH}

declare -r ORIGIN_ISO=${WORK_DIR}/origiso/ubuntu-19.10-server-amd64.iso

declare -r BUILD_DIR=${WORK_DIR}/target
declare -r BUILD_SRC_DIR=${BUILD_DIR}/nqskyiso

declare -r OUTPUT_ISO=${BUILD_DIR}/${1:-emm-ubuntu.iso}

#nqsky customized source 
declare -r NQ_SRC_DIR=${WORK_DIR}/nqskyiso

function usage() {
  echo "./$0 <output_iso_name>"
}

function die() {
  echo "$1"
  echo -e "\e[31m[ERROR] $@\e[0m" 1>&2
  echo
  exit 1
}

# install iso build tools if not.
function install_build_tools() {
  #pykickstart has a tool to check ks syntax, which is ksvalidator
  sudo yum install -y createrepo genisoimage pykickstart
}

#try to clean up.
function clean() {
  rm -rf ${BUILD_DIR} 2>/dev/null 
}

# copy the original centos iso to BUILD_SRC_DIR
function copy_original_iso () {
  mkdir -p ${BUILD_DIR} ${BUILD_SRC_DIR} 2>/dev/null

  local tmpdir=${BUILD_DIR}/bootiso
  #mount the original iso to a read-only tmp dir
  mkdir -p ${tmpdir} 2>/dev/null
  mount -o loop ${ORIGIN_ISO} ${tmpdir}

  # copy the mounted iso to working directory, 
  # Do not forget the hidden files. such as .diskinfo etc
  cp -pRrf ${tmpdir}/. ${BUILD_SRC_DIR}/
  #rm ${BUILD_SRC_DIR}/Packages/* -f
  #for x in `cat xxos.txt`
  #do
  #    cp ${tmpdir}/Packages/$x ${BUILD_SRC_DIR}/Packages/$x
  #done

  umount ${tmpdir} && rmdir ${tmpdir}
}

function prepare_nqsky () {
  local nqsky_ks=${NQ_SRC_DIR}/ks/ks.cfg
  local nqsky_preseed=${NQ_SRC_DIR}/ks/ks.preseed
  #checking ks syntax
  if [[ $(command -v ksvalidator 2>/dev/null) ]]; then
    ksvalidator ${nqsky_ks}
    if [[ $? -ne 0 ]]; then
      die "ERROR: kickstart script error, check ${nqsky_ks}. Quit..."
    fi
  fi

  # copy nqsky customized kickstart script
  cp ${nqsky_ks} ${BUILD_SRC_DIR}/ks.cfg 
  cp ${nqsky_preseed} ${BUILD_SRC_DIR}/ks.preseed
  #cp ${NQ_SRC_DIR}/install/* ${BUILD_SRC_DIR}/install/
  
  #cp isolinux.cfg
  cp ${NQ_SRC_DIR}/isolinux/txt.cfg ${BUILD_SRC_DIR}/isolinux/txt.cfg 

}

function prepare_nqsky_pkgs() {
  mkdir ${BUILD_SRC_DIR}/nqskypkgs 2>/dev/null

  for pkg in $(dir ${WORK_DIR}/nqskypkgs); do
    pkg_dir=${WORK_DIR}/nqskypkgs/${pkg}

    if [[ ! -d ${pkg_dir} ]]; then
      die "'${pkg_dir}' not found!"
    else 
      #cp ${pkg_dir}/Packages/*.rpm ${BUILD_SRC_DIR}/Packages 2>/dev/null
      echo ${pkg_dir}
      find ${pkg_dir}/Packages -name "*.rpm" -exec cp {} ${BUILD_SRC_DIR}/Packages \; 2>/dev/null
      
      mkdir -p ${BUILD_SRC_DIR}/nqskypkgs/${pkg} 2>/dev/null
      cp -rf ${pkg_dir}/postinstall ${BUILD_SRC_DIR}/nqskypkgs/${pkg}/ 2>/dev/null
    fi
  done
}

function test_post_install() {
  cp -pRrf ${NQ_SRC_DIR}/postinstall ${BUILD_SRC_DIR}/
}

function build_iso() {
  cd ${BUILD_SRC_DIR}
  chmod 664 ${BUILD_SRC_DIR}/isolinux/isolinux.bin
  mkisofs -o ${OUTPUT_ISO} -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V 'Ubuntu Server' -D -r -cache-inodes -R -T ${BUILD_SRC_DIR}
  # -v
  
  #clean up
  rm -rf ${BUILD_SRC_DIR} 2>/dev/null
}

function post_clean() {
  rm -rf ${BUILD_SRC_DIR} 2>/dev/null
}

######################MAIN ROUTINE################################
#install necessary iso build tools
#install_build_tools

cd ${WORK_DIR}
clean
copy_original_iso

prepare_nqsky
#prepare_nqsky_pkgs 

    
#change permissions on working directory
chmod -R u+w ${BUILD_SRC_DIR}

test_post_install 

build_iso
