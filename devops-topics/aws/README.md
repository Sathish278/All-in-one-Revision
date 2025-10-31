```markdown
# AWS — interview-ready revision

> Summary: Core AWS services and platform patterns SREs/platform engineers must know — networking, IAM, compute, storage, and common operational tasks.
>
> How to use: review architectures, practice common CLI commands in a sandbox account, and map services to fault-tolerance patterns.

1) Core services & patterns
- VPC, Subnets, Route Tables, NAT, Security Groups, NACLs.
- EC2, Auto Scaling Groups, Load Balancers (ALB/NLB), EBS, S3, RDS, EKS.
- IAM: roles, policies, instance profiles, least privilege, and cross-account access.

2) Quick CLI examples
- List EC2 instances: `aws ec2 describe-instances --region us-east-1`
- Describe S3 buckets: `aws s3 ls`

3) High availability patterns
- Multi-AZ deployments, cross-region replication (S3 replication, RDS read-replicas), route53 health checks & failover.

4) Security & governance
- Use IAM roles and policies, enable CloudTrail, guardrails via SCPs and AWS Organizations, and use AWS Config for drift detection.

5) Cost engineering
- Rightsize instances, spot instances, savings plans, and tagging for cost allocation.

6) Interview Q&A
- Q: How do you securely provide pods with AWS credentials? A: Use IAM roles for service accounts (IRSA) with OIDC or pass short-lived credentials via Vault.

--

I can add architecture diagrams, IAM least-privilege examples, and a short cost-optimization checklist if you want.
```
