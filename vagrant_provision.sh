#!/usr/bin/env bash

if [[ ! -e ~/.provisioned ]]; then
  # copy the .env to the provisioner folder so it gets picked up by the script
  cp /vagrant/.env /vagrant/provisioner/

  # run provisioner script
  cd /vagrant/provisioner
  ./provision.sh

  # test successful termination
  if [[ $? != 0 ]]; then
    echo "There was a problem with the provisioning. Check log for details." 
    exit 1
  fi

  # Patch Nginx and Unicorn configuration to create the unix socket elsewhere outside the project folder.
  # It seems you cannot create unix sockets inside a Vagrant shared folder.
  sudo sed -i -e "s/listen APP_ROOT.*/listen \"\/run\/unicorn.sock\", :backlog => 64/" /etc/unicorn/unicorn.rb
  sudo sed -i -e "s/server unix:.*/server unix:\/run\/unicorn.sock fail_timeout=0;/" /etc/nginx/nginx.conf

  # reload confs
  sudo monit restart nginx
  sudo monit restart unicorn

  # create this file so we don't re-provision the machine on each vagrant up
  touch ~/.provisioned
else
  echo "Machine appears already provisioned. Skipping."
fi