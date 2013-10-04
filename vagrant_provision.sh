#!/usr/bin/env bash

if [[ ! -e ~/.provisioned ]]; then
  # run provisioner script
  cd /vagrant
  ./provision.sh

  # test successful termination
  if [[ $? != 0 ]]; then
    echo "There was a problem during the provisioning. Check log for details." 
    exit 1
  fi

  # create this file so we don't re-provision the machine on each vagrant up
  touch ~/.provisioned
else
  echo "Machine appears already provisioned. Skipping provision."
fi