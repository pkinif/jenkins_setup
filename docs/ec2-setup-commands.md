# EC2 quick reference (Ubuntu)

Replace the key path and host with yours.

```bash
ssh -i "/path/to/your-key.pem" ubuntu@YOUR_PUBLIC_IP
```

## First-time Docker + Git

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl git
# Then install Docker from the official Docker docs for Ubuntu (download.docker.com).
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
exit   # log out and SSH back in so the group applies
docker --version
docker compose version
docker run --rm hello-world
```
