# Data Collection

## Data Sources

* [AWS Cloud Resources](#aws-cloud-resources)
* [Google Cloud Asset Inventory](#google-cloud-asset-inventory)
* [Kubernetes Resources](#kubernetes-resources)


### AWS Cloud Resources

#### Requirements

* [Ability to run AWS-Recon](https://github.com/darkbitio/aws-recon#usage)
* AWS Recon needs the IAM Role:
  * `arn:aws:iam::aws:policy/ReadOnlyAccess`
  * Plus the following permissions:
    * `support:DescribeTrustedAdvisor*`

#### Collection

1. Follow the usage steps at [https://github.com/darkbitio/aws-recon#usage](https://github.com/darkbitio/aws-recon#usage) to obtain an AWS Recon inventory file. Be sure to use the custom formatter and output to newline delimited JSON (NDJSON). Note the [OpenCSPM example](https://github.com/darkbitio/aws-recon#example-command-line-options).  The instructions will lead to the generation of a file named `output.json`.
2. In the `opencspm/assets` directory, there is a `demo` directory.  Create a directory named `custom` next to it.
3. Copy the `output.json` into `opencspm/assets/custom/output.json`.
4. Create a `manifest.txt` file next to the `output.json` file inside the `custom` directory.  Run `echo "output.json" > manifest.txt` to populate the first line of the `manifest.txt` with `output.json`.  The loader uses the `manifest.txt` file to know which file names to import.
5. Modify `opencspm/config/config.yaml` to refer to `/app/data/custom` instead of `/app/data/demo`.  e.g.
  ```yaml
  ---
  db:
    host: redis
    port: 6379
  buckets:
    # - gs://my-cspm-bucket-here
    # - s3://my-other-bucket-here
  local_dirs:
    - /app/data/custom
  ```
6. Run `docker-compose down`, `docker-compose up` and wait a few minutes for the import and analysis to take place.


### Google Cloud Asset Inventory

#### Requirements

* The ability to run `collection/scripts/cai-export.sh`
* The ability to enable the [Cloud Asset Inventory API](https://cloud.google.com/asset-inventory/docs/quickstart) and collect data from that API in the current project
* Permissions:
  * Storage Admin/Writer to a new GCS Bucket
  * `Cloud Asset Viewer` to your user identity or service account at the Organization level

#### Collection

1. Create a new GCS bucket in your current GCP project.  e.g. `my-cai-storage-bucket`
2. Assign `roles/cloudasset.viewer` or `roles.cloudasset.owner` to your identity at the organization or folder level
3. In the `opencspm/assets` directory, there is a `demo` directory.  Create a directory named `custom` next to it.
4. Obtain the current organization number via `gcloud organizations list`
5. In the `collection/scripts` directory, run `cai-export.sh -o myorgnumber -b my-cai-storage-bucket -l path/to/opencspm/assets/custom`.  Use `-f folderid` instead of `-o myorgnumber` if the CAI is only to be retrieved for a given folder and below.
6. Modify `opencspm/config/config.yaml` to refer to `/app/data/custom` instead of `/app/data/demo`.  e.g.
  ```yaml
  ---
  db:
    host: redis
    port: 6379
  buckets:
    # - gs://my-cspm-bucket-here
    # - s3://my-other-bucket-here
  local_dirs:
    - /app/data/custom
  ```
7. Run `docker-compose down`, `docker-compose up` and wait a few minutes for the import and analysis to take place.

### Kubernetes Resources

#### Requirements

Coming soon!
