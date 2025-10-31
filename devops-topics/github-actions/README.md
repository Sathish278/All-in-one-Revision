```markdown
# GitHub Actions — interview-ready revision

> Summary: Advanced GitHub Actions patterns — reusable workflows, OIDC, security, caching, and performance tips.
>
> How to use: practice authoring small reusable workflows, use `uses: org/repo/.github/workflows/action.yml@v1`, and apply OIDC for cloud auth in CI.

1) Essentials
- Jobs, steps, actions, runners, matrices, and artifacts.

2) Security
- Use OIDC for short-lived cloud credentials, avoid storing long-lived secrets, and scope tokens/permissions with least privilege.

3) Reusable workflows & composite actions
- Extract common CI steps into reusable workflows and composite actions to reduce duplication and improve maintenance.

4) Performance & caching
- Use `actions/cache` smartly (key by hash of lockfile), prefer workspace-aware caching and re-use runners via self-hosted fleets for heavy builds.

5) Example: OIDC to AWS
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: arn:aws:iam::123456789012:role/GitHubOIDCRole
          aws-region: us-east-1
```

6) Interview Q&A
- Q: Why OIDC over secrets? A: OIDC provides short-lived credentials without storing secrets in the repo, reducing leak risk.

--

I can add ready-to-use workflow templates for CI lint/test/build/deploy if you want.
```
