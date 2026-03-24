# Production: EC2 + GitHub Actions

This is how I deploy the same Jenkins image to an **EC2** instance: one path through CI/CD (no Watchtower on the server).

## How it works

- **Registry:** Docker Hub — `pierrickkinif/jenkins:latest` (plus per-run tags, see README).
- **Branch `prod`:** Only `prod` triggers the workflow that **builds**, **pushes**, and **SSH-deploys** to EC2.
- **On the instance:** I run plain `docker compose up -d` (no `--profile auto-cd`). Updates happen when the workflow runs, not via Watchtower.

Pushes to **`main`** still build and push the image (local / course flow). When I want the server to match, I merge or fast-forward into **`prod`** and push.

## EC2 prerequisites

1. Ubuntu (or similar) with **Docker Engine** and **Docker Compose v2**.
2. SSH user that can run `docker` without `sudo` (user in `docker` group, or adapt commands).
3. A **git clone** of this repo at a fixed path (e.g. `/home/ubuntu/jenkins_setup`) containing `docker-compose.yml` and the `./jenkins_home` volume directory.
4. One manual first start: `docker compose up -d` (no Watchtower profile).
5. Security group: **22** for SSH, **8080** (or whatever you map) for Jenkins UI.

## Security group: SSH from GitHub Actions

The deploy job SSHs from **GitHub-hosted runners**; their egress IPs are **not** static. If the group only allows SSH from your home IP, the workflow fails while your own `ssh` still works.

Practical options:

1. **Lab / quick test:** allow SSH from `0.0.0.0/0`, then tighten later.
2. **Tighter:** ingest the `actions` CIDR list from [GitHub’s meta API](https://api.github.com/meta) into the security group (large list, needs maintenance).
3. **Different model:** self-hosted runner on EC2, SSM, etc.—no public SSH from GitHub.

The public key for the instance must match the private key stored in **`EC2_SSH_KEY`** (`authorized_keys` for `EC2_USER`).

## GitHub Actions secrets

Repository **Settings → Secrets and variables → Actions**:

| Secret | Purpose |
|--------|---------|
| `DOCKERHUB_USERNAME` | Docker Hub login |
| `DOCKERHUB_TOKEN` | Docker Hub token |
| `EC2_HOST` | Public DNS or IP |
| `EC2_USER` | e.g. `ubuntu` |
| `EC2_SSH_KEY` | Full private PEM (including `BEGIN` / `END` lines) |
| `EC2_DEPLOY_PATH` | Absolute path to the clone on the server, e.g. `/home/ubuntu/jenkins_setup` |

Never commit these values.

## Release flow

1. Work on `main` as usual.
2. When I want production updated: merge into **`prod`** and `git push origin prod`.
3. The workflow builds, pushes tags to Hub, SSHs in, runs `git fetch/checkout/merge` on `prod`, then `docker compose pull jenkins` and `docker compose up -d jenkins --force-recreate`.

To re-run without a new commit: **Actions → workflow → Re-run jobs**.

## Non-standard SSH port

In `.github/workflows/deploy_prod_ec2.yaml`, under `appleboy/ssh-action` `with:`, add:

```yaml
port: 2222
```

(or wire a dedicated secret if you prefer).
