#!/bin/bash

echo "Accounts SHA: $SHA"

echo "ls -l accounts-git"
ls -ltr accounts-git

echo "ls -l accounts-sha"
ls -ltr accounts-sha

cd /accounts-deployment/scripts
#./build_image --region us-east-2 --verbose --sha ${SHA}
