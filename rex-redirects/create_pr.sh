#!/bin/bash

set -xe

# no branch is checked out at this point
git checkout "$CNX_DEPLOY_BRANCH"

# download hub (commandline program to do github stuff)
wget "https://github.com/github/hub/releases/download/v$HUB_VERSION/hub-linux-amd64-$HUB_VERSION.tgz"
tar xf "hub-linux-amd64-$HUB_VERSION.tgz" "hub-linux-amd64-$HUB_VERSION/bin/hub"

# check whether PR already exists
if [ -z "$("hub-linux-amd64-$HUB_VERSION/bin/hub" pr list -h "$CNX_DEPLOY_BRANCH")" ]
then
  "hub-linux-amd64-$HUB_VERSION/bin/hub" pull-request -f --no-edit -a "$ASSIGNEES"
fi
