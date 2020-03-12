#!/bin/bash

echo "Accounts SHA: $SHA"
echo $PWD

echo "ls -l"
ls -ltr

cd /accounts-deployment/scripts
#./build_image --region us-east-2 --verbose --sha ${SHA}
