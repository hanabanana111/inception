This project has been created as part of the 42 curriculum by hakobori.

Description

This project, titled "Inception," aims to broaden knowledge of system administration by using Docker. The primary goal is to virtualize several Docker images within a personal virtual machine to create a small, functional infrastructure. The project involves setting up a multi-container architecture including NGINX (with TLSv1.2 or TLSv1.3), WordPress with php-fpm, and MariaDB.

Project Overview and Design Choices

The infrastructure is built using Docker Compose, where each service runs in a dedicated, custom-built container.

Docker and Sources: Each Docker image is built from the penultimate stable version of Alpine or Debian using custom Dockerfiles. All configuration files are located in the srcs folder.

Virtual Machines vs Docker: While a VM virtualizes the entire hardware, Docker shares the host kernel, providing a lightweight isolation. This project runs Docker inside a VM to ensure a standardized, isolated environment.

Secrets vs Environment Variables: Non-sensitive settings are defined in `srcs/.env`. Sensitive data is managed from host files in the root `secrets/` directory and mounted into containers as `/run/secrets/*` paths.

Docker Network vs Host Network: A custom bridge network is used for internal container communication. The host network is avoided to maintain strict isolation and security boundaries.

Docker Volumes vs Bind Mounts: Named volumes are used for /home/login/data. Unlike bind mounts, named volumes are managed by the Docker engine, ensuring data persistence and better performance in this specific infrastructure.

Directory Structure

As per the project requirements, the repository is organized as follows:

.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── .gitkeep
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── .env.example
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── conf/
        │   ├── tools/
        │   └── Dockerfile
        ├── nginx/
        │   ├── conf/
        │   └── Dockerfile
        └── wordpress/
            ├── conf/
            ├── tools/
            └── Dockerfile


Instructions

Compilation & Installation

Clone the repository: Ensure you are on your Virtual Machine.

Setup Data Folders: Create the volume directories on your host machine:

mkdir -p /home/$USER/data/wordpress
mkdir -p /home/$USER/data/mariadb


Build and Run: Run the Makefile from the root:

make


Execution

Configure your /etc/hosts file: 127.0.0.1 hakobori.42.fr.

Access the site at https://hakobori.42.fr.

NGINX serves as the only entry point (Port 443).

Security Mounting Notes

Secret files from the host (`secrets/*.txt`) are exposed to containers through Docker secret mounts and consumed by `_FILE` variables in `srcs/.env` (for example: `SQL_PASSWORD_FILE=/run/secrets/db_password`).

Resources

References

Docker Documentation

NGINX TLS Configuration Guide

MariaDB Official Documentation

AI Usage

AI (Gemini) was used to assist in the following tasks:

Documentation: Drafting the structure of README.md, USER_DOC.md, and DEV_DOC.md.

Technical Comparison: Providing comparative analysis between VM/Docker and Volume/Bind Mounts.

Code Review: Explaining PID 1 best practices and reviewing the Makefile structure.

Validation: All AI-generated suggestions were manually tested and verified to comply with the project's strict constraints (no latest tags, no hacky patches).
