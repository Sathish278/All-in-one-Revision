
# Prometheus — In-depth Guide for SRE & Senior DevOps Interviews

This page is a focused, interview-oriented deep dive into Prometheus: architecture, deployment patterns, scaling and long-term storage, PromQL examples, alerting best practices, troubleshooting, and hands-on lab exercises you can use to prepare for senior SRE/DevOps interviews.

## Quick contract
- Inputs: instrumented apps exposing /metrics (Prometheus exposition format) or push via exporters/remote_write
- Outputs: time-series metrics, recording rules, alerts routed via Alertmanager, dashboards in Grafana
- Success criteria: reliable scraping, low-cardinality metric design, alerting with actionable runbooks, long-term storage for SLO/analytics

## Architecture & Components
- Server: single binary (prometheus) that scrapes targets, evaluates rules, and serves HTTP API/UI.
- Storage: local TSDB (default), suitable for short retention (~weeks). For long retention, use remote_write to durable backends.
- Service discovery: Kubernetes SD, Consul, DNS, static_configs, file_sd, cloud providers (GCE, EC2).
- Exporters: node_exporter, blackbox_exporter, cAdvisor, mysqld_exporter — expose metrics in Prometheus format.
- Alertmanager: receives alerts, deduplicates, groups, routes to receivers (Slack, PagerDuty), supports silences and inhibition.

## Deployment patterns
- Single Prometheus per cluster (simpler) vs multiple per namespace or per team (isolation). Many orgs use Thanos/Cortex for multi-cluster aggregation.
- Operator-based installs (kube-prometheus-stack) provide CRDs and automation for Prometheus, Alertmanager, and Grafana.
- Scrape discovery in Kubernetes: prefer `kubernetes_sd_configs` with relabeling to map k8s metadata to labels.

## PromQL Essentials (engineers must be fluent)
- Basic rate over window:

```
rate(http_requests_total[5m])
```

- Instant vector vs range vector: `up` is an instant vector; `http_requests_total[5m]` is a range vector.
- Aggregations examples:

```
sum(rate(http_requests_total{job="api"}[5m])) by (instance)
sum(rate(http_requests_total{job="api"}[5m])) by (job)
```

- Ratio / error rate example:

```
sum(rate(http_requests_total{status=~"5.."}[5m]))
/ sum(rate(http_requests_total[5m]))
```

- Histogram usage (e.g., request duration): use `histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))` for p95 latency.

## Recording Rules & Alerts (examples and rationale)
- Recording rules: precompute expensive queries to speed up dashboards and alerts.

Example recording rule (record: job:http_requests:rate5m):

```yaml
groups:
- name: recording.rules
  rules:
  - record: job:http_requests:rate5m
    expr: sum(rate(http_requests_total[5m])) by (job)
```

- Alerting rules should be actionable and targeted to a team with a runbook link.

Example alert (HighErrorRate):

```yaml
groups:
- name: app.rules
  rules:
  - alert: HighErrorRate
    expr: (
      sum(rate(http_requests_total{job="api",status=~"5.."}[5m]))
      / sum(rate(http_requests_total{job="api"}[5m]))
    ) > 0.05
    for: 5m
    labels:
      severity: page
    annotations:
      summary: "High 5xx error rate for API (>5%)"
      runbook: "https://wiki.example.com/runbooks/high-error-rate"
```

## Scaling & Long-term storage
- Local retention: Prometheus local TSDB is efficient but not intended for multi-week/month retention at scale.
- Remote storage solutions:
  - Thanos: sidecar + object storage (S3/GCS), store, ruler, compact, query, and receive components for global view.
  - Cortex: multi-tenant, horizontally scalable TSDB with ingesters, distributors, and queriers.
  - Mimir (Grafana Mimir) and VictoriaMetrics are alternatives for scale and cost.
- Pattern: run one Prometheus per cluster with sidecar to remote storage (Thanos) for global queries and durable retention.

