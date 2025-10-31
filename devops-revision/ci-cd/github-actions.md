# GitHub Actions — CI/CD Workflows

Overview
- GitHub Actions provides workflow automation (CI/CD) with YAML-based workflows triggered on events (push, pull_request, schedule).

Example: CI workflow for building and testing a Docker image
```yaml
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          push: false
          tags: user/app:latest
      - name: Run tests
        run: |
          docker run --rm user/app:latest ./run-tests.sh
```

Secrets & Security
- Store credentials in repository secrets or organization secrets. Use OIDC where possible for short-lived token access to cloud providers.

Advanced: Reusable workflows & composite actions
- Create reusable workflows and call them with `uses: ./.github/workflows/ci.yml` or use composite actions to share steps.

Best Practices
- Keep secrets out of logs, prefer OIDC for cloud auth, and pin action versions.

References
- https://docs.github.com/actions
