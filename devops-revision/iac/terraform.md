# Terraform - Consolidated Revision

This is a condensed Terraform revision file with quick examples and common commands.

## Key Concepts
- Configuration files (*.tf), variables, outputs, locals, modules
- State: local vs remote (S3 + DynamoDB for locking)
- Workspaces for multiple environments
- Meta-arguments: count, for_each, depends_on, lifecycle
- Provider blocks and provider versioning (terraform.lock.hcl)

## Quick Commands
- init: terraform init
- validate: terraform validate
- plan: terraform plan -out=tfplan
- apply: terraform apply tfplan
- fmt: terraform fmt
- graph: terraform graph -type=plan | dot -Tpng > graph.png

## Best Practices
- Use remote state and locking
- Keep secrets out of code (use Vault or Secrets Manager)
- Use modules for reuse and clarity
- Pin provider versions and check terraform.lock.hcl

## Useful Examples
- Backend S3 + DynamoDB:
```
backend "s3" {
  bucket = "my-terraform-state"
  key    = "envs/prod/terraform.tfstate"
  region = "us-east-1"
  dynamodb_table = "state-lock"
}
```

## References
- ../../Devops/Terraform.md
- ../../Interviews-questions/terraform.md

## Advanced Terraform Topics

- State management (advanced): remote state locking with S3 + DynamoDB prevents concurrent writes; enable state encryption and restrict access with IAM. For sensitive state, consider additional encryption layers.
- State import & partial state: use `terraform import` to bring existing resources under management; be careful to match resource addresses and import one-by-one.
- Backend migration: use `terraform init -migrate-state` when changing backends; test in a non-production workspace first.
- Modules: publish reusable modules (registry or private), design with inputs/outputs, and follow the module composition pattern (root module delegates to child modules).
- Module patterns: use composition (module-per-layer), test modules independently, keep modules small and focused, and version modules semantically.
- Workspaces caveats: workspaces are not namespaces for resource names — they are best for small variations; prefer separate state files per environment or separate workspaces with a solid naming strategy.
- Testing & scanning: use Terratest (Go), kitchen-terraform, and static scanners (tfsec, Checkov) in CI. Add `terraform validate` and `terraform plan` checks in PR pipelines.
- CI integration (example snippet for GitHub Actions):

```yaml
name: Terraform CI
on: [pull_request]
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Terraform Init
        run: terraform init -backend-config="bucket=my-terraform-state"
      - name: Terraform Validate
        run: terraform validate
      - name: Terraform Plan
        run: terraform plan -no-color -out=tfplan
      - name: Upload Plan
        uses: actions/upload-artifact@v3
        with:
          name: tfplan
          path: tfplan
```

## Advanced Patterns & Troubleshooting

- Handling secrets: never put secrets in tfvars files in source control. Use data sources that read from Vault/Secrets Manager at runtime, or use remote state with restricted access.
- Drift detection: run `terraform plan` periodically in CI to detect drift; consider `terraform refresh` where appropriate.
- Partial applies: use `-target` sparingly. Prefer making incremental changes via modules.
- Provider versioning: pin providers and review provider changelogs before upgrades; test upgrades in a staging workspace.

## Security & Governance

- Limit who can run `terraform apply` against production. Use an automation role with a narrow policy for CI/CD applies.
- Use policy-as-code (Sentinel, Open Policy Agent) or tfsec in the pipeline to enforce guardrails.

## References & Further Reading
- https://www.terraform.io/docs/state/overview.html
- https://www.terraform.io/language/modules
- https://github.com/gruntwork-io/terratest

