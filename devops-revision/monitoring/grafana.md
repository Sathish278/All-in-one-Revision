
# Grafana — Deep Dive for Senior SRE / DevOps Interviews

Goal
- This page is an interview- and hands-on-focused deep dive into Grafana. Read it to prepare for senior SRE/DevOps interviews: architecture, deployment patterns, provisioning-as-code, dashboard design, alerting, security, scaling, common pitfalls, and a practical lab.

## Quick contract
- Inputs: metrics (Prometheus), logs (Loki/Elasticsearch), traces (Tempo/OpenTelemetry), traces & metrics may be combined in dashboards.
- Outputs: dashboards (JSON), alerts (notifications), saved queries, snapshots, reporting.
- Success criteria: reproducible dashboard provisioning, scalable read/query path, secure access, reliable alerting with low false positive rate.

## Architecture & Components
- Grafana server: stateless application that renders dashboards and executes queries against data sources.
- Data sources: external systems (Prometheus, Loki, Elasticsearch, Graphite, PostgreSQL, InfluxDB, Tempo). Grafana queries these at render time.
- Backend storage: Grafana uses an external SQL database (SQLite by default for local dev; Postgres/MySQL recommended for production) to store dashboards, users, and alerting state.
- Plugins: datasource and panel plugins extend Grafana (install via provisioning or the UI).
- Alerting: unified alerting (Grafana 8+) handles both Prometheus-style rule alerts and Grafana alert rules. Alertmanager integration still common for Prometheus-centric pipelines.

Diagram (conceptual):
- Instrumented apps -> Prometheus & Loki -> Grafana queries -> Grafana renders dashboards; Alerting pushes to channels (Slack/PagerDuty/Email)

## Provisioning-as-Code (recommended for interviews)
- Grafana supports provisioning of data sources, dashboards, and alerting via YAML files. This should be stored in Git and deployed with CI/CD.

Example: `datasource.yaml` provisioning (file-based)

```yaml
apiVersion: 1
datasources:
- name: Prometheus
  type: prometheus
  access: proxy
  url: http://prometheus-operated:9090
  isDefault: true
  editable: false

- name: Loki
  type: loki
  access: proxy
  url: http://loki:3100
  editable: false
```

Dashboard provisioning (simple `dashboards.yaml`):

```yaml
apiVersion: 1
providers:
- name: 'default'
  orgId: 1
  folder: 'Provisioned'
  type: file
  disableDeletion: false
  options:
    path: /var/lib/grafana/dashboards
```

Place dashboard JSON files under the provisioned `path` and Grafana will import them at startup.

## Dashboard Design & Templating
- Panels: the building blocks (graphs, tables, heatmaps, stat, gauge).
- Queries: each panel issues queries to its datasource (PromQL for Prometheus, LogQL for Loki).
- Variables: template variables let users pick environment/cluster/instance; use `query` type variables to populate values from the datasource.
- Reusable panels: store panel JSON in a library or use dashboard templating to share.

Example PromQL (error rate panel):

```
sum(rate(http_requests_total{job="my-app",status=~"5.."}[5m]))
/ sum(rate(http_requests_total{job="my-app"}[5m]))
```

Example Loki query (errors in last 5m):

```
{app="my-app"} |= "ERROR" | count_over_time({app="my-app"}[5m])
```

## Alerting — Concepts & Examples
- Types: Grafana can evaluate alert rules (panel-based or query-based) and send notifications via contact points (Slack, PagerDuty, Webhook, Email).
- Notification policies: route alerts to different channels based on labels/severity.
- Silence & deduplication: Grafana supports silences; use blackboxing/maintenance windows in notification policies.

Example: simple Grafana alert rule (using query-based alerting)

```yaml
apiVersion: 1
kind: AlertRule
metadata:
  name: HighErrorRate
spec:
  for: 5m
  expr: |
    sum(rate(http_requests_total{job="api",status=~"5.."}[5m]))
    / sum(rate(http_requests_total{job="api"}[5m])) > 0.05
  labels:
    severity: page
  annotations:
    summary: High 5xx rate for API
```

Note: Grafana Alerting configuration syntax differs between versions; many teams continue to integrate Prometheus Alertmanager for advanced routing and existing workflows.

## Security & Multi-tenancy
- Authentication: support for OAuth/LDAP/Proxy/Basic; OIDC recommended for SSO integration.
- Authorization: teams, folders, and role-based access control (Admin/Editor/Viewer). Grafana Enterprise adds fine-grained RBAC.
- Sensitive data: avoid embedding credentials in dashboard JSON; use secrets management and provisioning using environment variables or Kubernetes secrets.

## Scaling & HA
- Grafana server is mostly stateless; scale horizontally behind a load balancer. Use a shared external SQL database (Postgres/MySQL) for state.
- For alerting state and high-availability, Grafana Enterprise offers clustering and HA features; OSS users often use active-passive setups or rely on Grafana Cloud.
- Caching: Grafana caches panel data for short durations; tune datasource timeouts and connection pooling for large installations.

## Performance Tips
- Use recording rules in Prometheus to precompute heavy queries used by Grafana.
- Limit dashboard time-range default (e.g., 1h) to avoid heavy long-range queries on dashboards.
- Use downsampling/aggregated series for long-range panels.

## Troubleshooting
- 401/403 when querying datasource: check datasource credentials and proxy settings; validate with `curl` to the datasource endpoint from Grafana pod.
- Slow dashboards: check query performance in Prometheus (`/api/v1/query_range`) and use `explain` or Prometheus debug endpoints; consider adding recording rules.
- Missing dashboard provisioning: check file permissions and Grafana logs for provisioning errors at startup.

## Grafana Interview Q&A (practice answers)

Q: How do you provision Grafana dashboards and datasources in a GitOps pipeline?
A: Use Grafana's provisioning feature: commit `datasources/*.yaml` and `dashboards/*.json` to a repo and apply them via CI to the Grafana instance (or bake them into container images). For Kubernetes, use Helm with values for provisioning, or use the `grafana-operator` to manage dashboards and datasources as CRDs.

Q: Explain how you would make Grafana dashboards reproducible and peer-reviewed.
A: Store dashboards as JSON in Git, use PR reviews for dashboard changes, run linting (grafana-dashboard-linter), and automate deployment via CI to the provisioning directory. Use dashboard versioning and changelogs.

Q: How do Grafana and Prometheus work together for alerting?
A: Prometheus traditionally evaluates alerting rules and sends alerts to Alertmanager. Grafana's unified alerting can also evaluate queries and send notifications to various channels. Many teams use both: Prometheus + Alertmanager for Prometheus-native alerts, Grafana for cross-datasource alerting and visual escalation.

## Quick revision cheat-sheet

- Common UI endpoints: `/explore`, `/dashboards`, `/api/dashboards/uid/<uid>`, provisioning logs in Grafana server startup output.
- Provisioning paths: `/etc/grafana/provisioning/datasources` and `/etc/grafana/provisioning/dashboards` when using container mounts.
- Key interview points:
  - Explain provisioning-as-code and why it's critical for reproducible dashboards.
  - Describe how Grafana queries data sources at render time and implications for query performance.
  - Explain alerting options (Prometheus+Alertmanager vs Grafana unified alerting) and routing to notification channels.

## Further Reading / Tools
- Grafana provisioning docs: https://grafana.com/docs/grafana/latest/administration/provisioning/
- Grafana dashboard best practices: https://grafana.com/docs/grafana/latest/dashboards/
- Grafana Labs blog and community dashboards

