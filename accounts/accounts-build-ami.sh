#!/bin/bash

set -xe

SHA=`cat accounts-sha/sha`
echo "SHA: $SHA"

export AWS_SECRET_ACCESS_KEY=$AWS_SECRET
export AWS_ACCESS_KEY_ID=$AWS_KEY

cd /accounts-deployment/scripts
./build_image --region us-east-2 --verbose --sha ${SHA}
