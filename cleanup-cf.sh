#!/bin/bash

cf login -o production -s cart-team -a https://api.bosh-lite.com --skip-ssl-validation -u admin -p $(bosh interpolate deployments/vbox/deployment-vars.yml --path /cf_admin_password)

cf delete shopping-cart1-0-0 -r -f

cf delete shopping-cart2-0-0 -r -f

cf delete-orphaned-routes -f