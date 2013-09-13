curl -L https://www.opscode.com/chef/install.sh | sudo bash
git clone git://github.com/opscode/chef-repo.git

cat <<EOF | knife configure --initial

https://chef.thuis:443
admin
chef-validator
/home/stefanv/.chef/chef-validator.pem
/home/stefanv/chef-repo
EOF

chmod go-rw .chef/*

