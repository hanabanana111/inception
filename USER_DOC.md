# Inception — User Guide (Evaluator)

## Overview

This project is part of the 42 system administration curriculum. It deploys a small Docker-based infrastructure composed of NGINX (TLS), WordPress (php-fpm), and MariaDB.

Configuration files are under `srcs/`, while host-side secret source files are stored in the root `secrets/` directory.

## Prerequisites

1. Use your VM environment for evaluation.
2. Ensure Docker and Docker Compose are available.
3. Create persistent data directories on the host:

```bash
mkdir -p /home/hakobori/data/wordpress
mkdir -p /home/hakobori/data/mariadb
```

## Host Configuration

Before starting the stack, add the following entry to your host machine `/etc/hosts`:

```text
127.0.0.1 hakobori.42.fr
```

## Installation and Startup

From the repository root, run:

```bash
make
```

This command builds the images and starts the full environment.

## Secret Handling

The stack uses file-based Docker secrets. Host files from `secrets/*.txt` are mounted into containers as `/run/secrets/*`, and services read them through `_FILE` environment variables from `srcs/.env`.

## Accessing the Service

Open the following URL in your browser:

```text
https://hakobori.42.fr
```

Because TLS uses a self-signed certificate in this local setup, your browser will show a security warning. It is expected for this project; select **Proceed** to continue.

## Cleanup Commands

- `make clean`: stops the running containers/environment.
- `make fclean`: performs a full cleanup (including removing the created resources/data tied to the project setup).

## Data Persistence

Persistent service data is stored under:

```text
/home/hakobori/data
```

This directory is used to keep WordPress and MariaDB data across container restarts.
