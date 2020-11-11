# Data Collection

## Data Sources

* [AWS Cloud Resources](#aws-cloud-resources)
* [Google Cloud Asset Inventory](#google-cloud-asset-inventory)
* [Kubernetes Resources](#kubernetes-resources)


### AWS Cloud Resources

#### Requirements

* [Ability to run AWS-Recon](https://github.com/darkbitio/aws-recon#usage)
* The required IAM Roles are:
  * `arn:aws:iam::aws:policy/SecurityAudit`
  * `arn:aws:iam::aws:policy/job-function/ViewOnlyAccess`
  * Plus the following permissions:
    * `acm:DescribeCertificate`
    * `apigateway:GET`
    * `athena:GetWorkGroup`
    * `codebuild:BatchGetProjects`
    * `codepipeline:GetPipeline`
    * `cloudtrail:List*`
    * `ec2:GetEbsEncryptionByDefault`
    * `ecr:Describe*`
    * `ecr:List*`
    * `eks:Describe*`
    * `eks:List*`
    * `elasticfilesystem:DescribeMountTargetSecurityGroups`
    * `elasticfilesystem:DescribeMountTargets`
    * `elasticmapreduce:DescribeCluster`
    * `elasticmapreduce:DescribeSecurityConfiguration`
    * `events:DescribeRule`
    * `fms:ListComplianceStatus`
    * `fms:ListPolicies`
    * `guardduty:ListDetectors`
    * `guardduty:ListFindings`
    * `guardduty:ListIPSets`
    * `guardduty:ListInvitations`
    * `guardduty:ListMembers`
    * `guardduty:ListThreatIntelSets`
    * `kafka:ListTagsForResource`
    * `kafka:ListClusters`
    * `kafka:DescribeCluster`
    * `kafka:DescribeClusterOperation`
    * `kafka:DescribeConfiguration`
    * `kafka:DescribeConfigurationRevision`
    * `kafka:GetBootstrapBrokers`
    * `kafka:ListConfigurations`
    * `kafka:ListClusterOperations`
    * `kafka:ListNodes`
    * `iam:GenerateCredentialReport`
    * `iam:GenerateServiceLastAccessedDetails`
    * `inspector:DescribeAssessmentRuns`
    * `inspector:DescribeAssessmentTargets`
    * `inspector:DescribeAssessmentTemplates`
    * `inspector:DescribeCrossAccountAccessRole`
    * `inspector:DescribeFindings`
    * `inspector:DescribeResourceGroups`
    * `inspector:DescribeRulesPackages`
    * `iot:DescribeAuthorizer`
    * `iot:DescribeCACertificate`
    * `iot:DescribeCertificate`
    * `iot:DescribeDefaultAuthorizer`
    * `iot:GetPolicy`
    * `iot:GetPolicyVersion`
    * `kms:GetKeyRotationStatus`
    * `lambda:GetFunctionConfiguration`
    * `lightsail:GetInstances`
    * `lightsail:GetLoadBalancers`
    * `opsworks:DescribeStacks`
    * `organizations:Describe*`
    * `organizations:List*`
    * `servicequotas:Get*`
    * `servicequotas:List*`
    * `ses:DescribeActiveReceiptRuleSet`
    * `ses:ListCustomVerificationEmailTemplates`
    * `ses:GetCustomVerificationEmailTemplate`
    * `ses:GetSendStatistics`
    * `ses:GetSendQuota`
    * `ses:DescribeConfigurationSet`
    * `ses:ListReceiptFilters`
    * `ses:GetIdentityMailFromDomainAttributes`
    * `ses:GetIdentityNotificationAttributes`
    * `ses:DescribeReceiptRule`
    * `ses:DescribeActiveReceiptRuleSet`
    * `ses:GetAccountSendingEnabled`
    * `ses:ListConfigurationSets`
    * `ses:DescribeReceiptRuleSet`
    * `ses:ListReceiptRuleSets`
    * `shield:DescribeAttack`
    * `shield:DescribeProtection`
    * `shield:DescribeSubscription`
    * `sso:DescribePermissionsPolicies`
    * `sso:ListApplicationInstanceCertificates`
    * `sso:ListApplicationInstances`
    * `sso:ListApplicationTemplates`
    * `sso:ListApplications`
    * `sso:ListDirectoryAssociations`
    * `sso:ListPermissionSets`
    * `sso:ListProfileAssociations`
    * `sso:ListProfiles`
    * `support:DescribeTrustedAdvisorCheckResult`
    * `support:DescribeTrustedAdvisorChecks`
    * `waf:GetWebACL`
    * `waf:ListWebACLs`
    * `wafv2:GetWebACL`
    * `wafv2:ListWebACLs`
    * `wafv2:ListResourcesForWebACL`
    * `xray:GetEncryptionConfig`

#### Collection

1. Follow the usage steps at [https://github.com/darkbitio/aws-recon#usage](https://github.com/darkbitio/aws-recon#usage) to obtain an AWS Recon inventory file.  The instructions will lead to the generation of a file named `output.json`.
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
