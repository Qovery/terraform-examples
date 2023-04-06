# Deploy a lifecycle job

This ready to use example show you how to deploy a lifecycle job from GitHub (and from an image) on AWS. All of that in just a few lines of Terraform file.

Terraform providers used:

- [Qovery](https://registry.terraform.io/providers/qovery/qovery/latest/docs)


## Behind the scene

Behind the scene, Qovery:

1. Creates a complete infrastructure on your AWS account (VPC, Security Groups, Subnet, EKS/Kubernetes...)
2. Creates Qovery resources:
  1. Organization `Terraform Demo`
  2. Project `lifecycle-job`
  3. Environment `production`
  4. Application `lifecycle-job`
3. Builds `echo app` application
4. Pushes `echo app` container image in your ECR registry
5. Deploys it on your EKS cluster (created by Qovery) and run it on the schedule you've defined

It will take approximately **20 minutes to create your infrastructure** and **less than 5 minutes to deploy your lifecycle job**.

## How to use

1. Clone this repository
2. Sign in to [Qovery](https://www.qovery.com)
3. Install the [Qovery CLI](https://hub.qovery.com/docs/using-qovery/interface/cli/) and [generate an API Token](https://hub.qovery.com/docs/using-qovery/interface/cli/#generate-api-token) with this guide.
4. Generate your AWS credentials (`Access Key ID` and `Secret Access Key`)
   with [this guide](https://hub.qovery.com/docs/using-qovery/configuration/cloud-service-provider/amazon-web-services/#connect-your-aws-account)
5. Open you terminal and run the following command by changing the values:

```shell
export TF_VAR_aws_access_key_id=YOUR_AWS_ACCESS_KEY_ID \
TF_VAR_aws_secret_access_key=YOUR_AWS_SECRET_ACCESS_KEY \
TF_VAR_qovery_access_token=YOUR_QOVERY_API_TOKEN \
TF_VAR_qovery_organization_id=YOUR_QOVERY_ORG_ID
```

6. Clone my [Echo app](https://github.com/Qovery/terraform-provider-testing.git)
7. Edit the `main.tf` file and change:
- Resource `resource "qovery_job" "lifecycle-job"` field `source.git_repository.url` (=`https://github.com/Qovery/terraform-provider-testing.git`) with yours
- Resource `resource "qovery_job" "lifecycle-job"` field `source.git_repository.branch` (=`job-echo-n-seconds`) with yours
8. You can now run the Terraform commands

```shell
terraform init
```

```shell
terraform plan
```

```shell
terraform apply
```

7. Open your Qovery console to find out the newly created lifecycle job.
8. To tear down your infrastructure and avoid unnecessary cloud costs you can run `terraform destroy`.
