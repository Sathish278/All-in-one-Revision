```markdown
# Terraform — interview-ready revision

> Summary: Practical guide for Terraform focused on infrastructure-as-code patterns, modules, state management, testing, and security.
>
> How to use: read the concepts, try the small examples in a test workspace, and follow the best-practice checks (state locking, backend, CI plan/apply gates).

1) Key concepts
- Resources, Providers, Variables, Outputs, Modules, Workspaces, State file (locking, backends).
- Recommended patterns: small reusable modules, immutability, remote state with locking, and CI-based plan/apply.

2) Minimal example (AWS S3 bucket)
```hcl
provider "aws" { region = "us-east-1" }

resource "aws_s3_bucket" "state" {
  bucket = "my-terraform-state-bucket"
  acl    = "private"
}
```

3) Modules & testing
- Split infra into modules (network, compute, db). Use Terratest or kitchen-terraform for automated tests.
- Example: call module with version pinning and inputs.

4) State & backends
- Use remote backends (S3/GCS + DynamoDB/Storage for locking). Never keep sensitive secrets in state.
- Use `terraform plan` in CI, store artifacts, require human approval for `apply` in prod.

5) Security & secrets
- Do not store secrets in code or plaintext variables. Use external secret stores (AWS Secrets Manager, Vault) or environment variables injected in CI.

6) Common interview Q&A
- Q: How do you handle drift? A: Detect with `terraform plan`, reconcile via plan/apply, and prevent manual changes with policies (policy as code) and RBAC.
- Q: How to reuse modules? A: Publish modules in a registry or VCS and version-pin them. Keep interfaces small and backwards compatible.

--

If you want, I'll create a small module example directory with tests and a CI pipeline to run `terraform fmt`, `terraform validate`, and `terraform plan`.
```
