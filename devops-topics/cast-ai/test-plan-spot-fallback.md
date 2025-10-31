# CAST AI — Short test plan: validate spot-fallback behavior (staging)

Goal: validate that CAST AI agent safely places workloads on spot instances and falls back to on-demand when spot capacity or interruptions occur.

Assumptions:
- You have a staging Kubernetes cluster with identical nodepools for spot and on-demand (or mixed instance types) and the CAST AI agent installed.
- Access to CAST AI console or agent logs and Prometheus metrics (see examples).

Test steps (quick):

1) Prepare test workloads
   - Create a non-critical deployment (e.g., nginx) with a PodDisruptionBudget that allows some disruptions.
   - Label the deployment with an annotation or label that makes it eligible for spot placement (per your CAST AI policies).

2) Baseline observation
   - Record current number of spot nodes and on-demand nodes.
   - Record metrics: `castai_spot_eviction_count_total`, `castai_agent_provision_events_total` and provisioning latency.

3) Simulate spot capacity pressure
   Option A (preferred): Use cloud provider tooling or capacity knobs to reduce spot availability in the region (if supported).
   Option B: Create a synthetic high-demand workload triggering cluster autoscaling to prefer spot.

4) Observe agent behavior
   - Verify new pods are scheduled onto spot nodes when policy allows.
   - Watch for provisioning events in Prometheus (`castai_agent_provision_events_total`), and check agent logs for provisioning steps.

5) Simulate spot eviction
   - Force-terminate a spot instance (cloud console or provider API) that hosts test pods.
   - Verify CAST AI detects eviction, provisions a replacement (spot or on-demand per policy), and reschedules pods.

6) Validate fallback correctness
   - Confirm pods resume running and application availability is maintained (smoke test HTTP endpoint).
   - If spot capacity is scarce, confirm fallback to on-demand nodes occurs and pods are scheduled there.

7) Check metrics & alerts
   - Confirm `castai_node_lifecycle_seconds` and `castai_node_provision_errors_total` are within acceptable thresholds.
   - Ensure alert rules (if any) trigger for sustained high eviction rates or provisioning errors.

8) Post-test cleanup
   - Revert any artificially created high-demand resources.
   - Restore nodepool sizes and verify cluster health.

Success criteria
- Application remains available (HTTP 200) during evictions.
- Agent provisions replacements within an acceptable SLO (e.g., X minutes — define per your SLA).
- No unexpected provisioning error spike; any errors are logged and actionable.

Notes & cautions
- Run tests in a staging environment, never in production.
- Inform teammates and schedule a maintenance window for disruptive tests.
- Provider APIs that simulate evictions may vary; use official tooling where possible.
