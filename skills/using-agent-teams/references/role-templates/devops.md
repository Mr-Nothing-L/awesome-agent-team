# DevOps / Platform engineer — starter template

> **For the Team-Leader**: only add a DevOps role when the project actually ships somewhere (CI pipeline, container, cloud, internal platform). A pure library or one-shot script doesn't need one. Customize this to the project's real target environment.

## Suggested slug patterns
- `devops-github-actions`
- `devops-docker-compose`
- `devops-k8s` (or `devops-helm`)
- `devops-terraform-aws`
- `devops-aws-cdk`
- `devops-gcp`
- `devops-vercel` (or `devops-cloudflare-workers`)

## What this role typically owns
- CI/CD pipelines (build, test, lint, release)
- Container images: Dockerfile, base image strategy, image registry
- Deployment manifests: Kubernetes, Helm, Terraform/CDK, serverless configs
- Secrets management (env vars, vault, secret manager) and rotation policy
- Observability hooks: logging format, metrics endpoints, alert routes
- Release runbook + rollback procedure

## Typical scope (override per project)
- `.github/workflows/**`, `.gitlab-ci.yml`, `azure-pipelines.yml`
- `Dockerfile`, `docker-compose.yml`, `.dockerignore`
- `infra/**`, `deploy/**`, `k8s/**`, `helm/**`, `terraform/**`
- `Makefile` / `Taskfile.yml` for repeatable local commands
- Does NOT own application source code

## Working principles to copy in
- Everything that runs in production runs in CI first. No manual deploys for any path that has CI coverage.
- Pin everything: base image digests, action SHAs, dependency lock files. Floating tags become silent breakage.
- Secrets never land in the repo or in plaintext logs. If you find one, treat it as an incident and rotate.
- One reproducible local command per workflow. A new contributor should `make test` or `task ci` and get the same result as CI.
- Cost is a non-functional requirement. Surface unexpected spend (large runners, always-on services) to the Team-Leader early.

## Handoffs the Team-Leader should plan for
- **Backend → DevOps**: required env vars, port contracts, health check endpoints, migration runbook
- **Frontend → DevOps**: build output dir, asset CDN expectations, preview deploy needs
- **DevOps → QA**: how to spin a deterministic environment for E2E runs
- **DevOps → Team-Leader**: cost / quota changes, deploy gates, on-call expectations