## Federation vs remote_write
- Federation: Prometheus can scrape other Prometheus servers for specific metrics (useful for rollups). Not ideal for high-cardinality or large-scale rollups.
- remote_write: push metrics to scalable, often external, long-term stores; recommended for long retention and multi-cluster ingestion.

## High-cardinality & label design
- Avoid labels with high cardinality (user IDs, request IDs, session IDs). Cardinaility explodes series and increases storage and query cost.
- Use labels for dimensions that make sense for aggregation (job, instance, environment, region).

## Alertmanager routing & silencing (advanced)
- Route tree: use `group_by`, `group_wait`, `group_interval`, `repeat_interval` to control noise.
- Receivers: define different receivers for pages vs tickets vs low-severity notifications.
- Inhibition: suppress alerts when a higher-priority alert is firing (e.g., inhibit low-priority alerts when cluster is down).

Example alertmanager config (snippet):

```yaml
route:
  receiver: 'team-email'
  group_by: ['alertname', 'cluster']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h
  routes:
    - match:
        severity: page
      receiver: 'pagerduty'
receivers:
  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: '<PD_KEY>'
  - name: 'team-email'
    email_configs:
      - to: 'team@example.com'
```

## Troubleshooting & Debugging
- Check scrape health: `/targets` endpoint in Prometheus UI; fix TLS/auth or relabeling issues.
- Slow queries: use `status/tsdb` to inspect series; use `promtool tsdb analyze` for offline diagnostics.
- High memory usage: check series churn, high-cardinality metrics, or long query range windows.
- Missing metrics: ensure exporter is exposing /metrics and has correct content-type; check network policies in k8s.

## Security & Operations
- Use network policies or service mesh to limit access to Prometheus endpoints.
- Protect the Prometheus UI/API with OIDC or reverse-proxy auth in production; restrict write endpoints.
- Limit who can run PromQL queries or access data that might contain sensitive labels.

## Prometheus Interview Q&A (sample, study these and practice answering)

Q: How does Prometheus handle high-cardinality labels? What are the consequences?
A: Prometheus stores a unique time series per unique labelset. High-cardinality (e.g., user_id) creates many series, increasing memory, storage, and query cost; it can cause OOM and slow queries. Use aggregation, remove high-cardinality labels before ingestion, or use indexing/rollups in remote store.

Q: When would you use Thanos vs Cortex?
A: Thanos is simpler to integrate with existing Prometheus instances via sidecar and provides global query, compaction, and object-store-backed storage. Cortex is designed for multi-tenant, scalable ingestion with more complexity but supports high ingestion and tenant isolation.

Q: How do you design alerts to avoid noise and pager fatigue?
A: Make alerts actionable (add runbooks), tune severity and `for` durations, use recording rules, group alerts logically, use suppression/inhibition for correlated alerts, and test in staging.

Q: Explain PromQL difference between `increase()` and `rate()`.
A: `rate()` returns per-second average rate over a range vector and is suitable for counters; `increase()` returns the total increase over the range window. `increase()` is useful for totals (e.g., total requests over 5m) and `rate()` for throughput per-second.

## Quick revision cheat-sheet

- Key endpoints: Prometheus UI `/`, `/targets`, `/alerts`, `/rules`, `/api/v1/query` and `/api/v1/query_range`.
- Important commands:

```
# Check targets and status
curl http://localhost:9090/api/v1/targets

# Run an instant query
curl -g 'http://localhost:9090/api/v1/query?query=rate(http_requests_total[5m])'
```

- One-line checklist before interview:
  - Explain architecture (server, TSDB, exporters, Alertmanager)
  - Describe PromQL differences: instant vs range vectors, rate() vs increase(), histogram_quantile()
  - Discuss scaling options: remote_write, Thanos/Cortex/Mimir
  - Explain alert design: actionable alerts, runbooks, groupings and inhibition

## Further reading & tools
- Official docs: https://prometheus.io
- Thanos: https://thanos.io
- Cortex: https://cortexmetrics.io
- VictoriaMetrics: https://victoriametrics.com
- PromQL tutorial: https://promlabs.com/promql
```

