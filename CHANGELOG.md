# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- fix: CKV2_AWS_28 Ensure public facing ALB are protected by WAF
- feat: more than one security group for ecs service
- feat: Add EC2 usage example
- feat: Possibly use lb module for load-balancer resource
- feat: Review ecs-service arguments, add and test those missing.
- feat: Use load-balancer module in example
- feat: Add more options for module cloudwatch log group
- feat: Exclusively use acm certificate (not self_signed_cert) for complete example
- feat: use updated vpc source in examples
- feat: use updated ecs cluster source for ecs cluster
- feat: consolidate ecs cluster module and ecs service module into one
- feat: create only one kms key for encryption.

## [1.1.6] - 2023-02-03
### Changes
- fix : CKV_AWS_91: "Ensure the ELBv2 (Application/Network) has access logging enabled"
- added new github workflow files

## [1.1.5] - 2022-10-20
### Changes
- fix: CKV_AWS_111 #Ensure IAM policies does not allow write access without constraints
- fix: CKV_AWS_158 #Ensure that CloudWatch Log Group is encrypted by KMS
- hotfix: deployment controller in minimum example
- fix: egress rules for fargate example

## [1.1.4] - 2022-10-10
### Changes
- fix: CKV_AWS_103: "Ensure that load balancer is using TLS 1.2"
- feat: update files
- feat: update github workflows
- feat: Add supporting resources (vpc and ecs cluster)
- feat: Make creation of KMS Key optional (i.e external KMS key can be used)

## [1.1.3] - 2022-08-29
### Changes
- fix: CKV_AWS_91: "Ensure the ELBv2 (Application/Network) has access logging enabled"
- fix: CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
- feat: update workflow jobs
- feat: restructure ingress and egress conf blocks

## [1.1.2] - 2022-07-28
### Changes
- fix: stopped (scaling activity initiated by (deployment ecs-svc/<number>))
- feat: dynamic rules for load-balancer security group
- feat: dynamic rules for service security group
- fix: Update in-place when `tfplan` or `tfapply` is done(triggered by task-definition resource)

## [1.1.1] - 2022-07-14
### Changes
- fix: CKV2_AWS_20 Ensure that ALB redirects HTTP requests into HTTPS ones

## [1.1.0] - 2022-07-08
### Changes
- Added the `.github/workflow` folder (not supposed to run gitcommit)
- Re-factored examples (`minimum`, `complete` and additional)
- Added `CHANGELOG.md`
- Added `CODEOWNERS`
- Added `versions.tf`, which is important for pre-commit checks
- Added `Makefile` for examples automation
- Added `.gitignore` file

## [1.0.0] - 2022-04-12
### Changes
- fix: description correction
- fix: removed deprecated examples.
- feat: count variables removal
- feat: README & source update
- feat: ecs-service upgrade (#3)
- feat: ec2 example and service auto-scaling
- feat: feature update.
- feat: initial code commit

[Unreleased]: https://github.com/boldlink/terraform-aws-ecs-service/compare/1.1.5...HEAD
[1.1.6]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.6
[1.1.5]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.5
[1.1.4]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.4
[1.1.3]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.3
[1.1.2]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.2
[1.1.1]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.1
[1.1.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.0
[1.0.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.0.0
