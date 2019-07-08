#!/bin/bash
set -ex
terraform init
terraform workspace select $1
shift
terraform $@
