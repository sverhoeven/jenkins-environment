Scripts to create the NLeSC jenkins environment.
================================================

Overview
--------

Machines:
- virtualization machine, will host virtual machines
- chef server, provisioning server (vm)
- jenkins, jenkins master build server (vm)
- slave1, jenkins slave, behind nat (vm)
- slave2, jenkins slave, behind nat (vm)
(- windows 7, jenkins slave (vm)
(- mac mini, jenkins slave, not dedicated)

Jenkins machine will be set to exclusive usage, so all builds will be done on slaves.

Virtualization machine
----------------------

openvswitch on vmhost with http://blog.scottlowe.org/2012/08/17/installing-kvm-and-open-vswitch-on-ubuntu/

See http://www.cryptocracy.com/blog/2012/05/12/bootstrapping-chef/ and https://github.com/borjasotomayor/demogrid/ http://confluence.globus.org/display/DEMOGRID/Running+with+ubuntu-vm-builder

Follow instructions in links above to install openvswitch and libvirt followed by:

    apt-get install python-vm-builder


Add domain to hosts in libvirt nat networks:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    sudo virsh net-edit default
    #insert
    <domain name='priv.thuis'/>    
    
    sudo virsh net-destroy default
    sudo virsh net-start default

Resolve hosts in nat network:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Virtualization machine can resolv nat networked machines, adding nat dns to /etc/resolv.conf causes deadlock.
It must be done manually for each nat machine.

Find nat machines ip and at it to /etc/hosts:

    dig @192.168.100.1 slave1.priv.thuis
    sudo nano /etc/hosts
    # Add 192.168.100.32 slave1.priv.thuis

Chef server
-----------

    sudo vmbuilder kvm ubuntu -o -c vmbuilder/chef-server.cfg -d kvm-chef-server

Start vm and login

Goto https://chef.thuis login as admin:p@ssw0rd1

Chef workstation
----------------

Install chef workstation on vmhost
copy /etc/chef-server/admin.pem + /etc/chef-server/chef-validator.pem from chef.thuis to vmhost.thuis:~/.chef
  
    . vmbuilder/chef-workstation.sh

Nodes
-----

    sudo vmbuilder kvm ubuntu -o -c vmbuilder/jenkins.cfg -d kvm-jenkins
    #Start vm and login
    knife bootstrap jenkins.thuis -x verhoes --sudo --run-list "role[jenkins-master]"

    sudo vmbuilder kvm ubuntu -o -c vmbuilder/slave1.cfg -d kvm-slave1
    #Start vm and login
    knife bootstrap slave1.priv.thuis -x verhoes --sudo --run-list "role[jenkins-slave]"
 
    sudo vmbuilder kvm ubuntu -o -c vmbuilder/slave2.cfg -d kvm-slave2
    #Start vm and login
    knife bootstrap slave2.priv.thuis -x verhoes --sudo --run-list "role[jenkins-slave]"

Goto http://jenkins.thuis to add a job.

Chef repo
---------

See https://github.com/sverhoeven/jenkins-chef-repo

Hints
-----

Update all nodes with a certain role with:
   
    knife ssh 'role:jenkins-master' 'sudo chef-client'



