# Déploiement production (EC2 + GitHub Actions)

## Principes

- **Registry** : Docker Hub (`pierrickkinif/jenkins:latest`), inchangé.
- **Branche `prod`** : seul déclencheur du **build**, du **push** image et du **déploiement** SSH vers l’EC2.
- **Un seul mécanisme de CD sur le serveur** : le workflow GitHub Actions (pull + recreate). **Ne pas** activer le profil Compose `auto-cd` / Watchtower sur l’EC2.

Le workflow `main` (`.github/workflows/deploy_docker.yaml`) continue de builder et pousser l’image pour le parcours local / cours ; la mise à jour **serveur** suit les pushes sur **`prod`** (merge ou commit direct sur `prod`).

## Prérequis sur l’EC2

1. Ubuntu (ou équivalent) avec **Docker Engine** et le plugin **Docker Compose v2**.
2. Utilisateur SSH avec accès à Docker (`docker` sans `sudo`, ou adapter les commandes).
3. Clone de ce dépôt (branche `prod` ou `main` selon ta politique) dans un répertoire fixe, par ex. `/home/ubuntu/jenkins_setup`, contenant au minimum `docker-compose.yml` et le volume monté `./jenkins_home`.
4. Premier démarrage manuel une fois : `docker compose up -d` (sans `--profile auto-cd`).
5. Groupe de sécurité : voir section **Réseau** ci-dessous ; port **8080** pour Jenkins.

## Réseau : SSH depuis GitHub Actions

Le job **deploy-ec2** ouvre une session SSH **depuis les runners GitHub** (IP **non fixes**). Ton security group doit donc autoriser le SSH (port **22**) **vers** ces IP, sinon le déploiement échoue alors que ton accès manuel depuis ton PC fonctionne.

Options courantes :

1. **TP / test** : règle inbound **SSH** depuis `0.0.0.0/0` (à durcir ensuite) — le plus simple.
2. **Plus propre** : récupérer les plages `actions` depuis l’API GitHub ([`GET https://api.github.com/meta`](https://api.github.com/meta)) et les ajouter en inbound (liste longue, à maintenir).
3. **Alternative** : runner **self-hosted** sur l’EC2 ou déploiement via **SSM** / autre, sans ouvrir SSH au monde.

Pense aussi à associer sur l’EC2 la **clé publique** correspondant au secret `EC2_SSH_KEY` (fichier `~/.ssh/authorized_keys` de `EC2_USER`).

## Secrets GitHub (Settings → Secrets and variables → Actions)

| Secret | Rôle |
|--------|------|
| `DOCKERHUB_USERNAME` | Déjà utilisé par le workflow `main` |
| `DOCKERHUB_TOKEN` | Idem |
| `EC2_HOST` | DNS public ou IP de l’instance |
| `EC2_USER` | Utilisateur SSH (ex. `ubuntu`) |
| `EC2_SSH_KEY` | Clé **privée** PEM (contenu complet, y compris `BEGIN` / `END`) |
| `EC2_DEPLOY_PATH` | Chemin absolu du clone sur l’EC2 (ex. `/home/ubuntu/jenkins_setup`) |

Les **vraies valeurs** ne doivent **pas** être commitées ; elles vivent uniquement dans les secrets du dépôt (ou de l’organisation).

## Workflow

1. Intégrer les changements sur `main` comme d’habitude.
2. Quand tu veux **livrer sur l’EC2** : merge (ou fast-forward) vers **`prod`** et pousse `origin prod`.
3. Le workflow **Prod — build, push Docker Hub, deploy EC2** exécute : build image → push Hub → SSH sur l’EC2 → `git` met à jour le clone sur **`prod`** (si c’est un dépôt Git) → `docker compose pull jenkins` → `up -d --force-recreate`.

Pour **tester** sans merger : onglet **Actions** → workflow **Prod — …** → **Run workflow** sur la branche `prod` (après avoir poussé un commit sur `prod`, ou en ré-exécutant un run récent).

## SSH sur un port autre que 22

Éditer `.github/workflows/deploy_prod_ec2.yaml` et ajouter sous `with:` de `appleboy/ssh-action` :

```yaml
port: 2222
```

(ou une valeur lue via un secret dédié, en évitant les expressions fragiles sur secrets optionnels.)
