#!/bin/bash

oci compute instance get --instance-id "$1" | yq .data.metadata.user_data | base64 --decode | gunzip
