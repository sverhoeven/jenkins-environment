# This script will run the first time the virtual machine boots
# It is ran as root.

# Expire the user account
passwd -e stefanv

# Regenerate ssh keys
rm /etc/ssh/ssh_host*key*
dpkg-reconfigure -fnoninteractive -pcritical openssh-server

# rabbitmq requires HOME env
HOME=/tmp chef-server-ctl reconfigure
