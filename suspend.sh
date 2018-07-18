#!/bin/bash
vboxmanage controlvm $(bosh int deployments/vbox/state.json --path /current_vm_cid) savestate