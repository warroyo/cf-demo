#!/bin/bash
vboxmanage startvm $(bosh int deployments/vbox/state.json --path /current_vm_cid) --type headless