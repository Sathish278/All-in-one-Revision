
# Argo CD — Complete GitOps Reference (Interview-ready)

Purpose
- This file is a dense, interview-focused reference for Argo CD and GitOps patterns. It covers core concepts, App-of-Apps, ApplicationSet (multi-cluster), RBAC, sync strategies, hooks, secret management, bootstrapping, security, troubleshooting, and suggested answers to common senior SRE/DevOps interview questions.

Quick contract
- Inputs: Git repos (manifests, Helm charts, Kustomize overlays) as the single source of truth.
- Outputs: Kubernetes resources in one or multiple clusters matched to Git state; visibility & drift detection via Argo CD UI/API.
- Success criteria: reproducible deployments, secure automated syncs, auditable changes, multi-cluster reliability, clear rollback paths.

Core concepts
- Application: maps a Git repo (repoURL/path/revision) to a destination cluster/namespace and tracks/live-syncs resources.
- Project: a logical namespace in Argo CD that groups Applications and enforces policies (source repos, destination clusters, roles).
- Repo server: component that reads Git repos and serves manifests to the API server.
- Controller: reconciles Applications, triggers syncs, and monitors health.
- Dex / SSO: optional identity provider for authentication.

Why GitOps with Argo CD?
- Declarative — Git holds the desired state; Argo CD reconciles the cluster to match.
- Auditable — Git history is the audit trail for changes.
- Rollbacks — revert the Git commit to roll back to a previous state.

Application manifest — minimal example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/example/guestbook'
    path: manifests
    targetRevision: HEAD
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: guestbook
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

App-of-Apps pattern
- Pattern: a root Application (in a bootstrap repo) that points to multiple child Application manifests in Git. Useful for multi-environment or multi-team orchestration.
- Pros: simple, clear hierarchy, easy to visualize in Argo CD UI.
- Cons: can get large; consider ApplicationSet for dynamic generation.

Example (root Application pointing to child Apps):

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: argocd
spec:
  source:
    repoURL: 'https://github.com/example/bootstrap'
    path: apps
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
```

ApplicationSet — dynamic, multi-cluster generation
- ApplicationSet controller generates Applications from generators (Git, List, Cluster, Matrix). Ideal for multi-cluster or multi-environment deployments.

Example: generate an Application per cluster (Cluster generator)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: apps-per-cluster
  namespace: argocd
spec:
  generators:
  - clusters: {}
  template:
    metadata:
      name: '{{name}}-guestbook'
    spec:
      project: default
      source:
        repoURL: 'https://github.com/example/guestbook'
        path: manifests
      destination:
        server: '{{server}}'
        namespace: guestbook
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

Sync strategies & options (practical)
- Manual: human-triggered sync.
- Automated:
  - prune: delete resources removed from Git.
  - selfHeal: auto-reconcile drift.
  - syncOptions: CreateNamespace=true, SkipDryRunOnMissingResource=true, ApplyOutOfSyncOnly=true.
- Hooks: resource lifecycle hooks allow jobs to run at pre-sync, post-sync, sync-fail, etc. Use for migrations or DB schema tasks.

Example hook (pre-sync job):

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pre-migrate
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-weight: "0"
spec:
  template:
    spec:
      containers:
      - name: migrate
        image: my-migrations:latest
      restartPolicy: Never
```

Health checks & customizers
- Argo CD has built-in health checks for common resources. For custom resources, provide Lua or JSON health checks via `resource.customizations.health` in Argo CD config.

Security & RBAC
- RBAC: define roles with `Role` (argocd-rbac-cm) and policies to limit who can sync/create/delete Applications.
- Example policy: allow team-X to sync apps in project X only:

```yaml
# argocd-rbac-cm
policy.csv: |
  p, role:team-x, applications, sync, *, allow
  p, role:team-x, applications, get, *, allow
```
- Projects: restrict repositories and cluster destinations per project to reduce blast radius.
- SSO: integrate with OIDC providers (Dex, Keycloak, Azure AD). Use groups to map to Argo CD roles.

