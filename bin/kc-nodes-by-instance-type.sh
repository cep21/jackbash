#!/bin/bash
kubectl get nodes -o json|jq -Cjr '.items[] | .metadata.name," ",.metadata.labels."node.kubernetes.io/instance-type"," ",.metadata.labels."kubernetes.io/arch", "\n"'|sort -k3 -r
