#!/bin/bash
kubectl get pods -A --field-selector "spec.nodeName=$1"
