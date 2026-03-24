FROM jenkins/jenkins:latest

# Renseigné par GitHub Actions (build-args) — démo CI/CD pour les étudiants.
ARG BUILD_DATE=local
ARG VCS_REF=local
ARG CI_WORKFLOW=local
ARG IMAGE_TAG=local

LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.title="Jenkins DLH (image construite en CI/CD)"

USER root

RUN printf '%s\n' \
  "=== Trace CI/CD — cette image a ete construite par GitHub Actions ===" \
  "" \
  "Date de build (UTC): ${BUILD_DATE}" \
  "Commit du depot jenkins_setup: ${VCS_REF}" \
  "Workflow GitHub Actions: ${CI_WORKFLOW}" \
  "Tag pousse sur Docker Hub (exemple principal): ${IMAGE_TAG}" \
  "" \
  "Commande pour afficher ce fichier:" \
  "  docker exec jenkins cat /opt/jenkins-cicd-info.txt" \
  "" \
  "Autres tags sur Hub (meme build): latest, branche-numero_run, sha-hash_commit" \
  > /opt/jenkins-cicd-info.txt && chmod 644 /opt/jenkins-cicd-info.txt

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    dirmngr \
    gnupg \
    wget \
    ca-certificates \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libpq-dev \
    libx11-dev \
    pandoc \
    git

# CRAN trixie-cran40 matches the Debian release shipped with jenkins/jenkins:latest.
# Key via HTTPS (HKP keyservers often fail inside docker build).
RUN wget -qO- "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7" \
    | gpg --dearmor -o /etc/apt/trusted.gpg.d/cran_debian_key.gpg \
    && echo "deb https://cloud.r-project.org/bin/linux/debian trixie-cran40/" > /etc/apt/sources.list.d/cran.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends r-base r-base-dev

# Clean apt cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install renv
RUN Rscript -e 'install.packages("renv")' && \
    Rscript -e 'renv::consent(provided = TRUE)'

# Allow renv restores that target R_LIBS_SITE (common when Rscript skips project .Rprofile).
RUN mkdir -p /usr/local/lib/R/site-library \
    && chown -R jenkins:jenkins /usr/local/lib/R/site-library

# Switch back to Jenkins user
USER jenkins

EXPOSE 8080