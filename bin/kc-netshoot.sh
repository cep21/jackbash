#!/bin/bash
set -exuo pipefail
if [[ "${1-}" == "" ]]; then
	kubectl run "netshoot-$(whoami)" --rm -i --tty --image nicolaka/netshoot -- /bin/bash
else
	kubectl run "netshoot-$(whoami)" --rm -i --tty --image nicolaka/netshoot --overrides="{ \"spec\": { \"tolerations\": [ { \"key\": \"\", \"operator\": \"Exists\" } ], \"nodeSelector\": { \"kubernetes.io/hostname\": \"${1}\" } } }" -- /bin/bash
fi
