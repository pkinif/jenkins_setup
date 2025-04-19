# Start from the official Jenkins LTS image
FROM jenkins/jenkins:latest

USER root

# Install R
RUN apt-get update && apt-get install -y --no-install-recommends \
    r-base \
    r-base-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && apt-get clean

# Install renv
RUN Rscript -e 'install.packages("renv")' && \
    Rscript -e 'renv::consent(provided = TRUE)'
    
# Switch back to Jenkins user
USER jenkins

# Expose ports
EXPOSE 8080
