# Grafana — interview-ready revision

This concise, in-depth guide covers Grafana architecture, provisioning (datasources & dashboards), dashboard JSON basics, alerting, templating, common integrations (Prometheus, Loki, Tempo), and operational best practices with small examples you can copy-paste.

## 1) What is Grafana?
- Grafana is a visualization and analytics platform for time-series and observability data. It supports multiple data sources (Prometheus, Loki, Elasticsearch, Graphite, Tempo, InfluxDB, etc.) and provides dashboards, alerting, and annotation features.

## 2) Architecture
- Frontend (React): dashboard UI, queries
- Backend (server): datasource plugins, auth, provisioning, alerting engine (unified alerting in recent Grafana versions)
- Plugins: panels, datasources, backends
- Storage: Grafana stores dashboards, users, and alert rule metadata in an SQL database (SQLite/Postgres/MySQL).

## 3) Provisioning — immutable infrastructure approach
Provision datasources and dashboards using YAML files (preferred for automation). Place them in `/etc/grafana/provisioning/datasources/` and `/etc/grafana/provisioning/dashboards/` or as Helm chart values.

Example datasource provisioning (Prometheus):

apiVersion: 1
datasources:
- name: Prometheus
  type: prometheus
  access: proxy
  url: http://prometheus:9090
  isDefault: true

Example dashboard provisioning (references a ConfigMap in k8s):

apiVersion: 1
providers:
- name: 'default'
  orgId: 1
  folder: ''
  type: file
  disableDeletion: false
  options:
    path: /var/lib/grafana/dashboards

Dashboard JSON files can be placed under that path and will be loaded automatically.

## 4) Dashboard JSON basics
- A dashboard is a JSON object with panels, templating (variables), and time-range settings.
- Panels contain queries (PromQL), visualization settings, and thresholds.

Minimal panel snippet (PromQL query in a panel):

{
  "type": "timeseries",
  "title": "CPU usage",
  "targets": [
    {
      "expr": "avg by (instance) (rate(node_cpu_seconds_total{mode!='idle'}[5m]))",
      "refId": "A"
    }
  ]
}

Tip: use the Grafana UI to design dashboards, then export JSON for provisioning.

## 5) Variables & templating
- Variables (templating) allow reusing dashboards across clusters/namespaces. Common examples: $cluster, $namespace, $pod.
- Query variable example (Populates a dropdown):
  Data source: Prometheus
  Query: label_values(kube_pod_info, namespace)

## 6) Alerting (Grafana unified alerting)
- Grafana’s unified alerting centralizes alerts from multiple data sources.
- Alert rules are stored in Grafana and can be routed to notification channels (Slack, Opsgenie, PagerDuty, Email).

Example alert rule (Grafana expression using Prometheus):

- name: HighErrorRate
  expr: |
    sum(rate(http_requests_total{job="frontend",status=~"5.."}[5m])) / sum(rate(http_requests_total{job="frontend"}[5m])) > 0.05
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "High error rate on frontend"

Routing and silences are configured in Grafana’s UI or via provisioning for alert notification channels.

## 7) Integrations
- Prometheus (metrics) — primary data source for observability dashboards.
- Loki (logs) — log aggregation that integrates with Grafana Explore and dashboards.
- Tempo (traces) — distributed tracing that can be linked from Grafana panels.
- For end-to-end root cause: link trace/span to logs and metrics via trace IDs in panels and links.

## 8) Observability workflows & best practices
- Use provisioning for reproducibility (infrastructure-as-code).
- Keep dashboard JSON in Git and deploy with CI/CD.
- Use variables for multi-cluster reuse.
- Keep dashboards focused: one problem per dashboard, small panels.
- Use recording rules (Prometheus) for heavy aggregation and reference those in dashboards to save query CPU.

## 9) Performance & scaling
- Grafana querying load depends on data source; reduce dashboard query costs by:
  - Using recording rules in Prometheus
  - Lowering refresh rates
  - Using efficient PromQL and downsampled series from remote storage
- For large deployments, run Grafana in a scaled, stateless mode with a shared SQL backend and use a sidecar for dashboard provisioning.

## 10) Security
- Restrict dashboard access with orgs, teams, and roles.
- Use OAuth/OIDC for SSO integration (Azure AD, Okta, GitHub).
- Secure data sources and ensure Prometheus endpoints are not publicly exposed.

## 11) Example: Deploy Grafana with Helm (basic)

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana --namespace monitoring --create-namespace \
  --set adminPassword='S3cr3t' \
  --set persistence.enabled=true \
  --set datasources."datasources\.yaml".apiVersion=1 \
  --set datasources."datasources\.yaml".datasources[0].name=Prometheus \
  --set datasources."datasources\.yaml".datasources[0].type=prometheus \
  --set datasources."datasources\.yaml".datasources[0].url=http://prometheus:9090

Note: use Helm values files for maintainability instead of long CLI overrides.

## 12) Dashboard example linking logs & traces
- Add a panel with a link to Loki for logs filtered by label values from the selected panel. Use variables to pass $instance or $pod to a dashboard link.

## 13) Troubleshooting
- 401/403 when loading dashboards: check API key, datasource permissions, and Grafana role mappings.
- Slow dashboard load: inspect datasource query times, use Prometheus query inspector, reduce panel complexity.

## 14) Interview Q&A
- Q: How do you provision dashboards in GitOps?
  A: Store dashboard JSON in Git, use provisioning (file provider / dashboard sidecar) or the Grafana operator to sync dashboards from ConfigMaps/CRDs into Grafana.

- Q: When would you use Loki vs. Elasticsearch?
  A: Use Loki for Kubernetes-native, low-cost logs with label-based queries; Elasticsearch is better for full-text search and complex query needs but typically costs more at scale.

--

If this looks good I'll:
- add a sample dashboard JSON file in `devops-revision/topics/grafana/examples/`,
- or create a small Helm values file example for provisioning in `devops-revision/topics/grafana/values.yaml`.
