#!/bin/bash

set -e

# create .pypirc
cat >$HOME/.pypirc <<EOF
[distutils]
index-servers =
  dist-rhaptos

[dist-rhaptos]
repository = $DIST_RHAPTOS_URL
username = $DIST_RHAPTOS_USERNAME
password = $DIST_RHAPTOS_PASSWORD
EOF

# create ssh private keys
mkdir $HOME/.ssh
cat >$HOME/.ssh/id_rsa <<EOF
$GIT_PRIVATE_KEY
EOF
chmod 600 $HOME/.ssh/id_rsa

set -x

# Install git
apt-get update && apt-get install -y git
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"

# add github as known host
ssh -o StrictHostKeyChecking=no -T git@github.com || echo 'Added github as known host'

# Download and run ez_setup.py which installs setuptools
python2.4 -c 'import urllib2; open("ez_setup.py", "w").write(urllib2.urlopen("https://raw.githubusercontent.com/pypa/setuptools/archive/bootstrap-py24/ez_setup.py").read())'
python2.4 ez_setup.py
rm -f ez_setup.py

# Download and install pip
python2.4 -c 'import urllib2; open("pip-1.1.tar.gz", "w").write(urllib2.urlopen("https://pypi.python.org/packages/source/p/pip/pip-1.1.tar.gz#md5=62a9f08dd5dc69d76734568a6c040508").read())'
tar xf pip-1.1.tar.gz
cd pip-1.1
python2.4 setup.py install
cd ..
rm -rf pip-1.1

# Install collective.dist 0.2.5
pip install -i https://pypi.python.org/simple/ 'collective.dist==0.2.5' 'docutils==0.5'

# Find the current tag of oer.exports
cd oer-exports
oer_exports_tag=$(git describe --exact-match --tags)

# Clone Products.RhaptosPrint
git clone $RHAPTOS_PRINT_REPO_URL Products.RhaptosPrint
cd Products.RhaptosPrint

# Initialize and update oer.exports (Products/Rhaptos/epub)
git submodule init
git submodule update

# Merge Products.RhaptosPrint master into the production branch
git checkout production
git merge master

# Merge oer.exports current tag into the production branch
cd Products/RhaptosPrint/epub
git checkout production
git merge --no-edit tags/$oer_exports_tag
git push origin HEAD

# Update RhaptosPrint version and changelog
cd .. # Products.RhaptosPrint/Products/RhaptosPrint/
old_version=$(cat version.txt)
new_version=$(awk -F. '{print $1 "." $2 + 1}' version.txt)
echo $new_version >version.txt
echo "RhaptosPrint-${new_version}" >CHANGES
echo "  - $(cat epub/version.txt)" >>CHANGES
git log --format='  - %s' $old_version.. >>CHANGES
echo >>CHANGES
cat CHANGES.txt >>CHANGES
mv CHANGES CHANGES.txt
git commit -m "version bump ${new_version}" -a
git push origin HEAD
git tag $new_version
git push origin $new_version

# Upload RhaptosPrint to dist server
cd ../.. # Products.RhaptosPrint/

# Unfortunately, per https://bugs.python.org/issue21722 there's a bug in old
# versions of Python where failed uploads don't return a non-zero error code.
# As a work around to catch these errors, we'll pipe output to file and look
# for expected values that denote successful upload of .tar.gz and .egg files
# at the end.
python2.4 setup.py mregister sdist mupload -r dist-rhaptos 2>&1 | tee upload_output.txt
num_success=$(tail -n 5 upload_output.txt | grep "Server response (200): OK" | wc -l)
if [ $num_success -ne 1 ]; then
  exit 1
fi

python2.4 setup.py bdist_egg mupload -r dist-rhaptos 2>&1 | tee upload_output.txt
num_success=$(tail -n 5 upload_output.txt | grep "Server response (200): OK" | wc -l)
if [ $num_success -ne 1 ]; then
  exit 1
fi
