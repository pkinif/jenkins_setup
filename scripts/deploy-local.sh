#!/usr/bin/env bash
# Déploie la dernière image Jenkins localement (pull + recreate).
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose pull jenkins
docker compose up -d jenkins --force-recreate --remove-orphans
echo "Jenkins est à jour. Ouvrez http://localhost:8080"
