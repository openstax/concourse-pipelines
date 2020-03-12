#!/bin/bash

SHA=`cat accounts-sha/sha`
echo "SHA: $SHA"

cd /accounts-deployment/scripts
./build_image --region us-east-2 --verbose --sha ${SHA}
