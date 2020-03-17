#!/bin/bash
pwd
SHA=`cat accounts-git/.git/short_ref`
echo "SHA: $SHA"

export AWS_SECRET_ACCESS_KEY=$AWS_SECRET
export AWS_ACCESS_KEY_ID=$AWS_KEY

set -xe 

cd /accounts-deployment/scripts
./build_image --region us-east-2 --verbose --do_it --sha ${SHA} 2>&1 | tee /tmp/build.out
grep "AMI:" /tmp/build.out | awk '{print $4}' /tmp/build.out

cd -
pwd
mkdir accounts-ami
grep "AMI:" /tmp/build.out | awk '{print $4}' >> accounts-ami/ami

cat accounts-ami/ami
