#!/bin/bash

echo "ls -l accounts-sha"
ls -ltr accounts-sha
cat accounts-sha/sha

SHA1 = `cat accounts-sha/sha`
echo "SHA1: $SHA1" 

cd /accounts-deployment/scripts
#./build_image --region us-east-2 --verbose --sha ${SHA1}
