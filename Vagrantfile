# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_NAME = ENV["BOX_NAME"] || "bento/ubuntu-14.04"
BOX_MEMORY = ENV["BOX_MEMORY"] || "512"
DOKKU_TAG = "v0.5.7"

Vagrant.configure(2) do |config|
  config.vm.box = BOX_NAME
  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vb|
    # Ubuntu's Raring 64-bit cloud image is set to a 32-bit Ubuntu OS type by
    # default in Virtualbox and thus will not boot. Manually override that.
    vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
    vb.customize ["modifyvm", :id, "--memory", BOX_MEMORY]
  end

  config.vm.define "dokku-daemon", primary: true do |vm|
    vm.vm.synced_folder File.dirname(__FILE__), "/dokku-daemon"

    vm.vm.provision :shell, :inline => "apt-get update > /dev/null && apt-get -qq -y install git > /dev/null"
    vm.vm.provision :shell, :inline => "wget https://raw.githubusercontent.com/dokku/dokku/#{DOKKU_TAG}/bootstrap.sh && DOKKU_TAG=#{DOKKU_TAG} bash bootstrap.sh"
    vm.vm.provision :shell, :inline => "cd /dokku-daemon && make ci-dependencies develop"
    vm.vm.provision :shell, :inline => "[[ `/sbin/init --version 2>&1` =~ upstart ]] && initctl reload-configuration"
    vm.vm.provision :shell, :inline => "[[ `systemctl 2>&1` =~ -\.mount ]] && systemctl daemon-reload"
  end
end
