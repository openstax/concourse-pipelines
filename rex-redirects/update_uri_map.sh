#!/bin/bash

set -xe

git checkout -b "$CNX_DEPLOY_BRANCH"

# TODO install pypi version (not currently available)
# For now we expect to be passed the source directory for cnx-rex-redirects
pip install $1

git config --global user.email "$GIT_AUTHOR_EMAIL"
git config --global user.name "$GIT_AUTHOR_NAME"

# find all the environments with rex_domain $OPENSTAX_HOST
git grep -l "rex_domain: *$OPENSTAX_HOST" environments/*/group_vars/ | cut -d/ -f2 | while read environment
do
  map_file="environments/$environment/files/etc/nginx/uri-maps/rex-uris.map"
  # get the original file in case it's symlinked
  echo "$(python -c "import os.path; print(os.path.relpath(os.path.realpath('$map_file')))")"
  # get all the unique map files
done | sort | uniq | while read output_file
do
  environment="$(echo "$output_file" | cut -d/ -f2)"
  mkdir -p "$(dirname "$output_file")"
  rex_redirects -o "$output_file" --archive-host "$ARCHIVE_HOST" --openstax-host "$OPENSTAX_HOST" update-rex-redirects

  echo -e "Update rex redirects for $environment\n" >commit-message.txt
  git add "$output_file"
  git diff --cached | sed -n 's/^\([-+]\)[^ ]* *\/books\/\([^/]*\).*$/\1\2/ p' | uniq >>commit-message.txt
  git commit -a -F commit-message.txt || echo "No changes to $environment rex-uris.map"
done
