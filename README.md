[![Build and Push Docker image](https://github.com/pkinif/jenkins_setup/actions/workflows/deploy_docker.yaml/badge.svg)](https://github.com/pkinif/jenkins_setup/actions/workflows/deploy_docker.yaml)

# Jenkins Setup for Local Development

Welcome to your **local Jenkins setup**! In this project, you will set up and maintain your own Jenkins server running inside Docker. Follow the instructions carefully.

## 🔹 Pre-requisites

| This project is designed to be run locally on your machine. You will need to have **Docker** and **Docker Compose** installed. You need to **fork** this repository to your own GitHub account and **clone** it to your local machine. \|

## 🔹 How to Set Up Jenkins Locally

You do **not** need to build the Docker image yourself. You can still review the dockerfile if curious.\
Instead, you will **pull the pre-built image** from Docker Hub and use it directly.

1.  **Fork this repository**

    Fork this repository to your own GitHub account, and then clone it to your local machine.

2.  **Pull the Jenkins Docker image from Docker Hub**

    Run:

    ``` bash
    docker pull pkinif/jenkins:latest
    ```

3.  **Launch Jenkins using Docker Compose**

    From your local clone of the repository, run:

    ``` bash
    docker compose up -d
    ```

    -   We are **mounting a local volume** (`./jenkins_home`) to **/var/jenkins_home** inside the container.
    -   This means that even if you pull a new Docker image later and restart the container, **you will not lose your Jenkins jobs, configuration, or users**.

4.  **First Startup: Unlock Jenkins**

    When you first access Jenkins at <http://localhost:8080>, it will ask for an **Administrator password**.

    You can find this password inside your local project:

    ``` bash
    ./jenkins_home/secrets/initialAdminPassword
    ```

    Example:

    ``` bash
    cat ./jenkins_home/secrets/initialAdminPassword
    ```

5.  **Install Recommended Plugins**

    After unlocking, Jenkins will prompt you to **install the recommended plugins**.

    Click **"Install Suggested Plugins"** and wait until the process is complete.

6.  **Create Your Admin User**

    After plugins installation, Jenkins will ask you to **create the first admin user**.

    -   Use a real email address! You will need it later.

7.  **Save and Finish**

    Once you complete the setup, click **"Save and Finish"**.

8.  **Ready to Use!**

    Your Jenkins server is now ready.

------------------------------------------------------------------------

## 🔹 Important Notes

-   **Linux Dependencies**

    If your R data pipelines require specific Linux system libraries, you may need to update the Docker image later.\
    (Contact your instructor if needed.)

-   **Persisted Data**

    Thanks to the mounted volume:

    -   You can pull new version of the Docker images
    -   Run `docker compose down` and then `docker compose up -d`

    ➔ **Your Jenkins configuration and jobs will persist.**

-   **Git Ignore**

    To avoid pushing your local Jenkins data into GitHub, the following is included in `.gitignore`:

    ``` r
    .Rproj.user
    .Rhistory
    .RData
    .Ruserdata
    jenkins_home
    *.Rproj
    .Renviron
    ```

-   **Admin Password**

    You only need to unlock Jenkins once. If you recreate your container later using the same volume, **you won't need the initialAdminPassword again**.

------------------------------------------------------------------------

## 🔹 Useful Docker Commands

-   **Start Container**

    ``` bash
    docker compose up -d
    ```

-   **Stop Container**

    ``` bash
    docker compose down
    ```

-   **Pull the latest image (if updated)**

    ``` bash
    docker pull pkinif/jenkins:latest
    docker compose down
    docker compose up -d
    ```

------------------------------------------------------------------------

## 🔹 GitHub Actions

This repository uses a GitHub Actions workflow that **automatically builds and pushes** the Docker image to Docker Hub every time a new push is made to the main branch.

-   You can find the workflow [here](https://github.com/pkinif/jenkins_setup/actions/workflows/deploy_docker.yaml).
-   The latest Docker image is always available at: `pkinif/jenkins:latest`.

Happy CI/CD building! 🚀

------------------------------------------------------------------------

*If you have any issue starting Jenkins or recovering your pipelines, please contact your instructor.*
