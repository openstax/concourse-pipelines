#!/bin/bash

# create ssh private keys
mkdir $HOME/.ssh
cat >$HOME/.ssh/id_rsa <<EOF
$GIT_PRIVATE_KEY
EOF
chmod 600 $HOME/.ssh/id_rsa

set -e

# Install git
apt-get update && apt-get install -y git
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"

# add github as known host
ssh -o StrictHostKeyChecking=no -T git@github.com || echo 'Added github as known host'

cd cnx-deploy

old_tag=$(git describe --abbrev=0)
echo "Last tag for cnx-deploy was ${old_tag}"

new_tag=$(date '+%Y%m%d.%H%M%S')
echo "New tag for cnx-deploy is ${new_tag}"

git tag $new_tag
git push origin $new_tag
