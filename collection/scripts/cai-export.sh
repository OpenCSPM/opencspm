#!/usr/bin/env bash

set -ueo pipefail

command -v gcloud >/dev/null 2>&1 || { echo "gcloud is not in the current path or is not installed.  Aborting." >&2; exit 1; }
command -v gsutil >/dev/null 2>&1 || { echo "gsutil is not in the current path or is not installed.  Aborting." >&2; exit 1; }

needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; }

function usage {
  echo ""
  echo "Usage:"
  echo ""
  echo "# Export from an entire org to a GCS bucket"
  echo "./cai-export.sh -o 1234567890 -b gs://mybucketname"
  echo ""
  echo "# Export at a folder and below to a GCS bucket"
  echo "./cai-export.sh -f 0987654321 -b gs://mybucketname"
  echo ""
  echo "Filtering for certain projects:"
  echo ""
  echo "To include only resources from a list of projects that"
  echo "are beneath the org or folder id, create a file called"
  echo "projectnumbers.txt in the same folder as cai-export.sh"
  echo "and insert the project NUMBER (not project name or id)"
  echo "one per line. Use 'gcloud projects list' to determine"
  echo "the correct number(s). e.g."
  echo ""
  echo "$ cat projectnumbers.txt"
  echo "489234872394"
  echo "839539393848"
  echo ""
}

orgid=''
folderid=''
bucketpath=''
localpath='.'

while getopts o:f:p:t:b:l:-: OPT; do
  if [ "$OPT" = "-" ]; then
    OPT="${OPTARG%%=*}"
    OPTARG="${OPTARG#$OPT}"
    OPTARG="${OPTARG#=}"
  fi
  case "$OPT" in
    o | orgid )             needs_arg; orgid="$OPTARG" ;;
    f | folderid )          needs_arg; folderid="$OPTARG" ;;
    b | bucketpath )        needs_arg; bucketpath="$OPTARG" ;;
    l | localpath )         needs_arg; localpath="$OPTARG" ;;
    ??* )                   usage ;;
    ? )                     exit 2 ;;
  esac
done
shift $((OPTIND-1))

TARGET_EXPORT_RESOURCE=''
TARGET_PROJECT_ID=''
validate_export_location() {
  if [ -z "${1}" ] && [ -z "${2}" ]; then
    echo "ERROR: Organization ID or Folder ID not set"
    usage
    exit 1
  fi
  if [ ! -z "${1}" ]; then
    TARGET_EXPORT_RESOURCE="--organization=${1}"
    return 0
  fi
  if [ ! -z "${2}" ]; then
    TARGET_EXPORT_RESOURCE="--folder=${2}"
    return 0
  fi
}


validate_paths() {
  if [ -z "${1}" ]; then
    echo "ERROR: Bucket/Path not set"
    usage
    exit 1
  fi
  if [ -z "${2}" ]; then
    echo "ERROR: Local Destination Path not set"
    usage
    exit 1
  fi
}

validate_approach() {
  read -p "Export ${TARGET_EXPORT_RESOURCE} to ${bucketpath}/*.json using the CAI API in project ${TARGET_PROJECT_ID}? (y/n):" -n 1 -r

  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    return 0
  else
    echo "Aborting..."
    exit 0
  fi
}

collect_cai() {
  for TYPE in resource iam-policy org-policy access-policy; do
    gcloud beta asset export "${TARGET_EXPORT_RESOURCE}" --output-path="${bucketpath}/${EXPORTTIME}-${TYPE}.json" --content-type="${TYPE}"
  done
}
wait_for_cai() {
  echo -n "Waiting for gsutil ls ${bucketpath}/${EXPORTTIME}-*.json to have all files present..."
  n=0
  until [ "$n" -ge 60 ]
  do
     echo -n "."
     if [ "$(gsutil ls ${bucketpath}/${EXPORTTIME}-\*.json 2> /dev/null| wc -l | xargs)" -ge 4 ]; then
       echo "All files present."
       break
     fi
     n=$((n+1))
     sleep 10
  done
}
copy_cai_locally() {
  echo "Copying CAI Exports to ${localpath}/"
  gsutil cp "${bucketpath}/${EXPORTTIME}-*.json" "$localpath"
  cat /dev/null > "$localpath/manifest.txt"
  for TYPE in resource iam-policy org-policy access-policy; do
    echo "${EXPORTTIME}-${TYPE}.json" >> "$localpath/manifest.txt"
  done
}

filter_cai() {
  PROJECT_NUMBERS_FILE="projectnumbers.txt"
  if [ -f "${PROJECT_NUMBERS_FILE}" ]; then
    command -v jq >/dev/null 2>&1 || { echo "jq is not in the current path or is not installed.  Unable to filter results." >&2; exit 1; }
    for TYPE in resource iam-policy org-policy access-policy; do
      echo "Filtering: ${EXPORTTIME}-${TYPE}.json"
      # Start with a clean file
      cat /dev/null > "${EXPORTTIME}-${TYPE}-filtered.json"
      # maintain all objects in folders or orgs (aka "not in projects")
      cat "${EXPORTTIME}-${TYPE}.json" | jq -c 'select(.ancestors[0] | contains ("projects/") | not)' > "${EXPORTTIME}-${TYPE}-filtered.json"
      # Filter for only the project numbers listed in projectids.txt
      while IFS= read -r line; do
        echo "Extracting resources from project number: $line to ${EXPORTTIME}-${TYPE}-filtered.json"
        cat "${EXPORTTIME}-${TYPE}.json" | jq -c --arg PROJECTNUMBER "projects/${line}" 'select(.ancestors[0] | contains ($PROJECTNUMBER))' >> "${EXPORTTIME}-${TYPE}-filtered.json"
      done < "${PROJECT_NUMBERS_FILE}"
    done
  else
    echo "Skipping filtering for project numbers as: ${PROJECT_NUMBERS_FILE} does not exist"
  fi
}

validate_export_location "$orgid" "$folderid"
validate_paths "$bucketpath" "$localpath"
TARGET_PROJECT_ID="$(gcloud config get-value project --quiet)"
validate_approach
EXPORTTIME="$(date +%s)"
#EXPORTTIME="1604549648" # testing
collect_cai
wait_for_cai
copy_cai_locally
filter_cai
