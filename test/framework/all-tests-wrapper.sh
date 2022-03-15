#!/bin/bash
. test/framework/helper-methods.sh

# Copyright 2021 VMware Tanzu Community Edition contributors. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# get the parameters passed
for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)
    case "$KEY" in
            build)              build=${VALUE} ;;
            urltodownload)      urltodownload=${VALUE} ;;
            homebrew)           homebrew=${VALUE} ;;
            *)
    esac
done

#logger path setup
foldername="tce-runlogs-${RANDOM}"
mkdir /var/tmp/${foldername}
export LOG_PATH=${foldername}
print_style "log path is at folder /var/tmp/${foldername}\n" "info";


#ROOT_DIR := $(shell git rev-parse --show-toplevel)
MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export STANDLONE_DOCKER_PASSED="TRUE"
export LOG_FILE="tce-installation.txt"
touch /var/tmp/${LOG_PATH}/${LOG_FILE}
export LOG_LOCAL_PATH="/var/tmp/${LOG_PATH}/${LOG_FILE}"

{
  #This is where installation logic sits.
  if [ $homebrew == "yes" ]
      then
      print_style "#########################################\n" "info";
      print_style "Install TCE from homebrew\n" "info";
      print_style "#########################################\n" "info";
      echo "update TCE repo"
      brew tap vmware-tanzu/tanzu
      echo "Install TCE"
      brew install tanzu-community-edition
      echo "Additional Script run"
      pathLocal="$(brew info tanzu-community-edition| grep \*| cut -d " " -f1)"
      sh ${pathLocal}/libexec/configure-tce.sh
      # Workaround for issue https://github.com/kubernetes-sigs/kind/issues/2240
      sudo sysctl net/netfilter/nf_conntrack_max=131072
      go env -w GOFLAGS=-mod=mod
  elif [ $build == "yes" ]
  then
      print_style "#########################################\n" "info";
      print_style "Install TCE from homebrew\n" "info";
      print_style "#########################################\n" "info";
      "${TCE_REPO_PATH}/test/install-dependencies.sh"
      "${TCE_REPO_PATH}/test/build-tce.sh"
  else
      print_style "#########################################\n" "info";
      print_style "Install from URL provided\n" "info";
      print_style "#########################################\n" "info";
      brew install wget
      wget ${urltodownload}
      dirname=$(basename ${urltodownload} .tar.gz)
      echo "file name is ${filename}"
      echo "dir name is ${dirname}"
      chmod 777 ${dirname}.tar.gz
      tar -xvzf  ${dirname}.tar.gz
      ./${dirname}/uninstall.sh
      ./${dirname}/install.sh
  fi
  tanzu version
  print_style "Installation complete\n" "info";
} | tee "${LOG_LOCAL_PATH}"


print_style "#########################################\n" "info";
print_style "Run the e2e tests\n" "info";
print_style "#########################################\n" "info";
./test/framework/docker-managed-wrapper.sh
./test/framework/aws-managed-wrapper.sh
./test/framework/azure-managed-wrapper.sh
./test/framework/vsphere-managed-wrapper.sh
