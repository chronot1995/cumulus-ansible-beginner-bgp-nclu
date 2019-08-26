#!/bin/bash
cd vx-vbox-simulation
vagrant up oob-mgmt-server oob-mgmt-switch
sleep 10
vagrant up
cd vx-vbox-simulation
