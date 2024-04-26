#!/bin/bash
set -exuo pipefail
if [[ "${1-}" == "" ]]; then
	kubectl run "netshoot-$(whoami)" --rm -i --tty --image nicolaka/netshoot -- /bin/bash
else
	kubectl run "netshoot-$(whoami)" --rm -i --tty --image nicolaka/netshoot \
		--overrides='{ 
		"spec": {
			"hostNetwork": true,
			"tolerations": [{
				"key": "",
				"operator": "Exists"
			}],
			"nodeSelector": {
				"kubernetes.io/hostname": "'${1}'"
			},
			"containers": [{
				"name": "netshoot",
				"image": "nicolaka/netshoot",
				"securityContext": {
					"privileged": true
				},
				"command": ["/bin/bash"],
				"stdin": true,
				"tty": true
			}]
		}
	}'
fi
