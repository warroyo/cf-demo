#!/bin/bash

if [ ! -d cf-mysql-deployment ]
then
    git clone https://github.com/cloudfoundry/cf-mysql-deployment.git
else
    cd cf-mysql-deployment
    git pull
    cd -
fi



export IAAS_INFO=warden-boshlite
export STEMCELL_VERSION=$(bosh interpolate cf-mysql-deployment/cf-mysql-deployment.yml --path=/stemcells/alias=default/version)

if ! bosh -e vbox stemcells | grep ${IAAS_INFO} | grep ${STEMCELL_VERSION}
then
    bosh -e vbox upload-stemcell \
    https://bosh.io/d/stemcells/bosh-${IAAS_INFO}-ubuntu-trusty-go_agent?v=${STEMCELL_VERSION}
fi



bosh \
  -e vbox \
  -d cf-mysql \
  deploy \
  cf-mysql-deployment/cf-mysql-deployment.yml \
  -o cf-mysql-deployment/operations/bosh-lite.yml \
  -o cf-mysql-deployment/operations/add-broker.yml \
  -o cf-mysql-deployment/operations/register-proxy-route.yml \
  -l cf-mysql-deployment/bosh-lite/default-vars.yml

  bosh -e vbox  -d cf-mysql run-errand broker-registrar