Scripts to create the NLeSC jenkins environment.
================================================

openvswitch on vmhost with http://blog.scottlowe.org/2012/08/17/installing-kvm-and-open-vswitch-on-ubuntu/

See http://www.cryptocracy.com/blog/2012/05/12/bootstrapping-chef/ and https://github.com/borjasotomayor/demogrid/ http://confluence.globus.org/display/DEMOGRID/Running+with+ubuntu-vm-builder

Add dnsmasq dns to dhcp client
  
    echo 'prepend domain-name-servers 192.168.100.1;' >> /etc/dhcp/dhclient.conf
    # Also add it to /etc/resolv.conf to prevent reboot

    apt-get install python-vm-builder 

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

    sudo vmbuilder kvm ubuntu -o -c vmbuilder/slave1.cfg -d kvm-slave1
    #Start vm and login
    # from vmhost
    # add slave1 to /etc/hosts
    knife bootstrap slave1.thuis -x verhoes --sudo
 
    sudo vmbuilder kvm ubuntu -o -c vmbuilder/jenkins.cfg -d kvm-jenkins
    #Start vm and login
    knife bootstrap jenkins.thuis -x verhoes --sudo

Chef repo
---------

See https://github.com/sverhoeven/jenkins-chef-repo

Hints
-----

Update all nodes with:
   
    knife ssh 'name:*' 'sudo chef-client'



