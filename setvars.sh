#!/bin/bash
export BOSH_CA_CERT=$(bosh int deployments/vbox/creds.yml --path /director_ssl/ca)
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh int deployments/vbox/creds.yml --path /admin_password)
export BOSH_ENVIRONMENT=vbox
export GOPATH=${pwd}/demo-app
cf login -o development -s team1 -a https://api.bosh-lite.com --skip-ssl-validation -u admin -p $(bosh interpolate deployments/vbox/deployment-vars.yml --path /cf_admin_password)
