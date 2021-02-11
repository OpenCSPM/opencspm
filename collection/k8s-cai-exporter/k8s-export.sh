#!/bin/bash

# Local development
if [[ "${GOOGLE_APPLICATION_CREDENTIALS}" != "" ]]; then
  gcloud auth activate-service-account --key-file "${GOOGLE_APPLICATION_CREDENTIALS}" || { echo "Invalid credentials"; exit 1; }
fi

if [[ "${GCS_BUCKET_NAME}" == "" ]]; then
  echo "Invalid GCS_BUCKET_NAME env passed"
  exit 1
fi

if [[ "${GCS_BUCKET_FOLDER}" == "" ]]; then
  echo "Invalid GCS_BUCKET_FOLDER env passed"
  exit 1
fi

if [[ "${DEBUG_EXPORT_TIME}" != "" ]]; then
  echo "Sleeping ${DEBUG_EXPORT_TIME} or 300 seconds"
  sleep "${DEBUG_EXPORT_TIME}" || sleep 300
fi

export HOME=/tmp
cd

# Gather context
echo "Gathering context"
GCPPROJECT="$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)"
GCPLOCATION="$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/cluster-location)"
CLUSTERNAME="$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/cluster-name)"
CONTEXT="container.googleapis.com/projects/${GCPPROJECT}/locations/${GCPLOCATION}/clusters/${CLUSTERNAME}"
UTC_TIME="$(date +%s --utc)"
GCS_FILE_NAME="${UTC_TIME}_${GCPPROJECT}_${GCPLOCATION}_${CLUSTERNAME}_k8s-export.json"
GCS_MANIFEST="${GCPPROJECT}_${GCPLOCATION}_${CLUSTERNAME}_manifest.txt"

OUTPUTFILE="/tmp/k8s-export.json"
touch "${OUTPUTFILE}"
cat /dev/null > "${OUTPUTFILE}"

echo "Beginning export"
# API Resources
APIRESOURCES="$(kubectl api-resources -o name --verbs list | sort -u)"
REDACTEDRESOURCES='^(secrets|managedcertificate.+)$'
for res in $APIRESOURCES; do
  if [[ $res =~ $REDACTEDRESOURCES ]]; then
    # redact secrets data values
    kubectl get $res --all-namespaces --chunk-size=50 -ojson | jq -rc --arg CONTEXT "$CONTEXT" '.items[] | walk(if type=="object" and has("kubectl.kubernetes.io/last-applied-configuration") then ."kubectl.kubernetes.io/last-applied-configuration"="REDACTED" else . end) | walk(if type == "object" and has("data") then .data[] = "REDACTED" else . end) | {asset_type: ("k8s.io/"+ .kind), name: ("//"+ $CONTEXT + .metadata.selfLink), resource: {version: "v1", discovery_document_uri: "https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json", data: .}}' >> "${OUTPUTFILE}"
  else
    # redact anywhere env vars have "value"
    kubectl get $res --all-namespaces --chunk-size=50 -ojson | jq -rc --arg CONTEXT "$CONTEXT" '.items[] | walk(if type=="object" and has("kubectl.kubernetes.io/last-applied-configuration") then ."kubectl.kubernetes.io/last-applied-configuration"="REDACTED" else . end) | walk(if type=="object" and has("env") and (.env|type=="array") then walk(if type=="object" and has("name") and has("value") then .value="REDACTED" else . end) else . end) | {asset_type: ("k8s.io/"+ .kind), name: ("//"+ $CONTEXT + .metadata.selfLink), resource: {version: "v1", discovery_document_uri: "https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json", data: .}}' >> "${OUTPUTFILE}"
  fi
done

# Server version
kubectl version -o json | jq -r '.serverVersion'| jq -rc --arg CONTEXT "$CONTEXT" '{asset_type: ("k8s.io/Version"), name: ("//"+ $CONTEXT + .metadata.selfLink), resource: {version: "v1", discovery_document_uri: "https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json", data: .}}' >> "${OUTPUTFILE}"

# Top nodes and pods
TOPNODES="$(kubectl top nodes --no-headers=true 2> /dev/null)"
echo "{}" | jq -rc --arg TOPNODES "$TOPNODES" --arg CONTEXT "$CONTEXT" '{asset_type: ("k8s.io/TopNodes"), name: ("//"+ $CONTEXT), resource: {version: "v1", discovery_document_uri: "https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json", data: $TOPNODES}}' >> "${OUTPUTFILE}"
TOPPODS="$(kubectl top pods -A --containers=true --no-headers=true 2> /dev/null)"
echo "{}" | jq -rc --arg TOPPODS "$TOPPODS" --arg CONTEXT "$CONTEXT" '{asset_type: ("k8s.io/TopPods"), name: ("//"+ $CONTEXT), resource: {version: "v1", discovery_document_uri: "https://raw.githubusercontent.com/kubernetes/kubernetes/master/api/openapi-spec/swagger.json", data: $TOPPODS}}' >> "${OUTPUTFILE}"

echo "Export complete."

echo "Sending export to GCS"
if [[ -f "${OUTPUTFILE}" ]]; then
  # Send export
  if gsutil cp "${OUTPUTFILE}" "gs://${GCS_BUCKET_NAME}/${GCS_BUCKET_FOLDER}/${GCS_FILE_NAME}"; then
    echo "Export JSON sent to GCS"
  else
    echo "ERROR: Unable to send export to GCS!"
    exit 1
  fi

  # Create and send manifest
  echo "${GCS_FILE_NAME}" > "/tmp/${GCS_MANIFEST}"
  if gsutil cp "/tmp/${GCS_MANIFEST}" "gs://${GCS_BUCKET_NAME}/${GCS_BUCKET_FOLDER}/${GCS_MANIFEST}"; then
    echo "Export manifest sent to GCS"
    exit 0
  else
    echo "ERROR: Unable to send manifest to GCS!"
    exit 1
  fi
else
  echo "ERROR: Output file not found"
  exit 1
fi
