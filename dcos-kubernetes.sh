#!/usr/bin/env bash

set -e

[ ! -f /dcos-kubernetes/quickstart/gcp.json ] || ( echo "Required gcp.json file with credentials" && exit 1 )
[ ! -f /dcos-kubernetes/quickstart/dcos_gcp ] || ( echo "Required dcos_gcp private key" && exit 1 )

eval $(ssh-agent) && ssh-add dcos_gcp

make get-cli && mv dcos kubectl /usr/local/bin/

make gcp deploy

COUNT_DOWN=0
while [[ $COUNT_DOWN -lt 100 ]]; do
  k8s_status=$(dcos kubernetes plan status deploy | head -n 1 | grep COMPLETE | wc -l)
  if [[ '1' == $k8s_status ]]; then
    dcos kubernetes kubeconfig
    echo -e "\033[32mKubernetes service is ready for use, ;-)\033[0m"
    kubectl cluster-info
    break;
  fi
  if [[ $COUNT_DOWN -eq 100 ]]; then
    echo -e "\033[31mKubernetes service is not yet, :-(\033[0m"
    exit 1
  fi
  echo "Waiting for kubernetes service [${COUNT_DOWN}/100] ..."
  COUNT_DOWN=`expr $COUNT_DOWN + 1`
  sleep 5
done
