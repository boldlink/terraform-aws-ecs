# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- fix: Incomplete example for EC2 since it was done before the ecs-cluster module hence used a hard-coded value used for a cluster that had ec2 instances
- fix: CKV2_AWS_28 Ensure public facing ALB are protected by WAF
- fix: Update in-place when `tfplan` or `tfapply` is done
- fix: stopped (scaling activity initiated by (deployment ecs-svc/<number>))
- feat: Add EC2 usage example
- feat: Add more features to the root module lb
- feat: Module restructure
- feat: Add missing features/upgrade
- feat: Use load-balancer module in example
- feat: Add more options for module cloudwatch log group
- feat: Exclusively use acm certificate (not self_signed_cert) for complete example
- feat: Modify SG configuration to allow dynamic ingress and egress block

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

[Unreleased]: https://github.com/boldlink/terraform-aws-ecs-service/compare/1.1.0...HEAD

[1.1.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.1.0
[1.0.0]: https://github.com/boldlink/terraform-aws-ecs-service/releases/tag/1.0.0
