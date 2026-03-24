[![Build and Push](https://github.com/pkinif/jenkins_setup/actions/workflows/deploy_docker.yaml/badge.svg)](https://github.com/pkinif/jenkins_setup/actions/workflows/deploy_docker.yaml)
[![Prod EC2 deploy](https://github.com/pkinif/jenkins_setup/actions/workflows/deploy_prod_ec2.yaml/badge.svg?branch=prod)](https://github.com/pkinif/jenkins_setup/actions/workflows/deploy_prod_ec2.yaml)

# Jenkins in Docker (with R tooling)

This repo is how I ship a **Jenkins** image tailored for **R** workflows (renv-friendly, common system libs, Pandoc, Git). Everything runs in **Docker Compose**; data lives in a bind-mounted `jenkins_home` so jobs and config survive image updates.

I push the image to **Docker Hub** as `pierrickkinif/jenkins:latest` from GitHub Actions. You can use it as-is or fork the repo and adjust the `dockerfile` / workflows.

---

## What you need

- **Docker** and **Docker Compose** (v2 plugin, `docker compose` command).
- A clone of this repository if you want the `docker-compose.yml` and docs locally (optional if you only pull the image).

---

## Run it locally

You do **not** have to build the image. Pull and start:

```bash
docker compose up -d
```

`docker-compose.yml` points at `pierrickkinif/jenkins:latest` and sets `pull_policy: always`, so a plain `docker compose up -d` usually pulls the newest `latest` before starting.

**Volume:** `./jenkins_home` on the host is mounted to `/var/jenkins_home` in the container. That is where Jenkins stores everything that matters.

**First login:** open [http://localhost:8080](http://localhost:8080). Unlock with the initial password:

```bash
cat ./jenkins_home/secrets/initialAdminPassword
```

Or from inside the container:

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Complete the setup wizard (suggested plugins, admin user, etc.). After that, you normally do not need the initial password again as long as you keep the same `jenkins_home` volume.

---

## Permissions on Linux / EC2

If Jenkins complains it cannot write `JENKINS_HOME`, the bind-mounted directory is probably owned by the wrong uid. The image runs as user `jenkins` (typically uid **1000**). On the host:

```bash
sudo chown -R 1000:1000 ./jenkins_home
```

Adjust if your image uses a different uid (`docker run --rm pierrickkinif/jenkins:latest id jenkins`).

---

## Day-to-day Docker commands

| Task | Command |
|------|---------|
| Start | `docker compose up -d` |
| Stop | `docker compose down` |
| Refresh image and recreate Jenkins | `docker compose pull jenkins && docker compose up -d jenkins` |

---

## Optional: Watchtower (local auto-update)

I added an **optional** Compose profile `auto-cd` that runs [nickfedor/watchtower](https://github.com/nicholas-fedor/watchtower) so Docker Hub is polled and the `jenkins` container is recreated when `latest` changes. Handy for demos or laptops that stay on; I do **not** rely on this for production EC2 (I use GitHub Actions SSH deploy instead—see `docs/production.md`).

```bash
docker compose --profile auto-cd up -d
docker compose --profile auto-cd logs -f watchtower
```

Use `nickfedor/watchtower`, not the old `containrrr/watchtower` image, on recent Docker Engine (API 1.44+). If the machine sleeps, nothing updates until Docker runs again.

---

## CI/CD: prove the image came from GitHub Actions

Every CI build bakes a small manifest into the image:

```bash
docker exec jenkins cat /opt/jenkins-cicd-info.txt
```

You get UTC build time, repo commit SHA, workflow name, and the primary tag for that run.

The same build is tagged on Docker Hub as:

- `pierrickkinif/jenkins:latest` (what Compose uses)
- `pierrickkinif/jenkins:<branch>-<run_number>` (e.g. `main-42`, `prod-12`)
- `pierrickkinif/jenkins:sha-<full_commit_sha>`

Useful to line up **Actions → run → Hub tags → file in the container**.

---

## GitHub Actions (summary)

| Workflow | Trigger | What it does |
|----------|---------|----------------|
| [deploy_docker.yaml](.github/workflows/deploy_docker.yaml) | Push to `main` | Build, push image to Docker Hub (with build args + extra tags). |
| [deploy_prod_ec2.yaml](.github/workflows/deploy_prod_ec2.yaml) | Push to `prod` | Same build/push, then SSH to EC2, `git pull` on the deploy path, `docker compose pull` + recreate Jenkins. |

Secrets and EC2 setup are documented in **[docs/production.md](docs/production.md)**. EC2 bootstrap snippets live in **[docs/ec2-setup-commands.md](docs/ec2-setup-commands.md)**.

---

## Building the image yourself

```bash
docker build -t my-jenkins:local .
```

The `dockerfile` extends `jenkins/jenkins:latest`, installs R (CRAN repo aligned with the Debian series in that base image), renv, and fixes permissions on `/usr/local/lib/R/site-library` for `renv::restore()` under the `jenkins` user.

---

## Repository layout (gitignored)

`jenkins_home` is in `.gitignore` so local Jenkins data never gets committed. Same idea for `.Renviron`, `.Rproj` noise, etc.—see `.gitignore`.

---

## License / contact

Use this repo for teaching or your own pipelines. If something breaks after an upstream Jenkins or base-image change, open an issue or adjust the `dockerfile` and pin a base tag you trust.
