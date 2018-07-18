#!/bin/bash
base=$PWD
if [ ! -d bosh-deployment ]
then
    git clone https://github.com/cloudfoundry/bosh-deployment
else
    cd bosh-deployment
    git pull
    cd -
fi

if [ ! -d cf-deployment ]
then
    git clone https://github.com/cloudfoundry/cf-deployment.git
else
    cd cf-deployment
    git pull
    cd -
fi

mkdir -p deployments/vbox
cd deployments/vbox

bosh create-env $base/bosh-deployment/bosh.yml \
  --state ./state.json \
  -o $base/bosh-deployment/virtualbox/cpi.yml \
  -o $base/bosh-deployment/virtualbox/outbound-network.yml \
  -o $base/bosh-deployment/bosh-lite.yml \
  -o $base/bosh-deployment/bosh-lite-runc.yml \
  -o $base/bosh-deployment/uaa.yml \
  -o $base/bosh-deployment/credhub.yml \
  -o $base/bosh-deployment/jumpbox-user.yml \
  --vars-store ./creds.yml \
  -v director_name=bosh-lite \
  -v internal_ip=192.168.50.6 \
  -v internal_gw=192.168.50.1 \
  -v internal_cidr=192.168.50.0/24 \
  -v outbound_network_name=NatNetwork

bosh alias-env vbox -e 192.168.50.6 --ca-cert <(bosh int ./creds.yml --path /director_ssl/ca)

sudo route add -net 10.244.0.0/16     192.168.50.6
cd ../../

source setvars.sh
bosh -e vbox update-cloud-config cf-deployment/iaas-support/bosh-lite/cloud-config.yml

export IAAS_INFO=warden-boshlite
export STEMCELL_VERSION=$(bosh interpolate cf-deployment/cf-deployment.yml --path=/stemcells/alias=default/version)

if ! bosh -e vbox stemcells | grep ${IAAS_INFO} | grep ${STEMCELL_VERSION}
then
    bosh -e vbox upload-stemcell \
    https://bosh.io/d/stemcells/bosh-${IAAS_INFO}-ubuntu-trusty-go_agent?v=${STEMCELL_VERSION}
fi


if ! bosh -e vbox deployments | grep cf
then
    bosh -e vbox -d cf deploy cf-deployment/cf-deployment.yml \
    -o cf-deployment/operations/bosh-lite.yml \
    -o cf-deployment/operations/use-compiled-releases.yml \
    --vars-store deployments/vbox/deployment-vars.yml \
    -v system_domain=bosh-lite.com
else
    bosh -e vbox -d cf cloud-check 
fi