Secret management
- Do NOT store plaintext secrets in Git. Common patterns:
  - Sealed Secrets (Bitnami) — encrypt secrets into the repo and have controller decrypt into cluster.
  - SOPS + Git-crypt — encrypted secrets in Git; CI or controllers decrypt during apply.
  - External secrets operator / secret store CSI driver — reference secrets from vault-like systems.

Bootstrapping & GitOps operator patterns
- Bootstrap repo: repo that contains Application/App-of-Apps for bootstrapping clusters.
- Argo CD Autopilot / CLI tools: tools to bootstrap Argo CD and repository structure (argocd-autopilot, Argo CD Operator patterns).

Multi-cluster strategies
- Single Argo CD controlling multiple clusters:
  - Argo CD can be given kubeconfigs to target external clusters; good for central control and visibility.
  - Use ApplicationSet + cluster generator to produce Applications per cluster.
- Argo CD installed per cluster with a central control plane:
  - Decentralized approach: each cluster has its own Argo CD instance, with a central GitOps repo and optional federation.
  - Combine with GitHub Actions/CI to push configuration and manage lifecycle.
- Trade-offs: central Argo CD simplifies visibility but is a single control plane (availability concerns). Per-cluster installs improve isolation and reduce blast radius but increase operational overhead.

Integrations & advanced features
- Argo Rollouts: progressive delivery (blue/green, canary) with analysis using metrics (Prometheus).
- Application resource customization: Helm/Kustomize/Jsonnet/Plain YAML — Argo CD supports all via correct `source` definitions.
- Automated sync waves and sync hooks to orchestrate complex upgrades safely.
- App metrics and health checks can be integrated with Prometheus alerts to drive automation.

Troubleshooting & common issues
- OutOfSync resources: check `argocd` controller logs and repo server logs; ensure repo access and correct paths.
- Sync fails due to permissions: ensure ServiceAccount in target cluster has necessary RBAC to create resources (especially CRDs).
- Large repo performance: use repo caching, reduce large monorepos per Application, or use repo server config `repo.server.timeout`.
- Secret diffs: encrypted secrets appear as diffs if not handled with proper decryption process in cluster (use sealed/sealed-secrets or sops).

Interview Q&A (practice answers)

Q: What are the pros and cons of App-of-Apps vs ApplicationSet?
A: App-of-Apps is simple and explicit: root app references child app manifests. It's easy to reason over but static and requires new child manifests per child. ApplicationSet is dynamic and generates Applications from data sources (clusters/git), ideal for multi-cluster scale. App-of-Apps can be sufficient for small setups; ApplicationSet is better when clusters/environments scale or change frequently.

Q: How do you manage secrets in GitOps with Argo CD?
A: Avoid plaintext secrets in Git. Use SealedSecrets, SOPS-encrypted files, or reference external secret stores (Vault, AWS Secrets Manager) via an external-secrets operator. Ensure Argo CD has RBAC and admission controls to prevent unauthorized secret access.

Q: How would you design Argo CD for 50 clusters with shared apps?
A: Use ApplicationSet with `clusters` generator to produce one Application per cluster; central Argo CD or sharded Argo CD instances per region if scale/latency requires. Use object storage and monitoring for the repo server; use automated tests and PR-based gating. Enforce Projects to restrict teams and destinations.

Q: How to implement safe automated syncs?
A: Use automated sync with `prune=true` and `selfHeal=true` but gate critical changes via `syncPolicy.automated` disabled and use manual promotion, or use `syncWindows` and stages, apply canary patterns with Argo Rollouts, and use pre-sync hooks for migrations.

Quick revision cheat-sheet
- Key manifests: `Application`, `ApplicationSet`, `AppProject` (Project), `argocd-cm` and `argocd-rbac-cm` for config.
- Useful CLI: `argocd app list`, `argocd app sync <app>`, `argocd app diff <app>`, `argocd app rollback <app> --to-revision <rev>`.
- Common annotations:
  - `argocd.argoproj.io/hook` (PreSync/PostSync)
  - `argocd.argoproj.io/sync-wave` (ordering)

References & further reading
- Official docs: https://argo-cd.readthedocs.io/
- ApplicationSet: https://github.com/argoproj-labs/applicationset
- Argo Rollouts: https://argoproj.github.io/argo-rollouts/

