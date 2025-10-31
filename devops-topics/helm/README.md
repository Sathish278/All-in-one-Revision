```markdown
# Helm — interview-ready revision

> Summary: Helm for packaging Kubernetes applications—charts, templates, values, releases, and best practices for CI/CD and GitOps.
>
> How to use: read the templating patterns, practice creating a small chart, and use `helm lint`/`helm test` in CI before releasing.

1) Concepts
- Chart, Chart.yaml, templates, values.yaml, hooks, library charts, and chart repositories.

2) Quick commands
- Install: `helm install myapp ./mychart -n prod`
- Upgrade: `helm upgrade --install myapp ./mychart -f values-prod.yaml`
- Lint: `helm lint ./mychart`

3) Templating tips
- Keep templates simple; use helper `_helpers.tpl` for common labels; avoid heavy logic in templates.

4) CI/CD & GitOps
- Use chart-releaser for publishing charts, or store charts in OCI registries. Use ArgoCD/Flux to deploy charts from Git.

5) Security
- Scan templates for unsafe values, validate inputs, and use image pull policies and image policies in admission controllers.

6) Interview Q&A
- Q: How do you manage secrets with Helm? A: Use external secret stores (SealedSecrets, SOPS, external Secret CRDs) and avoid plaintext secrets in `values.yaml`.

--

I can add a small starter chart skeleton and recommended `values.yaml` conventions if you'd like.
```
