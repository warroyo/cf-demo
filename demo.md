DONT forget CTRL + L

# troubleshooting

 if bosh is up and I cant connect to cf api run this `sudo route add -net 10.244.0.0/16     192.168.50.6`


# go into directory

`cd ~/workspace/demos/cf`

# cleanup cf

`./cleanup-cf.sh`

# login to cf 

`cf login -a https://api.bosh-lite.com --skip-ssl-validation -u admin -p $(bosh interpolate deployments/vbox/deployment-vars.yml --path /cf_admin_password) -o production -s cart-team`

# go into app dir

`cd ~/workspace/demos/cf/shopping-cart/src/github.com/warroyo/shopping-cart`

# deploy first v1

`cf push`

# go to url

`https://shopping-cart.production.bosh-lite.com/`

# scale up app

`while true; do curl shopping-cart.production.bosh-lite.com/version; sleep 1; done`
`watch cf app shopping-cart1-0-0`
`cf scale shopping-cart1-0-0 -i 4`

# kill an insatnce

`cf curl -X DELETE /v2/apps/$(cf app shopping-cart1-0-0 --guid)/instances/2`

# deploy a new version zero downtime

`cf deploy-canary --new-app shopping-cart2-0-0 -f manifest-2.0.0.yml -p .`
`https://shopping-cart2-0-0-canary.production.bosh-lite.com`
`watch cf app shopping-cart2-0-0`

# promote to canary

`cf promote-canary -old-app shopping-cart1-0-0 -new-app shopping-cart2-0-0 -duration 1m`
