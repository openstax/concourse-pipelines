#!/bin/bash

ls -l accounts-ami/
AMI=`cat accounts-ami/ami`
echo "AMI: $AMI"

ENV_NAME=`cat accounts-git/.git/short_ref`
echo "ENV_NAME: $ENV_NAME"

export AWS_SECRET_ACCESS_KEY=$AWS_SECRET
export AWS_ACCESS_KEY_ID=$AWS_KEY

set -xe 

cd /accounts-deployment/scripts
#./create_env --region us-east-2 --env_type prod_lite --do_it --env_name $ENV_NAME --image_id $AMI