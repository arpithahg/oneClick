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

export STANDLONE_DOCKER_PASSED="TRUE"
export LOG_FILE="docker-standalone.txt"
touch /var/tmp/${LOG_PATH}/${LOG_FILE}
export LOG_LOCAL_PATH="/var/tmp/${LOG_PATH}/${LOG_FILE}"
{
#ROOT_DIR := $(shell git rev-parse --show-toplevel)
#MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  ROOT_DIR="$(pwd)"
  guest_cluster_name="guest-cluster-${RANDOM}"

  print_style "#########################################\n" "info";
  print_style "Create the standalone cluster\n" "info";
  print_style "#########################################\n" "info";
  test/docker/run-tce-docker-standalone-cluster.sh build="no" setup="yes" cleanup="no" clustername=$guest_cluster_name
  printf '\E[32m'; echo "Creating standalone cluster complete"; printf '\E[0m'

  print_style "#########################################\n" "info";
  print_style "Install the package repo\n" "info";
  print_style "#########################################\n" "info";
  test/add-tce-package-repo.sh
  printf '\E[32m'; echo "Adding TCE repo complete"; printf '\E[0m'

  print_style "#########################################\n" "info";
  print_style "Run the package tests\n" "info";
  print_style "#########################################\n" "info";
  cd "test/smoke" && make smoke-test
  test/gatekeeper/e2e-test.sh && tanzu package installed delete gatekeeper -y
  printf '\E[32m'; echo "Gatekeeper run complete"; printf '\E[0m'
  test/smoke/packages/contour/1.18.2/contour-test.sh
  printf '\E[32m'; echo "Contour run complete"; printf '\E[0m'
  test/smoke/packages/cert-manager/1.5.3/cert-manager-test.sh
  printf '\E[32m'; echo "Cert-manager run complete"; printf '\E[0m'
  test/smoke/packages/fluent-bit/1.7.5/fluent-bit-test.sh
  printf '\E[32m'; echo "fluent-bit run complete"; printf '\E[0m'
  test/smoke/packages/local-path-storage/0.0.20/local-path-storage-test.sh
  printf '\E[32m'; echo "local-storage-path run complete"; printf '\E[0m'
  cd "test/e2e" && ginkgo -v -- --packages="external-dns" --version="0.8.0" --guest-cluster-name=$guest_cluster_name
  printf '\E[32m'; echo "external-dns run complete"; printf '\E[0m'
  cd "test/e2e" && ginkgo -v -- --packages="multus-cni" --version="3.7.1" --guest-cluster-name=$guest_cluster_name
  printf '\E[32m'; echo "multius-cni run complete"; printf '\E[0m'

  print_style "#########################################\n" "info";
  print_style "Collect support bundles\n" "info";
  print_style "#########################################\n" "info";
  tanzu diagnostics collect --workload-cluster-name ${guest_cluster_name}

  print_style "#########################################\n" "info";
  print_style "Cleanup the cluster\n" "info";
  print_style "#########################################\n" "info";
  cd "$ROOT_DIR" && test/docker/run-tce-docker-standalone-cluster.sh build="no" setup="no" cleanup="yes" clustername=$guest_cluster_name
  printf '\E[32m'; echo "Deleting standalone cluster complete"; printf '\E[0m'
} 2>&1 | tee -a "${LOG_LOCAL_PATH}"