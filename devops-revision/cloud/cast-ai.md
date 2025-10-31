# CAST AI — Cloud/Kubernetes Optimization (Overview)

Overview
- CAST AI is a platform that optimizes Kubernetes clusters for cost, performance, and reliability using automation and AI-driven recommendations. It can autoscale, right-size nodes, and migrate workloads.

Core features
- Autoscaling (cluster and pod level) with intelligent decisions across instance types and spot/ondemand mixes.
- Cost optimization and recommendations: identifies underutilized resources and suggests rightsizing.
- Rebalancing and node replacement for reliability and cost.
- Security and governance integrations (RBAC, policies).

Basic workflow (conceptual)
1. Connect your Kubernetes cluster (via a connector) to CAST AI.
2. CAST AI collects telemetry and suggests optimizations.
3. Apply recommendations via the CAST AI console or automate them.

CLI / Example (conceptual)
- CAST AI primarily uses a web console and connectors; for automation, use their APIs or Terraform provider (if available). Example Terraform resource (pseudo):

```hcl
resource "castai_optimization" "example" {
  cluster_id = "cluster-xxxxx"
  enable_autopilot = true
}
```

When to use
- For teams needing automated cost optimization across cloud providers and wanting to reduce operational overhead for node management.

Notes & Caveats
- CAST AI modifies cluster node pools and may replace instances — test in staging before enabling automated changes in production.
- Consider governance policies and allowlisting to control what CAST AI can change.

References
- https://cast.ai
