#!/bin/bash

chroot $1 wget -nv -O chef-server.deb 'https://www.opscode.com/chef/download-server?p=ubuntu&pv=12.04&m=x86_64'
chroot $1 dpkg -i chef-server.deb
chroot $1 rm -f chef-server.deb
