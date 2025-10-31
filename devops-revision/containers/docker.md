# Docker - Consolidated Revision

This file consolidates Docker material and provides quick commands and examples for review.

## Key Concepts
- Images, Containers, Volumes, Networks
- Dockerfile instructions: FROM, WORKDIR, COPY, RUN, CMD, ENTRYPOINT, ENV, EXPOSE, VOLUME, HEALTHCHECK
- Docker Compose for multi-container apps
- Docker Hub for image distribution

## Typical Dockerfile (Python)
```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

## Quick Commands
- Run container: docker run -d -p 8080:80 --name my-nginx nginx
- Build image: docker build -t my-app:latest .
- List containers: docker ps -a
- Remove container: docker rm <container>
- Remove image: docker rmi <image>
- Exec into container: docker exec -it <container> /bin/bash
- Volume: docker volume create my-volume
- Network: docker network create mynetwork

## Docker Compose
- Start services: docker-compose up -d
- Stop and remove: docker-compose down
- Scale: docker-compose up --scale web=3

## Best Practices
- Keep images small (use slim/alpine images)
- Multi-stage builds for compiled languages
- Avoid running as root in containers
- Use .dockerignore to exclude files from build context

## References
- ../../Devops/Docker.md
- ../../Interviews-questions/Docker.md
