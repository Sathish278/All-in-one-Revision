```markdown
# Docker — interview-ready revision

> Summary: Essential Docker concepts for SREs — images, containers, registries, networking, volumes, and best practices for production workloads.
>
> How to use: practice building images, running containers locally, and simulate multi-container apps with Docker Compose before moving to Kubernetes.

1) Core concepts
- Images & layers, containers, registries (Docker Hub, ECR), image tags, and manifests.

2) Quick examples
- Build: `docker build -t myapp:latest .`
- Run: `docker run -d --name myapp -p 8080:80 myapp:latest`
- Push: `docker push myorg/myapp:latest`

3) Best practices
- Keep images small (multi-stage builds), avoid storing secrets in images, use non-root users, and pin base image versions.

4) Networking & storage
- Bridge, host, and overlay networks; volumes for persistence; use named volumes for data retention.

5) CI/CD & registries
- Scan images for vulnerabilities, sign images (cosign), and use immutable tags with digest-based deployment.

6) Interview Q&A
- Q: How do you reduce image size? A: Use minimal base images (distroless, alpine), multi-stage builds, and remove build artifacts.

--

I can add a small Dockerfile + multi-stage example and a CI snippet to build/push images to a registry.
```
