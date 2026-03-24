# Déploie la dernière image Jenkins localement (pull + recreate).
# À lancer depuis n'importe quel répertoire : .\scripts\deploy-local.ps1
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
docker compose pull jenkins
docker compose up -d jenkins --force-recreate --remove-orphans
Write-Host "Jenkins est à jour. Ouvrez http://localhost:8080"
