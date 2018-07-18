#!/bin/bash
existing="$1"
new="$2"

#login to cf
cf login -o development -s team1 -a https://api.bosh-lite.com --skip-ssl-validation -u admin -p $(bosh interpolate deployments/vbox/deployment-vars.yml --path /cf_admin_password)

# put new service behind route
echo "Adding $new to primary route at 20% traffic"
cf map-route $new team1.development.bosh-lite.com --hostname demo-app
echo "Running some tests"
sleep 30
#scale service to 2 instances 33%
echo "Increasng $new to 33% traffic"
cf scale $new -i 2
# wait some time , tests can be done here hit it with some traffic
echo "Running some tests"
sleep 30
#scale to 4 instances 50%
echo "Increasng $new to 50% traffic"
cf scale $new -i 4
# wait some time , tests can be done here hit it with some traffic
echo "Running some tests"
sleep 30
# remove old app from route ,  100% traffic
echo "Increasng $new to 100% traffic"
cf unmap-route $existing team1.development.bosh-lite.com --hostname demo-app
# wait some time , tests can be done here hit it with some traffic
echo "Running some tests"
sleep 30
#destroy old app
echo "Tests passed, canary deploy successful"
cf delete $existing -r -f