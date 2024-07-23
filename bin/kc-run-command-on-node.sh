#!/bin/bash
set -euo pipefail
if [ "${DEBUG-}" == "true" ]; then
	set -x
fi


# Help message if no command to run
if [ "$#" -eq 0 ]; then
    echo "Help: Runs a pod inside kubernetes, uses command parameters are parameters to COMMAND inside the pod"
    echo "Usage: $0 <command>"
    echo "Environment variable configuration parameters:"
    echo "  NAME:           Who you are: names the pod                     (default: \$USER)"
    echo "  IMAGE:          The container image to use                     (default: nicolaka/netshoot)"
    echo "  NODE_NAME:      The node to run the command on                 (default: none)"
    echo "  READ_ONLY_HOST: If the host mount should be read only at /host (default: true)"
    echo "  DEBUG:          If true, turn on debug logging for the shell   (default: false)"
    echo "Examples:"
    echo "  $0 whoami"
    echo "  IMAGE=amazon/aws-cli:latest $0 aws sts get-caller-identity"
    echo "  IMAGE=nvidia/cuda:12.5.0-base-ubuntu22.04 $0 nvidia-smi -L"
    echo "  NODE_NAME=worker-1 $0 whoami"
    exit 1
fi

# Run a single command in the cluster and return the result
# NAME: Who you are: names the pod
NAME=${NAME-$(whoami)}
# IMAGE: The container image to use
IMAGE=${IMAGE-nicolaka/netshoot}
# If the host mount should be read only at /host
READ_ONLY_HOST=${READ_ONLY_HOST-true}

kubectl delete --ignore-not-found=true pod "cmd-${NAME}"
if [[ "${NODE_NAME-}" == "" ]]; then
	kubectl run "cmd-${NAME}" --command -q --restart=Never -it --rm --image "${IMAGE}" -- $@
else
	kubectl run "cmd-${NAME}" --command -q --restart=Never -it --rm --image "${IMAGE}" \
		--overrides='{
		"spec": {
			"hostNetwork": true,
			"tolerations": [{
				"key": "",
				"operator": "Exists"
			}],
			"nodeSelector": {
				"kubernetes.io/hostname": "'"${NODE_NAME}"'"
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
				"stdin": true,
				"tty": true,
				"volumeMounts": [{
					"mountPath": "/host",
					"name": "host-fs",
					"readOnly": '"$READ_ONLY_HOST"'
				}]
			}]
		}
	}' -- $@
fi


