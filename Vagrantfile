# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "centos65-puppet"
    config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box"


    config.vm.define :web do |web_config|
        web_config.vm.hostname = "web"
        web_config.vm.network "private_network", ip: "192.168.77.2"

        web_config.vm.network :forwarded_port, guest: 80, host: 8085
    end

    config.vm.define :mysql do |db_config|
        db_config.vm.hostname = "mysql"
        db_config.vm.network "private_network", ip: "192.168.77.3"
    end

    config.vm.define :mysql1 do |db_config|
        db_config.vm.hostname = "mysql1"
        db_config.vm.network "private_network", ip: "192.168.77.5"
    end

    config.vm.define :memcache do |m_config|
        m_config.vm.hostname = "memcache"
        m_config.vm.network "private_network", ip: "192.168.77.4"
    end

    config.vm.define :varnish do |v_config|
        v_config.vm.hostname = "varnish"
        v_config.vm.network "private_network", ip: "192.168.77.10"
    end

    config.vm.provision :puppet do |puppet|
        puppet.module_path = [ "puppet/modules" ]
        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file = "site.pp"
    end
end
