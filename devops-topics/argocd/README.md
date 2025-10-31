```markdown
# Argo CD — interview-ready revision

> Summary: GitOps with Argo CD — app-of-apps, sync strategies, RBAC, multi-cluster patterns, and troubleshooting.
>
> How to use: model a git repo for cluster configuration, test sync/rollback flows in a staging cluster, and use App-of-Apps for multi-cluster deployments.

1) Core ideas
- Git as the source of truth, applications as CRs, sync strategies (auto/manual), health checks, and automated rollbacks.

2) Common patterns
- App-of-Apps, single-repo vs multi-repo, and using kustomize or Helm charts with Argo CD.

3) Quick commands (kubectl + argocd CLI)
- Login: `argocd login argocd.example.com`
- Create app: `argocd app create myapp --repo <repo> --path <path> --dest-server https://kubernetes.default.svc` 
- Sync: `argocd app sync myapp`

4) Security & RBAC
- Use SSO (OIDC), configure Argo CD RBAC for team isolation, and restrict repo access via SSH keys or deploy tokens.

5) Troubleshooting
- Check `argocd app diff`, `argocd app history`, and controller logs in `argocd` namespace. Use health checks and resource overrides for non-standard resources.

6) Interview Q&A
- Q: How do you handle secrets in GitOps? A: Use sealed secrets or SOPS-encrypted files; keep decryption keys out of the repo and use CI to decrypt for deployment.

--

I can add an `app-of-apps` example folder with a minimal Git repo layout and an Argo CD App manifest if you'd like.
```
