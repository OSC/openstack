# -*- mode: ruby -*-
# vi: set ft=ruby :

# $script = <<-SCRIPT
# sudo apt-get update
# sudo apt-get install python-pip
# SCRIPT

$script = <<-SCRIPT
echo beginning script
DEBIAN_FRONTEND=noninteractive apt-get update
echo finished updating cache 
echo beginning pip installations
DEBIAN_FRONTEND=noninteractive apt-get install -yes python-pip
echo updated cache and installed pip 
SCRIPT

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/xenial64"

  machines = {
    'controller.devstack.osc'    => { :ip => '10.1.0.10', :memory => "8192", :cpus => "2"},
    'ood.devstack.osc'    => { :ip =>'10.1.0.20', :memory => "1024", :cpus => "1"}
  }

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.ssh.pty = true
  # config.ssh.insert_key = false
  # config.ssh.private_key_path = File.expand_path('/root/.ssh/id_rsa')

  machines.each do | hostname, attrs|
    config.vm.define hostname do |machine|
      machine.vm.hostname = hostname
      machine.vm.network :private_network, :ip => attrs[:ip]
      machine.ssh.forward_agent = true

      machine.vm.provider "virtualbox" do | v |
          v.memory = attrs[:memory]
          v.cpus = attrs[:cpus]
          # v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ] #only need this line if vagrant is being used by WLS
      end

      if hostname == "controller.devstack.osc"
         machine.vm.provision "shell", inline: $script, privileged: true
      
        machine.vm.provision "ansible_local" do |ans|
          #ans.limit = "controller.devstack.osc"
          ans.playbook = "vagrant_playbook.yml"
          ans.install_mode = "pip"
          ans.verbose = true
          ans.install = true 
        end
      end
    end
  end

end


