#!/usr/bin/env bash

set -eo pipefail

command -v kubectl >/dev/null 2>&1 || { \
 echo >&2 "kubectl is needed, but it's not installed.  Aborting."
 echo >&2 "Refer to: https://kubernetes.io/docs/tasks/tools/install-kubectl/"
 exit 1
}
command -v jq >/dev/null 2>&1 || { \
 echo >&2 "jq is needed, but it's not installed.  Aborting."
 echo >&2 "Refer to: https://stedolan.github.io/jq/"
 exit 1
}

# Exports all resources from a K8s cluster
# while redacting secrets values and env vars
# Uses the current context

CONTEXT="$(kubectl config current-context | sed -e 's/\//_/g' | sed -e 's/:/_/g')"
OUTPUTFILE="../assets/${CONTEXT}.json"
touch "${OUTPUTFILE}" || exit 1
cat /dev/null > "${OUTPUTFILE}"

# API Resources
APIRESOURCES="$(kubectl api-resources -o name --verbs list | sort -u)"
REDACTEDRESOURCES='^(secrets|managedcertificate.+)$'
for res in $APIRESOURCES; do
  if [[ $res =~ $REDACTEDRESOURCES ]]; then
    # redact secrets data values
    kubectl get $res --all-namespaces --chunk-size=50 -ojson | jq -rc --arg CONTEXT "$CONTEXT" '.items[] | {asset_type: ("k8s.io/"+ .kind), name: ("//"+ $CONTEXT + .metadata.selfLink), resource: {version: "v1", discovery_document_uri: "https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json", data: .}}' >> "${OUTPUTFILE}"
  else
    # redact anywhere env vars have "value"
    kubectl get $res --all-namespaces --chunk-size=50 -ojson | jq -rc --arg CONTEXT "$CONTEXT" '.items[] | {asset_type: ("k8s.io/"+ .kind), name: ("//"+ $CONTEXT + .metadata.selfLink), resource: {version: "v1", discovery_document_uri: "https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json", data: .}}' >> "${OUTPUTFILE}"
  fi
done

# Server version
kubectl version -o json | jq -r '.serverVersion'| jq -rc --arg CONTEXT "$CONTEXT" '{asset_type: ("k8s.io/Version"), name: ("//"+ $CONTEXT + .metadata.selfLink), resource: {version: "v1", discovery_document_uri: "https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json", data: .}}' >> "${OUTPUTFILE}"

# Top nodes and pods
TOPNODES="$(kubectl top nodes --no-headers=true 2> /dev/null)"
echo "{}" | jq -rc --arg TOPNODES "$TOPNODES" --arg CONTEXT "$CONTEXT" '{asset_type: ("k8s.io/TopNodes"), name: ("//"+ $CONTEXT), resource: {version: "v1", discovery_document_uri: "https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json", data: $TOPNODES}}' >> "${OUTPUTFILE}"
TOPPODS="$(kubectl top pods -A --containers=true --no-headers=true 2> /dev/null)"
echo "{}" | jq -rc --arg TOPPODS "$TOPPODS" --arg CONTEXT "$CONTEXT" '{asset_type: ("k8s.io/TopPods"), name: ("//"+ $CONTEXT), resource: {version: "v1", discovery_document_uri: "https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json", data: $TOPPODS}}' >> "${OUTPUTFILE}"
