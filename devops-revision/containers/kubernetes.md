# Kubernetes — In-depth Revision & Examples

This page gives a concise, practical review of Kubernetes concepts, common manifests, and real-world examples you can use for revision and labs.

## Core Concepts (short)
- Control plane: API Server, Controller Manager, Scheduler, etcd
- Node components: kubelet, kube-proxy, container runtime
- Key objects: Pod, Deployment, ReplicaSet, StatefulSet, DaemonSet, Service, Ingress, Job/CronJob
- ConfigMaps, Secrets, PersistentVolumes (PV) and PersistentVolumeClaims (PVC)
- Namespaces, RBAC (Role/ClusterRole & RoleBinding/ClusterRoleBinding), NetworkPolicies
- Packaging: Helm charts; extend with Operators & CRDs

## Example: Deployment + Service (rolling update safe defaults)
Deployment (nginx-deployment.yaml):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
	name: nginx-deployment
	labels:
		app: nginx
spec:
	replicas: 3
	selector:
		matchLabels:
			app: nginx
	strategy:
		type: RollingUpdate
		rollingUpdate:
			maxSurge: 1
			maxUnavailable: 1
	template:
		metadata:
			labels:
				app: nginx
		spec:
			containers:
				- name: nginx
					image: nginx:1.23
					ports:
						- containerPort: 80
					readinessProbe:
						httpGet:
							path: /
							port: 80
						initialDelaySeconds: 5
						periodSeconds: 10
					livenessProbe:
						httpGet:
							path: /healthz
							port: 80
						initialDelaySeconds: 15
						periodSeconds: 20
```

Service (nginx-service.yaml) — ClusterIP fronting the Deployment:

```yaml
apiVersion: v1
kind: Service
metadata:
	name: nginx-service
spec:
	selector:
		app: nginx
	ports:
		- protocol: TCP
			port: 80
			targetPort: 80
	type: ClusterIP
```

Apply:
```
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
```

Check rollout:
```
kubectl rollout status deployment/nginx-deployment
kubectl get pods -l app=nginx -o wide
```

## Persistent Storage (PV + PVC example)
PersistentVolume (hostPath example for lab use):

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
	name: pv-local-1
spec:
	capacity:
		storage: 1Gi
	accessModes:
		- ReadWriteOnce
	hostPath:
		path: /mnt/data
```

PersistentVolumeClaim:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
	name: pvc-data-1
spec:
	accessModes:
		- ReadWriteOnce
	resources:
		requests:
			storage: 1Gi
```

Mount into a Pod (snippet in the pod spec):

```yaml
			volumes:
				- name: data
					persistentVolumeClaim:
						claimName: pvc-data-1
			containers:
				- name: app
					image: busybox
					command: ["sh","-c","sleep 3600"]
					volumeMounts:
						- mountPath: /data
							name: data
```

## ConfigMap & Secret examples
ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
	name: app-config
data:
	LOG_LEVEL: "info"
	MAX_CONN: "100"
```

Use as env in container:

```yaml
				env:
					- name: LOG_LEVEL
						valueFrom:
							configMapKeyRef:
								name: app-config
								key: LOG_LEVEL
```

Secret (base64 encoded value for demo):

```yaml
apiVersion: v1
kind: Secret
metadata:
	name: db-secret
type: Opaque
data:
	username: YWRtaW4=
	password: cGFzc3dvcmQ=
```

Consume secret as env (recommended):

```yaml
				env:
					- name: DB_USER
						valueFrom:
							secretKeyRef:
								name: db-secret
								key: username
```

## Horizontal Pod Autoscaler (HPA)
Scale deployment based on CPU usage:

```bash
kubectl autoscale deployment nginx-deployment --cpu-percent=50 --min=1 --max=10
kubectl get hpa
```

HPA YAML (metrics API required for advanced metrics):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
	name: nginx-hpa
spec:
	scaleTargetRef:
		apiVersion: apps/v1
		kind: Deployment
		name: nginx-deployment
	minReplicas: 1
	maxReplicas: 10
	metrics:
		- type: Resource
			resource:
				name: cpu
				target:
					type: Utilization
					averageUtilization: 50
```

## Ingress (example using nginx ingress controller)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
	name: nginx-ingress
	annotations:
		kubernetes.io/ingress.class: nginx
spec:
	rules:
		- host: example.local
			http:
				paths:
					- path: /
						pathType: Prefix
						backend:
							service:
								name: nginx-service
								port:
									number: 80
```

## Helm quick example
Install a chart (nginx) from bitnami or official repo:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-nginx bitnami/nginx
```

## Debugging & Useful kubectl commands
- Cluster info: kubectl cluster-info
- Nodes and resources: kubectl get nodes; kubectl top nodes; kubectl top pods
- All namespaces pods: kubectl get pods -A
- Describe failing object: kubectl describe pod <pod> -n <ns>
- Logs: kubectl logs <pod> [-c container] -n <ns>
- Exec for live debugging: kubectl exec -it <pod> -n <ns> -- /bin/sh
- Port-forward for local access: kubectl port-forward svc/nginx-service 8080:80 -n <ns>
- View events (recent): kubectl get events -A --sort-by='.lastTimestamp'

## Best Practices (revision checklist)
- Use resource requests/limits to avoid noisy neighbour problems.
- Prefer readinessProbe over livenessProbe for startup checks.
- Put limits on RBAC permissions (least privilege).
- Store secrets in Secret Manager or sealed-secrets for production.
- Use namespaces for environment separation (dev/stage/prod).
- Use CI to lint manifests (kubeval/kube-score) and run `kubectl apply --server-dry-run` as sanity check.

## References
- ../../Devops/K8S.md

- ../../Interviews-questions/Kubernetes.md
