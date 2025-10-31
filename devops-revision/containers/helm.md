# Helm — Package Manager for Kubernetes

Overview
- Helm is a package manager for Kubernetes that packages resources into charts. Charts contain templated manifests, default values, and metadata.
- Use-cases: shareable app packaging, parameterized deployments, release lifecycle (install/upgrade/rollback).

Key Concepts
- Chart: a package containing templates, values.yaml, and Chart.yaml metadata.
- Release: an installed instance of a chart in a Kubernetes cluster.
- Values: user-provided configuration to parameterize templates (values.yaml or `--set`).
- Helm repos: chart repositories (e.g., ArtifactHub, GitHub Pages, OCI registries for charts).

Getting Started (quick)
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-nginx bitnami/nginx --namespace demo --create-namespace
helm list -n demo
helm upgrade my-nginx bitnami/nginx -n demo --set replicaCount=3
helm rollback my-nginx 1 -n demo
```

Example: minimal chart template
```
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "{{ .Chart.Name }}.fullname" . }}
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: app
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: {{ .Values.service.port }}
```

Best Practices
- Keep charts small and focused; extract shared components to dependencies or umbrella charts.
- Use chart testing (ct) and linting: `helm lint`, `helm unittest`.
- Pin chart and dependency versions; use OCI registries for security.
- Store secrets using sealed-secrets / external secret operators; avoid placing secrets in values.yaml in plain text.

CI/CD Integration
- Build-and-push charts in CI (GitHub Actions) and publish to a chartrepo or OCI registry.
- Use `helm diff` in PR validation to show changes between releases.

Advanced: Chart hooks & lifecycle
- Hooks (pre-install, post-upgrade) can run jobs during release lifecycle — use carefully.

References
- https://helm.sh
