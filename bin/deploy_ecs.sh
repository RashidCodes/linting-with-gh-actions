#!/usr/bin/env bash 

export TOP_DIR=$(git rev-parse --show-toplevel)
cd provision_ecs_task
terraform init
terraform apply -auto-approve