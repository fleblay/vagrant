# -*- mode: ruby -*-
# vi: set ft=ruby :

# script_apt_upgrade = <<-'SCRIPT'
#     apt-get update && apt-get upgrade -y
# SCRIPT
#
# scripts_master = [script_apt_upgrade]
# scripts_worker = [script_apt_upgrade]
scripts_master = []
scripts_worker = []

port_map_master = [
  # { host_port: 6443, guest_port: 6443 } # (useless with kubeconfig)
]
port_map_worker = [
  { host_port: 9000, guest_port: 9000 }, # traefik dashboard
  { host_port: 8080, guest_port: 30001 } # argocd dashboard
]

master = { cpu: 3, memory: 6144, name: 'fleblayS', ip: '192.168.42.110', port_map: port_map_master,
           scripts: scripts_master }
worker = { cpu: 3, memory: 6144, name: 'fleblaySW', ip: '192.168.42.111', port_map: port_map_worker,
           scripts: scripts_worker }

machines = [master, worker]
#machines = [master]

Vagrant.configure('2') do |config|
  machines.each do |machine|
    config.ssh.insert_key = false
    config.vm.box = 'debian/bookworm64'
    config.vm.define machine[:name].to_s do |server|
      server.vm.disk :disk, size: "40GB", primary: true
      server.vm.provider 'virtualbox' do |vb|
        vb.cpus = machine[:cpu]
        vb.memory = machine[:memory]
        vb.name = machine[:name]
      end
      server.vm.synced_folder '.', '/vagrant', disabled: true
      server.vm.network 'private_network', ip: machine[:ip]
      machine[:port_map].each do |entry|
        server.vm.network 'forwarded_port', guest: entry[:guest_port], host: entry[:host_port]
      end
      server.vm.hostname = machine[:name]

      machine[:scripts].each do |script|
        server.vm.provision 'shell', inline: script
      end
      server.vm.provision 'ansible' do |ansible|
        ansible.limit = 'all'
        ansible.compatibility_mode = '2.0'
        ansible.playbook = 'ansible/common/playbook.yaml'
      end
    end
  end

  # create ansible inventory file
  ansible_inventory_dir = 'ansible/'
  Dir.mkdir(ansible_inventory_dir) unless Dir.exist?(ansible_inventory_dir)
  File.open("#{ansible_inventory_dir}/inventory.yaml", 'w') do |f|
    f.write "[all:vars]\n"
    f.write "master_node_ip=#{master[:ip]}\n"
    f.write "ansible_user=vagrant\n"
    f.write "[master]\n"
    f.write "#{master[:ip]}\n"
    f.write "[worker]\n"
    f.write "#{worker[:ip]}\n"
  end

  config.push.define 'k3s', strategy: 'local-exec' do |push|
    push.inline = <<-SCRIPT
    ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i ansible/inventory.yaml ansible/local/known_hosts.yaml
    ansible-playbook -i ansible/inventory.yaml ansible/master/playbook.yaml
    ansible-playbook -i ansible/inventory.yaml ansible/worker/playbook.yaml
    SCRIPT
  end

  config.push.define 'app', strategy: 'local-exec' do |push|
    push.inline = <<-SCRIPT
    ansible-playbook -i ansible/inventory.yaml ansible/local/k8s/playbook.yaml
    SCRIPT
  end

  config.push.define 'argo', strategy: 'local-exec' do |push|
    push.inline = <<-SCRIPT
    ansible-playbook -i ansible/inventory.yaml ansible/local/argo/playbook.yaml
    SCRIPT
  end

  config.push.define 'argo-destroy', strategy: 'local-exec' do |push|
    push.inline = <<-SCRIPT
    ansible-playbook -i ansible/inventory.yaml ansible/local/argo/destroy.yaml
    SCRIPT
  end

  config.push.define 'gitlab', strategy: 'local-exec' do |push|
    push.inline = <<-SCRIPT
    ansible-playbook -i ansible/inventory.yaml ansible/local/gitlab/playbook.yaml
    SCRIPT
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessible to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  # config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
