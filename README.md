# Docker images for Task 3

This directory contains the container images used by the ECS Fargate deployment in `task3`.

| Directory | Image | Purpose |
| --- | --- | --- |
| `ollama/` | `ollama` | Ollama with the `llama3.2:1b` model downloaded during the build. |
| `open-webui/` | `open-webui` | Web interface for Ollama. |
| `prometheus/` | `prometheus` | Prometheus with its configuration. |
| `grafana/` | `grafana` | Grafana with provisioned data sources, dashboards, and alerts. |
| `node-exporter/` | — | Old EC2 exporter; it is not built or used by the Fargate deployment. |

## Requirements

- Docker with Buildx, running locally.
- AWS CLI authenticated to the AWS account that owns the ECR repository.
- An existing private ECR repository in `us-east-1`.

The build script publishes `linux/amd64` images. Building Ollama also downloads the model, so its build can take longer than the other images.

## Build and push

From this directory, run:

```sh
./build-and-push.sh ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/REPOSITORY_NAME v2
```

Replace `ACCOUNT_ID` and `REPOSITORY_NAME` with your ECR values. The second argument is the version; if omitted, the script uses `v2`.

The script logs in to ECR, then builds and pushes these four tags into the same repository:

```text
ollama-v2
open-webui-v2
prometheus-v2
grafana-v2
```

It does not build `node-exporter`.

## Run locally

After publishing, use the same repository URI and version to test the containers on your computer:

```sh
repo=ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/REPOSITORY_NAME
version=v2
docker network create task3
docker run -d --name ollama --network task3 -p 11434:11434 "$repo:ollama-$version"
docker run -d --name prometheus --network task3 -p 9090:9090 "$repo:prometheus-$version"
docker run -d --name grafana --network task3 -p 3000:3000 -e PROMETHEUS_URL=http://prometheus:9090 -e ALERT_EMAIL=you@example.com "$repo:grafana-$version"
docker run -d --name open-webui --network task3 -p 8080:8080 -e OLLAMA_BASE_URL=http://ollama:11434 "$repo:open-webui-$version"
```

If your local Docker installation cannot access ECR, repeat the login command in `build-and-push.sh` first. On an ARM Mac, running `linux/amd64` images may be slow because Docker emulates the architecture.

Check the services:

```sh
curl http://localhost:11434/api/tags
curl http://localhost:9090/-/healthy
curl http://localhost:3000/api/health
curl -I http://localhost:8080/
```

Open WebUI at `http://localhost:8080/` and Grafana at `http://localhost:3000/`.

This local WebUI example uses its default database. In ECS, the task definition supplies `DATABASE_URL` and `WEBUI_SECRET_KEY` through Secrets Manager. Prometheus currently scrapes only itself; the Ollama ECS CPU, memory, and ephemeral storage panels in Grafana read CloudWatch Container Insights. The Grafana CloudWatch data source needs the ECS task role at runtime. Email alerts also need Grafana SMTP settings at runtime; `ALERT_EMAIL` only sets the recipient.

Stop the local containers:

```sh
docker rm -f open-webui grafana prometheus ollama
docker network rm task3
```

## Deploy on ECS Fargate

The Docker script does not create ECS resources. Terraform in `task3` creates the cluster and services. After pushing a new version, set the four image tags in `task3/main.tf` to that version before running Terraform. For example, images pushed as `*-v2` require `ollama-v2`, `open-webui-v2`, `prometheus-v2`, and `grafana-v2` in the ECS module inputs.
