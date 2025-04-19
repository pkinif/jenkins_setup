# Jenkins Setup for Local Development

Welcome to your **local Jenkins setup**! In this project, you will set up and maintain your own Jenkins server running inside Docker. Follow the instructions carefully.

------------------------------------------------------------------------
## 🔹 Pre-requisites

This project is designed to be run locally on your machine. You will need to have **Docker** and **Docker Compose** installed.
You need to fork this repository to your own GitHub account and clone it to your local machine.

## 🔹 How to Set Up Jenkins Locally

1.  **Build your Jenkins Docker image**

    Use the provided `dockerfile` to build a Jenkins image with R installed:

    ``` bash
    docker build -f dockerfile -t <your-dockerhub-username>/jenkins:latest .
    ```

    ⚡ **Important**: Replace `<your-dockerhub-username>` with your **Docker Hub username**.\
    (You will need it later to push your image to Docker Hub.)

2.  **Launch Jenkins using Docker Compose**

    Use the provided `docker-compose.yml`:

    ``` bash
    docker compose up -d
    ```

    -   We are **mounting a local volume** (`./jenkins_home`) to **/var/jenkins_home** inside the container.
    -   This means that even if you build a new Docker image and run `docker compose down && docker compose up`, **you will not lose your Jenkins jobs, configuration, or users**.

3.  **First Startup: Unlock Jenkins**

    When you first access Jenkins (<http://localhost:8080>), it will ask for an **Administrator password**.

    -   You can find this password inside your RStudio project, at:

        ```         
        ./jenkins_home/secrets/initialAdminPassword
        ```

    Example:

    ``` bash
    cat ./jenkins_home/secrets/initialAdminPassword
    ```

4.  **Install Recommended Plugins**

    After unlocking, Jenkins will prompt you to **install the recommended plugins**.

    Click **"Install Suggested Plugins"** and wait until the process is complete.

5.  **Create Your Admin User**

    After plugins installation, Jenkins will ask you to **create the first admin user**.

    -   Use a real email address! You will need it later.

6.  **Save and Finish**

    Once you complete the setup, click **"Save and Finish"**.

7.  **Ready to Use!**

    Your Jenkins server is now ready.

------------------------------------------------------------------------

## 🔹 Important Notes

-   **Linux Dependencies**

    You are responsible for **updating the Linux dependencies** in the Dockerfile if your R data pipelines require specific system libraries.

-   **Persisted Data**

    Thanks to the mounted volume, even if you:

    -   Build a new Docker image
    -   Run `docker compose down` and then `docker compose up -d` ➔ **All your Jenkins configuration and jobs will persist**.

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

-   .Renviron

    Jenkins need access to the PostGreSQL db. You need to mount the .Renviron to the docker-compose environment.
    
    ``` r
    usethis::edit_r_environ(scope = 'project')
    ```
    
    Add the following lines to your `.Renviron` file:

    ``` r
    # .Renviron
    PG_DB = '...'
    PG_HOST = '...'
    PG_USER = '...'
    PG_PASSWORD = '...'
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

-   **Pull a new image (if image updated)**

    ``` bash
    docker pull <your-dockerhub-username>/jenkins:latest
    docker compose down
    docker compose up -d
    ```

------------------------------------------------------------------------

## 🔹 GitHub Actions

We will set up a GitHub Actions workflow that automatically builds your Docker image and pushes it to your Docker Hub account every time you push to the main branch.

------------------------------------------------------------------------

## 🔹 Summary

You are responsible for your Jenkins environment:

\- Keep your volume mounted.

\- Update Linux dependencies if needed.

\- Maintain your R pipelines inside Jenkins safely.

Happy CI/CD building! 🚀

------------------------------------------------------------------------

*If you have any issue starting Jenkins or recovering your pipelines, please contact your instructor.*
