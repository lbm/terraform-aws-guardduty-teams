# Terraform AWS GuardDuty Teams

This project allows you to deploy a simple Microsoft Teams alerting system for AWS GuardDuty findings. When findings are updated, a CloudWatch rule is used to trigger a lambda function which formats and sends the messages.

Written for my blog post: [Integrating AWS GuardDuty with Microsoft Teams][blog-post].

## Requirements

- Terraform >= 0.14
- AWS CLI

## Getting Started

1. Clone this repository locally.
2. Run `terraform --version` and ensure you have at least version 0.14 installed.
3. Check that you have a set of credentials configured for the AWS CLI. Note down the name of the relevant profile.
4. Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars` and modify the parameters to suit your needs (including the profile name from step 3).
5. Change directory to `terraform` and run the following commands:

```sh
terraform init
terraform apply
```

6. After deployment, notifications for updated findings should begin appearing immediately.

## License

This repository is distributed under the terms of the [ISC license](LICENSE.md).

[blog-post]: https://lachlan.io/blog/integrating-aws-guardduty-with-microsoft-teams
