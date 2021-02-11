#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

NAMESPACE_NAME="opencspm"
EXPORTER_GCP_SA_EMAIL="opencspm-gke-exporter@demo2-good.iam.gserviceaccount.com"
SA_NAME="opencspm"
CLUSTERROLE_NAME="opencspm"
CLUSTERROLEBINDING_NAME="opencspm"
CRONJOB_NAME="opencspm-exporter"
EXPORTER_CRON_SCHEDULE_STRING="5 * * * *"
EXPORTER_IMAGE="gcr.io/opencspm/k8s-cai-exporter:v0.1.9"
GCS_BUCKET_NAME="db-collection-us-opencspm"
GCS_BUCKET_FOLDER="k8s"
DEBUG_EXPORT_TIME=""

cat <<EOF
---
apiVersion: v1
kind: Namespace
metadata:
  name: "${NAMESPACE_NAME}"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
  namespace: "${NAMESPACE_NAME}"
automountServiceAccountToken: false  
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    iam.gke.io/gcp-service-account: "${EXPORTER_GCP_SA_EMAIL}"
  name: "${SA_NAME}"
  namespace: "${NAMESPACE_NAME}"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: "${CLUSTERROLE_NAME}"
rules:
- apiGroups:
  - "*"
  resources:
  - "*"
  verbs:
  - get
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: "${CLUSTERROLEBINDING_NAME}"
  namespace: "${NAMESPACE_NAME}"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: "${CLUSTERROLE_NAME}"
subjects:
- kind: ServiceAccount
  name: "${SA_NAME}"
  namespace: "${NAMESPACE_NAME}"
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: "${CRONJOB_NAME}"
  namespace: "${NAMESPACE_NAME}"
spec:
  concurrencyPolicy: Forbid
  schedule: "${EXPORTER_CRON_SCHEDULE_STRING}"
  jobTemplate:
    spec:
      template:
        metadata:       
          annotations:
            container.seccomp.security.alpha.kubernetes.io/opencspm: "runtime/default"
            container.apparmor.security.beta.kubernetes.io/opencspm: "runtime/default"
          labels:         
            app: "${CRONJOB_NAME}"
        spec:
          serviceAccountName: "${SA_NAME}"
          containers:
          - name: opencspm
            image: "${EXPORTER_IMAGE}"
            env:
            - name: "GCS_BUCKET_NAME"
              value: "${GCS_BUCKET_NAME}"
            - name: "GCS_BUCKET_FOLDER"
              value: "${GCS_BUCKET_FOLDER}"
            - name: "DEBUG_EXPORT_TIME"
              value: "${DEBUG_EXPORT_TIME}"
            securityContext:
              runAsUser: 65534
              runAsGroup: 65534
              allowPrivilegeEscalation: false
              capabilities:
                drop: ["ALL"]
          restartPolicy: Never
EOF
