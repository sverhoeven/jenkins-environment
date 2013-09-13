# This script will run the first time the virtual machine boots
# It is ran as root.

# Expire the user account
passwd -e stefanv

# Regenerate ssh keys
rm /etc/ssh/ssh_host*key*
dpkg-reconfigure -fnoninteractive -pcritical openssh-server

echo '145.100.61.17 chef.esciencecenter.local chef' >> /etc/hosts
# Gridengine does not want 127.0.1.1 to resolve the hostname, but it's real ip.
echo `hostname -I` `hostname -f` >> /etc/hosts
