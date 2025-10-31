## Kubernetes — interview-ready revision

Goal: concise, in-depth coverage of core concepts SRE/Platform candidates must know — control plane, scheduling, networking, storage, security, troubleshooting, and common interview scenarios. Each section includes small, copy-pasteable examples.

1) Control plane & components
- kube-apiserver: central API, authentication, admission controllers
- kube-scheduler: assigns pods to nodes based on resources and constraints
- kube-controller-manager: node controller, replication controller, endpoint controller
- kubelet: node agent; kube-proxy: service networking (iptables/ipvs)

Example: check component status

kubectl get componentstatuses

2) Pod lifecycle & design
- Pod vs container, init containers, lifecycle hooks, probes (liveness/readiness/startup)

Example: readinessProbe

apiVersion: v1
kind: Pod
metadata:
  name: web
spec:
  containers:
  - name: app
    image: nginx
    readinessProbe:
      httpGet:
        path: /health
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5

3) Scheduling and affinity
- nodeSelector, nodeAffinity (preferred/required), podAffinity/anti-affinity, taints & tolerations

Example: tolerate taint

spec:
  tolerations:
  - key: "special"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"

4) Services, ClusterIP, NodePort, LoadBalancer, Ingress
- Service types mapping to networking; Ingress controllers (nginx, contour, traefik)

Example: Service + Ingress (NGINX)

kind: Service
apiVersion: v1
metadata:
  name: web-svc
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
  - host: example.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-svc
            port:
              number: 80

5) Storage
- PersistentVolumes (PV), PersistentVolumeClaims (PVC), StorageClasses; dynamic provisioning; reclaim policies

Example: PVC request

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard

6) RBAC & Security
- Roles, ClusterRoles, RoleBindings, ClusterRoleBindings; service accounts; PodSecurityPolicies (deprecated) / Pod Security Admission

Example: give a service account permissions

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]

kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io

7) Observability & troubleshooting
- kubectl top, logs, describe, events; metrics-server vs Prometheus; common patterns for debugging network issues (tcpdump, nsenter)

Example: common debug sequence

kubectl get pods -o wide
kubectl describe pod <pod>
kubectl logs <pod> -c <container>

8) High availability & scaling patterns
- Control plane HA (external etcd, multiple apiservers); Horizontal Pod Autoscaler (HPA), Cluster Autoscaler; best practices for stateful workloads

Example: HPA

apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60

9) Networking internals
- kube-proxy modes (iptables, ipvs), CNI plugins (Calico, Flannel, Cilium), Services vs Endpoints, DNS (CoreDNS), NetworkPolicies

10) Common interview questions and answers
- Q: How does Kubernetes schedule a pod? A: scheduler evaluates Node affinity, taints/tolerations, resource requests, topologySpreadConstraints, and scoring policies; it then binds the Pod to a Node via the API server.
- Q: How do you troubleshoot a CrashLoopBackOff? A: `kubectl describe pod` for events, inspect container logs (previous), check probe config and resource limits, run `kubectl exec` to inspect filesystem if possible.

--

If this layout looks good I'll:
- add the other topic READMEs in the same style (prometheus, grafana, terraform, aws, docker, helm, argocd, github-actions, opentelemetry, ansible, git, linux),
- run a quick markdown link check,
- then optionally move scripts into `devops-revision/scripts/`.
