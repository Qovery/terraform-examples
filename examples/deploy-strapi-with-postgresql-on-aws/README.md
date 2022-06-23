# Deploy Strapi with PostgreSQL on AWS

This ready to use example show you how to deploy a Strapi app with PostgreSQL on AWS and make it accessible via HTTPS. All of that in just a few lines of Terraform file.

## Behind the scene

Behind the scene, Qovery:

1. Creates a complete infrastructure on your AWS account (VPC, Security Groups, Subnet, EKS/Kubernetes...)
2. Creates Qovery resources:
   1. Organization `Terraform Demo`
   2. Project `Strapi V4`
   3. Environment `production`
   4. Database `strapi db`
   5. Application `strapi app`
   6. Inject all the Secrets and Environment Variables used by Strapi
3. Builds `strapi app` application
4. Pushes `strapi app` container image in your ECR registry
5. Deploys your PostgreSQL database and configure the backups and disk encryption (AWS RDS).
6. Deploys it on your EKS cluster (created by Qovery)
7. Creates an AWS Network Load Balancer
8. Generates a TLS certificate for your app
9. Exposes publicly via HTTPS your Strapi app

It will take approximately **20 minutes to create your infrastructure** and **less than 10 minutes to deploy your application**.

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

> If you use this template in production, beware that you have some values to change in `variables.tf`

6. Clone my [Strapi application](https://github.com/evoxmusic/strapi-v4)
7. Edit the `main.tf` file and change `https://github.com/evoxmusic/strapi-v4.git` with yours
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

7. Open your Qovery console to find out the HTTPS URL of your deployed app.
8. To tear down your infrastructure and avoid unnecessary cloud costs you can run `terraform destroy`.
