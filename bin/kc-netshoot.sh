#!/bin/bash
set -exuo pipefail
NAME=${NAME-$(whoami)}
IMAGE=${IMAGE-nicolaka/netshoot}
READ_ONLY_HOST=${READ_ONLY_HOST-true}
echo $NAME
if [[ "${1-}" == "" ]]; then
	kubectl run "netshoot-${NAME}" --rm -i --tty --image "${IMAGE}" -- /bin/bash
else
	kubectl run "netshoot-${NAME}" --rm -i --tty --image "${IMAGE}" \
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
			"volumes": [{
				"hostPath": {
					"path": "/"
				},
				"name": "host-fs"
			}],
			"containers": [{
				"name": "netshoot",
				"image": "'"${IMAGE}"'",
				"securityContext": {
					"privileged": true
				},
				"command": ["/bin/bash"],
				"stdin": true,
				"tty": true,
				"volumeMounts": [{
					"mountPath": "/host",
					"name": "host-fs",
					"readOnly": '"$READ_ONLY_HOST"'
				}]
			}]
		}
	}'
fi
