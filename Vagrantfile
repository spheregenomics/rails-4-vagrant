# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "trusty-server-cloudimg-amd64-vagrant-disk1"
  config.vm.provision :shell, :path => "vagrant_provision.sh", :privileged => false
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network :forwarded_port, guest: 3000, host: 8080
  config.vm.network :private_network, ip: "192.168.33.11"
  config.vm.synced_folder "./", "/home/vagrant/", :nfs => true

  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
  end
end
