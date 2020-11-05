#!/usr/bin/env bash

set -ueo pipefail

command -v gcloud >/dev/null 2>&1 || { echo "I require gcloud but it's not installed.  Aborting." >&2; exit 1; }
command -v gsutil >/dev/null 2>&1 || { echo "I require gsutil but it's not installed.  Aborting." >&2; exit 1; }

die() { echo "$*" >&2; exit 2; }
needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; }

function usage {
  echo "Usage:"
}
# Defaults
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
    ??* )                   die "Illegal option --$OPT" ;;  # bad long option
    ? )                     exit 2 ;;  # bad short option (error reported via getopts)
  esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list

TARGET_EXPORT_RESOURCE=''
TARGET_PROJECT_ID=''
validate_export_location() {
  if [ -z "${1}" ] && [ -z "${2}" ] && [ -z "${3}" ]; then
    echo "ERROR: Organization ID, Folder ID, or Project ID not set"
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

  #read -p "Are you sure? " -n 1 -r
  echo    # (optional) move to a new line
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
  for TYPE in resource iam_policy org_policy access_policy; do
    echo "${EXPORTTIME}-${TYPE}.json" >> "$localpath/manifest.txt"
  done
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
