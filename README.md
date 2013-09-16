Scripts to create the NLeSC jenkins environment.

Overview
========

Machines:
- virtualization machine, will host virtual machines
- chef server, provisioning server, bridged vm
- jenkins, jenkins master build server, exclusive usage, bridged vm
- ubuntu1, jenkins slave, natted vm
- slurm1, slurm controller + grid engine exec + jenkins slave, natted vm
- gridengine1, grid engine master + slurm compute + jenkins slave, natted vm
(- windows 7, jenkins slave, exclusive usage, natted vm)
(- mac mini, jenkins slave, exclusive usage, not dedicated)

Nodes set to exclusive usage, will only run jenkins jobs have specified them.

Virtualization machine
======================

openvswitch on vmhost with http://blog.scottlowe.org/2012/08/17/installing-kvm-and-open-vswitch-on-ubuntu/

See http://www.cryptocracy.com/blog/2012/05/12/bootstrapping-chef/ and https://github.com/borjasotomayor/demogrid/ http://confluence.globus.org/display/DEMOGRID/Running+with+ubuntu-vm-builder

Follow instructions in links above to install openvswitch and libvirt followed by:

    apt-get install python-vm-builder


Add domain to hosts in libvirt nat networks
-------------------------------------------

    sudo virsh net-edit default
    #insert
    <domain name='internal.esciencetest.nl'/>    
    
Restart 'default' network:    

    sudo virsh net-destroy default
    sudo virsh net-start default

Resolve hosts in nat network
----------------------------

Virtualization machine can't resolv nat networked machines, adding nat dns to /etc/resolv.conf causes circular dependency failure.
It must be done manually for each nat machine.

Find nat machines ip and at it to /etc/hosts:

    dig @192.168.122.1 ubuntu1.internal.esciencetest.nl
    sudo nano /etc/hosts
    # Add 192.168.122.32 ubuntu1.internal.esciencetest.nl

Use Virtio disks
----------------

In `/etc/vmbuilder/libvirt/libvirtxml.tmpl` replace `<target dev='hd$disk.devletters()' />` with `<target dev='vd$disk.devletters()' bus='virtio' />`.
In `/usr/share/pyshared/VMBuilder/plugins/ubuntu/fiesty.py` replace `disk_prefix = 'sd'` with `disk_prefix = 'vd'`.

Create chef secret key
----------------------

    openssl rand -base64 512 > encrypted_data_bag_secret
    chmod go-rw encrypted_data_bag_secret

Chef server
===========

    sudo vmbuilder kvm ubuntu -o -c vmbuilder/chef-server.cfg -d kvm-chef-server
    virsh autostart chef

Start vm and login

Goto https://chef.esciencecenter.local login as admin:p@ssw0rd1

Chef workstation
================

Install chef workstation on vmhost
copy /etc/chef-server/admin.pem + /etc/chef-server/chef-validator.pem from chef.esciencecenter.local to vmhost.esciencecenter.local:~/.chef
  
    . vmbuilder/chef-workstation.sh


Test with `knife user list`.
Upload the environment, cookbooks and roles.

Jenkins
=======

    sudo vmbuilder kvm ubuntu -o -c vmbuilder/jenkins.cfg -d kvm-jenkins --part /home/stefanv/vmbuilder/jenkins.part
    #Start vm and login
    virsh autostart jenkins 
    knife bootstrap jenkins.esciencecenter.local -E jenkins -x stefanv --sudo --run-list "role[jenkins-master]"

Goto http://jenkins.esciencetest.nl

Primary jenkins slave
=====================

    sudo vmbuilder kvm ubuntu -o -c vmbuilder/ubuntu1.cfg -d kvm-ubuntu1
    #Start vm and login
    virsh autostart ubuntu1
    knife bootstrap ubuntu1.internal.esciencetest.nl -E jenkins -x stefanv --sudo --run-list "role[jenkins-slave]"

Batch queue nodes
=================

    sudo vmbuilder kvm ubuntu -o -c vmbuilder/slurm2.cfg -d kvm-slurm2
    #Start vm and login
    virsh autostart slurm2
    knife bootstrap slurm2.internal.esciencetest.nl -E jenkins -x stefanv --sudo --run-list "role[jenkins-slave],role[slurm-controller],role['gridengine-exec]"


    sudo vmbuilder kvm ubuntu -o -c vmbuilder/gridengine1.cfg -d kvm-gridengine1
    #Start vm and login
    virsh autostart gridengine1
    knife bootstrap gridengine1.internal.esciencetest.nl -E jenkins -x stefanv --sudo --run-list "role[jenkins-slave],role[gridengine-master],role[gridengine-exec],role[slurm-compute]"
    # after exec hosts are added the master should be updated 
    knife ssh "role:gridengine-master" "sudo chef-client"


Chef repo
---------

See https://github.com/sverhoeven/jenkins-chef-repo

Hints
-----

Update all nodes with a certain role with:
   
    knife ssh 'role:jenkins-master' 'sudo chef-client'



