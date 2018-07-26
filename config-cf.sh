#!/bin/bash

cf login -o system -a https://api.bosh-lite.com --skip-ssl-validation -u admin -p $(bosh interpolate deployments/vbox/deployment-vars.yml --path /cf_admin_password)

cf create-org production

cf create-space  -o production cart-team

cf create-domain production production.bosh-lite.com