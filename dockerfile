FROM jenkins/jenkins:latest

USER root

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    dirmngr \
    gnupg \
    software-properties-common \
    wget \
    ca-certificates \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libpq-dev \
    libx11-dev \
    pandoc \
    git

# Adds a source where R 4.4.0 is available
# we need R 4.4 for some packages
RUN echo "deb https://cloud.r-project.org/bin/linux/debian bookworm-cran40/" > /etc/apt/sources.list.d/cran.list \
    && apt-get update --allow-insecure-repositories || true \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
       r-base r-base-dev

# Clean apt cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install renv
RUN Rscript -e 'install.packages("renv")' && \
    Rscript -e 'renv::consent(provided = TRUE)'

# Switch back to Jenkins user
USER jenkins

EXPOSE 8080
