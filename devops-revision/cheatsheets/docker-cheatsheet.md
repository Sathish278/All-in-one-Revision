# Docker Cheatsheet

Quick commands:

- List containers: docker ps -a
- Run container: docker run -it --rm image /bin/bash
- Build: docker build -t name:tag .
- Compose up: docker-compose up -d
- Remove all stopped containers: docker container prune
- Remove dangling images: docker image prune
