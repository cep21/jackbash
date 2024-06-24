#!/bin/bash
set -eu
CTX=$(kubectl config current-context)
KUST_STATUS=$(mktemp)
HR_STATUS=$(mktemp)
HELM_STATUS=$(mktemp)
echo "Fetching kustomizations"
kubectl --context $CTX get kustomizations.kustomize.toolkit.fluxcd.io -A >  "$KUST_STATUS"
echo "Fetching helm releases"
kubectl --context $CTX get helmreleases.helm.toolkit.fluxcd.io -A > "$HR_STATUS"
echo "listing helm charts"
helm --kube-context $CTX list -A > "$HELM_STATUS"
TOTAL_KUST=$(wc -l < "$KUST_STATUS")
TOTAL_KUST_FALSE=$(grep 'False' < "$KUST_STATUS" | wc -l)
TOTAL_HR=$(wc -l < "$HR_STATUS")
TOTAL_HR_FALSE=$(grep 'False' < "$HR_STATUS" | wc -l)
TOTAL_H=$(wc -l < "$HELM_STATUS")
TOTAL_H_FALSE=$(grep 'False' < "$HELM_STATUS" | wc -l)
echo "Total kustomizations: $TOTAL_KUST"
echo "Total HelmRelease: $TOTAL_HR"
echo "Total Helm Charts: $TOTAL_H"
echo "Bad Kustomizations"
cat < $KUST_STATUS | grep -v 'True'
echo "Bad HelmRelease"
cat < $HR_STATUS | grep -v 'True'
echo "Bad Helm Charts"
cat < $HELM_STATUS | grep -v 'deployed'

rm -f "$KUST_STATUS" "$HR_STATUS" "$HELM_STATUS"
