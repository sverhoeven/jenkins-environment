curl -L https://www.opscode.com/chef/install.sh | sudo bash
git clone --recurse-submodules git@github.com:sverhoeven/jenkins-chef-repo.git /home/stefanv/jenkins-chef-repo

cat <<EOF | knife configure --initial

https://chef.esciencecenter.local:443
stefanv
admin
/home/stefanv/.chef/admin.pem
chef-validator
/home/stefanv/.chef/chef-validator.pem
/home/stefanv/jenkins-chef-repo
EOF

chmod go-rw ~/.chef/*

