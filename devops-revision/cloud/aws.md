# AWS - Consolidated Revision

This file consolidates the AWS material from the repository and adds a short quick-commands / checklist section for fast revision.

## Core Concepts
- Regions, Availability Zones (AZs), Edge Locations (PoPs)
- IAM (Users, Groups, Roles, Policies) — principle of least privilege
- MFA, Access Keys, Credential Report, Access Advisor
- RDS Proxy, VPC, Subnets, Route Tables, Security Groups, NACLs
- S3, EC2, RDS, IAM, Lambda, CloudWatch, CloudTrail, Route53

## Short Examples / Notes
- IAM policy structure: Version, Statement (Effect, Action, Resource, Condition)
- Use roles for services: EC2 instance profile, Lambda roles
- Use MFA on root and sensitive users
- Use S3 lifecycle for cost optimization

## Quick Commands / CLI
- Configure CLI:
  aws configure

- IAM
  - List users: aws iam list-users
  - Simulate policy: aws iam simulate-principal-policy --policy-source-arn <arn> --action-names s3:PutObject

- S3
  - Copy local to S3: aws s3 cp file.txt s3://my-bucket/
  - Sync: aws s3 sync ./site s3://my-bucket/ --delete

- EC2
  - Describe instances: aws ec2 describe-instances
  - Start/Stop: aws ec2 start-instances --instance-ids i-0123; aws ec2 stop-instances --instance-ids i-0123

- CloudWatch Logs
  - Tail logs: aws logs tail /aws/lambda/myfn --follow

- STS temporary creds (MFA):
  aws sts get-session-token --serial-number arn:aws:iam::123456789012:mfa/johndoe --token-code 123456

## Revision Checklist
- [ ] Root account MFA enabled
- [ ] No long-term access keys for root
- [ ] IAM roles used for services, least-privilege policies
- [ ] Logging enabled (CloudTrail) and retention policy
- [ ] S3 buckets follow secure settings (block public access)

## Advanced Topics & Definitions

- EKS / ECS / Fargate: managed container platforms. EKS runs upstream Kubernetes; ECR stores images. Fargate is serverless compute for containers.
- VPC design patterns: hub-and-spoke using Transit Gateway or shared VPCs for central services. Use multiple AZ subnets (public/private) and NAT Gateway per AZ for resiliency.
- Transit Gateway vs VPC Peering: TGW scales hub-and-spoke and supports routing policies; peering is simpler but does not transit.
- KMS & envelope encryption: use CMKs (customer-managed) for cross-account encryption and rotate keys. Use encryption in transit + at rest.
- Organizations / SCPs / Identity Center: AWS Organizations for account management, Service Control Policies (SCPs) to restrict services across accounts, AWS IAM Identity Center (SSO) for centralized access.
- Networking: use flow logs, VPC endpoints (Gateway and Interface) for private access to AWS APIs and S3 (VPC endpoint policy for least privilege).
- Observability: CloudWatch Metrics/Logs/Events, CloudWatch Logs Insights, CloudWatch Container Insights, X-Ray for distributed tracing, and OpenTelemetry integration.
- Cost optimization: use Cost Explorer, budgets, RI/Savings Plans, rightsizing recommendations, and tagging strategy for chargeback.

## Advanced CLI Examples

- Assume role (cross-account):

```
aws sts assume-role --role-arn arn:aws:iam::222222222222:role/ReadOnlyRole --role-session-name session1
```

- Create a KMS key (quick):

```
aws kms create-key --description "terraform state key" --key-usage ENCRYPT_DECRYPT
```

- Generate a pre-signed S3 URL (temporary upload):

```
aws s3 presign s3://my-bucket/object.txt --expires-in 3600
```

## Infrastructure-as-Code & CI/CD (notes)

- CloudFormation vs CDK vs Terraform: CloudFormation is native declarative IaC; CDK provides higher-level constructs (synthesizes CFN). Terraform is cloud-agnostic and popular for multi-cloud.
- Use CI pipelines (GitHub Actions / CodePipeline) to lint, plan, and apply changes. Keep `terraform plan -out` artifacts from CI for controlled applies.
- Use change management: PR-based plans, reviewers, and an automated apply step with least-privilege automation roles.

## Security & Governance (advanced checklist)

- Enforce least privilege via IAM policies and usage of assume-role for automation.
- Use AWS Config rules and GuardDuty for continuous compliance and threat detection.
- Encrypt sensitive parameters in Secrets Manager or Parameter Store (SecureString) and reference via IAM roles.
- Use SCPs in Organizations to limit risky services (e.g., disable root-level service creation in non-admin accounts).

## Advanced Patterns & Links

- Use VPC endpoints for private communication to S3 and DynamoDB to avoid internet egress.
- For large orgs, use AWS Control Tower or custom account vending to standardize account setup.
- Consider AWS RAM (Resource Access Manager) for sharing subnets and other resources cross-account.

## References
- ../../Devops/Aws.md
- ../../AWS/README.md
- ../../Interviews-questions/AWS-AZURE-GCP-Cloud.md

