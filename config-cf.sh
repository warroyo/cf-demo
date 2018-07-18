#!/bin/bash

cf login -o system -a https://api.bosh-lite.com --skip-ssl-validation -u admin -p $(bosh interpolate deployments/vbox/deployment-vars.yml --path /cf_admin_password)

cf create-org development

cf create-space  -o development team1

cf create-domain development team1.development.bosh-lite.com