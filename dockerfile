FROM jenkins/jenkins:latest

USER root

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

# Switch back to Jenkins user
USER jenkins

EXPOSE 8080