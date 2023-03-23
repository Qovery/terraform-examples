# Deploy services with a specific order

This ready to use example show you how to deploy 3 applications with a specific order. 

Backend 1 -> Backend 2 -> Backend 3

Each backend application have their own [deployment stage](https://hub.qovery.com/docs/using-qovery/deployment/deployment-pipeline/). 

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

6. Clone my [URL Shortener application](https://github.com/evoxmusic/ShortMe-URL-Shortener.git)
7. Edit the `main.tf` file and change `https://github.com/evoxmusic/ShortMe-URL-Shortener.git` with yours
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
