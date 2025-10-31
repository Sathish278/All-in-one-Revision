# Prometheus — interview-ready revision

This file is a compact, in-depth reference for Prometheus and monitoring at scale. It covers architecture, TSDB internals, scraping, relabelling, PromQL examples, recording rules, alerting with Alertmanager, scaling (Thanos/Cortex/Mimir), best practices, and troubleshooting. Examples are copy-paste ready for quick study.

## 1) Architecture overview
- Prometheus server: pulls metrics (scrape model) and stores them in a local TSDB (WAL + blocks). Good for single-cluster monitoring and short-term retention.
- Pushgateway: for short-lived jobs that can't be scraped.
- Alertmanager: receives alerts, deduplicates, routes, silences and notifies.
- Remote storage (Thanos/Cortex/Mimir): long-term storage, global query, HA, and downsampling.

Key concepts: metrics (counters, gauges, histograms, summaries), labels (cardinality risks), PromQL (vector algebra), job/service discovery, scrape intervals, and retention.

## 2) Prometheus server basic config (prometheus.yml)

global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
    relabel_configs:
      - source_labels: [__address__]
        regex: (.*):10250
        replacement: $1:9100
        target_label: __address__

  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)

Notes:
- Prefer service discovery (kubernetes_sd_configs, consul, ec2) over static targets.
- Use `relabel_configs` to drop noisy labels and reduce cardinality.

## 3) Relabeling examples (reduce noise)
- Drop namespace and pod labels you don't need, or map them to concise labels.

- Drop labels with high cardinality:
  - source_labels: [__meta_kubernetes_pod_label_foo]
    regex: 
    action: drop

- Keep only selected labels:
  - source_labels: [__meta_kubernetes_namespace]
    regex: (default|kube-system)
    action: keep

## 4) PromQL — common queries
- Instant vector: rate(http_requests_total[5m])
- CPU usage per node (avg over 5m):
  avg by (instance) (rate(node_cpu_seconds_total{mode!="idle"}[5m]))

- 95th percentile latency across services:
  histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service))

- Error rate:
  sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))

## 5) Recording rules (reduce query CPU and precompute)

groups:
- name: example.rules
  rules:
  - record: job:http_requests:rate5m
    expr: sum by (job) (rate(http_requests_total[5m]))

Use recording rules for expensive queries and to provide stable time-series for alerts.

## 6) Alerting with Alertmanager
- Define alerting rules in Prometheus, route alerts in Alertmanager to receivers (Slack, Opsgenie, PagerDuty). Use grouping and inhibition.

Example rule (Prometheus):

- alert: HighErrorRate
  expr: job:http_requests:rate5m{job="frontend"} > 0.05
  for: 2m
  labels:
    severity: critical
  annotations:
    summary: "High error rate on frontend"
    description: "{{ $labels.job }} error rate is {{ $value }}"

Alertmanager example (simple):

route:
  group_by: [alertname, job]
  receiver: team-foo
receivers:
  - name: "team-foo"
    slack_configs:
      - channel: '#alerts'

## 7) Scaling and long-term storage
- Single Prometheus handles short retention and per-cluster metrics. For global view and long retention use:
  - Thanos: sidecar + object storage (S3) + query/compactor/store components for global query & downsampling.
  - Cortex / Mimir: horizontally scalable, pushed samples via Prometheus remote_write, supports multi-tenant workloads.

Tradeoffs:
- Thanos uses object storage to store TSDB blocks (good for HA & global queries). Cortex/Mimir accept remote_write and provide write-availability and ingestion scaling.

Example remote_write (Prometheus config):

remote_write:
  - url: "https://cortex.example/api/prom/push"
    bearer_token: "${CORTEX_TOKEN}"

Considerations: network cost, scrape frequency, downsampling, replication factor, and retention settings.

## 8) TSDB internals & storage tuning
- WAL: write-ahead log for latest samples; compaction runs to create blocks every 2 hours by default.
- Retention: controlled with `--storage.tsdb.retention.time` (or blocks retention settings in Thanos).
- Tune `--storage.tsdb.min-block-duration` and `max-block-duration` only if necessary; rely on Prometheus defaults unless investigating block churn.

Disk layout: each block contains index + chunk files. High cardinality increases index size and memory pressure.

## 9) Cardinality & best practices
- Avoid high-cardinality labels (user_id, request_id). Prefer low-cardinality labels like service, method, status.
- Use relabeling to drop unnecessary labels at scrape time.
- Instrumentation: counters for events, gauges for current state, histograms for latency (with careful bucket choices).

Histogram example (client-side):
client_histogram_bucket_seconds{le="0.1"}

Best practices:
- Set sensible scrape intervals (15s is common).
- Use service discovery; avoid static targets at scale.
- Use recording rules to precompute expensive aggregations.
- Monitor Prometheus itself (prometheus_engine_query_duration_seconds, prometheus_tsdb_head_series). Alert on high query times and series growth.

## 10) Security
- Expose Prometheus and Alertmanager behind authentication and TLS (nginx/auth proxy). Use RBAC in Kubernetes to limit access to metrics endpoints.
- Remote write endpoints require TLS and auth tokens.

## 11) Troubleshooting checklist
- High series count: check `prometheus_tsdb_head_series` and `prometheus_target_interval_length_seconds`.
- Missing metrics: check target status `/-/targets`, scrape logs, network connectivity, service discovery labels.
- Slow queries: inspect `prometheus_engine_query_duration_seconds`, add recording rules, or use partial responses with `max_source_resolution`.

Useful commands:

kubectl -n monitoring get po -l app=prometheus
curl -sS http://prometheus:9090/-/ready
curl -sS 'http://prometheus:9090/api/v1/query?query=up'

## 12) Interview Q&A (short answers)
- Q: When should you use remote_write vs Thanos sidecar?
  A: Use remote_write to send samples to Cortex/Mimir (ingest-based systems) for scalable ingestion. Use Thanos sidecar when you prefer local TSDB blocks to be uploaded to object storage and need global query across Prometheus instances.

- Q: How to reduce Prometheus memory usage?
  A: Reduce series cardinality, drop unnecessary labels, increase scrape_interval for noisy targets, add relabel_configs to reduce cardinality, use recording rules to precompute aggregates.

--

If this Prometheus README looks good, I'll produce the next topic (recommended: Grafana or Terraform) in the same interview-ready format. I can also run link/markdown checks afterwards.
