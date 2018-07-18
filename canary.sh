#!/bin/bash

#login to cf
cf login -o development -s team1 -a https://api.bosh-lite.com --skip-ssl-validation -u admin -p $(bosh interpolate deployments/vbox/deployment-vars.yml --path /cf_admin_password)

# put new service behind route
cf map-route
#scale service to 2 instances 33%
cf

# wait some time , tests can be done here hit it with some traffic

#scale to 4 instances 50%
cf


# wait some time , tests can be done here hit it with some traffic


# remove old app from route ,  100% traffic

# wait some time , tests can be done here hit it with some traffic

#destroy old app
