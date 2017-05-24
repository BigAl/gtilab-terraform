#!/bin/bash

apt-get update
echo "Installing nfs-common"
apt-get install -y nfs-common

echo "Creating gitlab-data mount point"
mkdir -p ${mount_point}
echo "${fs_id}.efs.${region}.amazonaws.com:/ /gitlab-data nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" >> /etc/fstab

echo "Creating gitlab.rb"

cat >> /etc/gitlab/gitlab.rb <<EOF
gitlab_rails['db_adapter'] = "postgresql"
gitlab_rails['db_encoding'] = "unicode"
gitlab_rails['db_database'] = "${db_database}"
gitlab_rails['db_username'] = "${db_username}"
gitlab_rails['db_password'] = "${db_password}"
gitlab_rails['db_host'] = "`echo ${db_host} |cut -d: -f1`"
gitlab_rails['db_port'] = ${db_port}
gitlab_rails['redis_host'] = "${redis_host}"
gitlab_rails['redis_port'] = ${redis_port}
git_data_dirs({"default" => "/gitlab-data/git-data"})
user['home'] = '/gitlab-data/gitlab/'
gitlab_rails['uploads_directory'] = '/gitlab-data//uploads'
gitlab_rails['shared_path'] = '/gitlab-data/shared'
gitlab_rails['registry_path'] = "/gitlab-data/shared/registry"
gitlab_rails['lfs_storage_path'] = '/gitlab-data/lfs-objects'
EOF

echo "Executing gitlab-ctl reconfigure"

gitlab-ctl reconfigure