#!/bin/bash

echo "Accounts SHA: $SHA"
cd /accounts-deployment/scripts
./build_image --region us-east-2 --verbose --sha ${SHA}
