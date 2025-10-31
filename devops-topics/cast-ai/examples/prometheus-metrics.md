# CAST AI — Prometheus metrics (example names)

This file lists common/expected metric names and short descriptions that a CAST AI agent-like exporter might expose. These are example metric names for study and dashboarding — confirm exact names with the vendor docs or by inspecting the /metrics endpoint in your cluster.

- `castai_agent_provision_events_total` (counter)
  - Total number of provisioning events handled by the agent (create/replace/scale).
  - Example query: rate(castai_agent_provision_events_total[5m])

- `castai_node_provision_errors_total` (counter)
  - Number of failed node provisioning attempts.
  - Example query: increase(castai_node_provision_errors_total[1h])

- `castai_spot_eviction_count_total` (counter)
  - Count of spot/preemptible instance evictions observed.
  - Example query: sum(rate(castai_spot_eviction_count_total[5m])) by (cluster, region)

- `castai_node_lifecycle_seconds` (histogram)
  - Time taken for node provisioning lifecycle (scheduling → ready).
  - Example query: histogram_quantile(0.95, sum(rate(castai_node_lifecycle_seconds_bucket[5m])) by (le))

- `castai_recommendations_total` (gauge)
  - Current count of active optimization recommendations (e.g., rightsizing suggestions).
  - Example query: castai_recommendations_total{type="rightsizing"}

- `castai_cost_savings_percent` (gauge)
  - Estimated percent savings compared to a baseline (reported by agent/console).
  - Example query: avg(castai_cost_savings_percent) by (cluster)

- `castai_provisioning_rate_per_minute` (gauge)
  - Short-term rate of provisioning actions (useful for surge detection).
  - Example query: avg_over_time(castai_provisioning_rate_per_minute[5m])

Notes:
- These names are illustrative. The vendor may use different metric names or label schemas; inspect the agent's `/metrics` endpoint to get exact metric names and labels.
- When building dashboards and alerts, prefer low-cardinality labels (cluster, region, nodepool) and avoid per-pod/per-instance high-cardinality labels.

Want me to add a ready-to-import Prometheus scrape_config or a PrometheusRule (alert) file for a few of these metrics? Mention which alerts you want (e.g., provisioning errors, high eviction rate, provisioning latency).
