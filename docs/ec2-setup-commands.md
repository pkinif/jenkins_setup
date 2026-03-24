# EC2 — commandes de référence (Ubuntu)

Remplace l’IP et le chemin de clé par les tiens.

```bash
ssh -i "/chemin/vers/ta-cle.pem" ubuntu@IP_PUBLIQUE_EC2
```

## Docker + Git (première installation)

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl git
# … puis suis la doc Docker officielle pour Ubuntu (repo docker.com)
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
exit   # puis reconnecte-toi en SSH
docker --version
docker compose version
docker run --rm hello-world
```
