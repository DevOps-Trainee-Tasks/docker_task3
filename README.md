# Task 3 Docker images

This directory builds the seven images used by the Terraform project in `../task3`. They are published to separate ECR repositories under the `task3/` prefix.

| Directory       | Purpose                                                                       |
| --------------- | ----------------------------------------------------------------------------- |
| `ollama/`       | Ollama with the `llama3.2:1b` model downloaded during the build.              |
| `open-webui/`   | Web interface connected to Ollama and PostgreSQL by the ECS task definition.  |
| `prometheus/`   | Prometheus configuration for its own metrics and the ECS exporters.           |
| `grafana/`      | Provisioned data sources, dashboards, and alerts.                             |
| `db-init/`      | Initializes the WebUI database role and PostgreSQL `vector` extension.        |
| `ecs-exporter/` | Exposes ECS task and container metrics on port 9779.                          |
| `log-router/`   | Sends application logs to CloudWatch and EFS, organized by availability zone. |

Prometheus discovers the exporters through the private `task3.local` Cloud Map domain. Grafana's Ollama CPU, memory, and ephemeral storage dashboards use Prometheus. Its ALB dashboards use CloudWatch.

## Requirements

- Docker with Buildx.
- AWS CLI authenticated to the account containing the ECR repositories.
- These seven ECR repositories in `us-east-1`: `task3/ollama`, `task3/open-webui`, `task3/prometheus`, `task3/grafana`, `task3/db-init`, `task3/ecs-exporter`, and `task3/log-router`.

The script builds `linux/amd64` images for ECS Fargate. The Ollama build downloads the model and can take longer.

## Build and push all images

From this directory:

```bash
chmod +x build-and-push.sh
./build-and-push.sh ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/task3 v6
```

Replace `ACCOUNT_ID` with your AWS account ID and `v6` with a **new tag**. The script logs in to ECR, then builds and pushes:

```text
task3/ollama:v6
task3/open-webui:v6
task3/prometheus:v6
task3/grafana:v6
task3/db-init:v6
task3/ecs-exporter:v6
task3/log-router:v6
```

The script expects the seven ECR repositories to exist. It stops if any build or push fails.

## Deploy the new images

After a successful push, set the new tags on all six image references in `../task3/main.tf` and the `log-router` image in `../task3/locals.tf`. The current Terraform configuration uses different tags for different images, so the images you push must match the references before deployment.

Then run Terraform from `../task3`, or push the Terraform changes to a branch and merge the pull request to trigger the configured GitHub Actions workflows.

The ECS task definitions supply database credentials, Grafana SMTP settings, service URLs, log volumes, and service discovery. These values are not baked into the Docker images.
