#!/bin/bash

git checkout $CNX_DEPLOY_BRANCH

# TODO install pypi version (not currently available)
pip install git+https://github.com/openstax/cnx-rex-redirects.git@fix-composite-pages
if [ -f "environments/$CNX_DEPLOY_ENVIRONMENT/group_vars/all/vars.yml" ]
then
    vars_file="environments/$CNX_DEPLOY_ENVIRONMENT/group_vars/all/vars.yml"
else
    vars_file="environments/$CNX_DEPLOY_ENVIRONMENT/group_vars/all.yml"
fi
rex_domain=$(awk -F': *' '/rex_domain/ { print $2 }' "$vars_file")
rex_redirects update-rex-redirects -o "environments/$CNX_DEPLOY_ENVIRONMENT/files/etc/nginx/uri-maps/rex-uris.map" "$rex_domain"

# commit any changes
git config --global user.email "$GIT_AUTHOR_EMAIL"
git config --global user.name "$GIT_AUTHOR_NAME"
git commit -am "Update rex redirects for $CNX_DEPLOY_ENVIRONMENT"
