# Inception — Developer Technical Documentation

## Purpose

This document expands the Design Choices from `README.md` and provides implementation-oriented guidance for developers working on this 42 system administration project.

## 1. Architecture

The stack is designed as a three-container Docker Compose architecture, all based on Debian images:

1. **NGINX container**  
   - Public entry point of the platform  
   - Terminates HTTPS with TLS 1.2/1.3  
   - Forwards PHP requests to WordPress (PHP-FPM)

2. **WordPress container (PHP-FPM)**  
   - Executes PHP application logic  
   - Serves dynamic content behind NGINX  
   - Connects to MariaDB for persistent data

3. **MariaDB container**  
   - Stores WordPress database state  
   - Isolated from direct public access

This separation enforces clear service boundaries and mirrors production-style layering (edge proxy -> app runtime -> database).

## 2. Network Design

- A dedicated user-defined bridge network named **`inception`** is used for inter-container communication.
- Service discovery is handled internally by Docker DNS on that network.
- Only **port 443** is published to the host.
- No other service ports (e.g., WordPress/PHP-FPM or MariaDB) are exposed externally.

This model minimizes the attack surface while preserving internal connectivity.

## 3. Security Strategy

Credential handling follows a defense-in-depth policy:

- Non-sensitive runtime values are defined in `srcs/.env` and `srcs/.env.example`.
- Secret source files are managed at the repository root in `secrets/` (for example, `db_password.txt`, `db_root_password.txt`, `credentials.txt`).
- Containers consume secrets through Docker secret mounts at `/run/secrets/*`.

Policy summary:

- Never hardcode secrets in Dockerfiles or repository-tracked source files.
- Keep `.env` usage limited to non-sensitive parameters whenever possible.
- Use `_FILE` variables (for example, `SQL_PASSWORD_FILE`) to reference mounted secret files instead of raw passwords.
- Treat database credentials and private keys as secret material by default.

## Repository Layout Notes

Current root-level security-relevant layout:

```text
secrets/
├── .gitkeep
├── credentials.txt
├── db_password.txt
└── db_root_password.txt
```

Environment definitions are stored in:

```text
srcs/.env
srcs/.env.example
```

## 4. Storage and Volumes

The project uses **Named Volumes** managed by Docker and bound to host storage under:

```text
/home/hakobori/data
```

Typical persisted paths:

- `/home/hakobori/data/wordpress`
- `/home/hakobori/data/mariadb`

Rationale:

- Persistence across container recreation
- Predictable host-side backup location
- Cleaner lifecycle management than ad hoc bind mounts alone

## 5. Runtime Debugging and Inspection

For operational troubleshooting, use the following commands:

```bash
docker logs <container_name>
docker exec -it <container> sh
```

Recommended checks:

- NGINX: TLS config, upstream connectivity, HTTP status codes
- WordPress/PHP-FPM: PHP-FPM process status, app config, file permissions
- MariaDB: service startup state, database/schema visibility, auth errors

## 6. Service Communication Flow (ASCII Diagram)

```text
[Browser]
    |
    | HTTPS :443 (TLS 1.2/1.3)
    v
[NGINX]
    |
    | FastCGI / internal app traffic
    v
[WordPress (PHP-FPM)]
    |
    | SQL (internal only)
    v
[MariaDB]
```

All east-west traffic remains inside the `inception` bridge network; only NGINX is north-south exposed.


## 7. Change WP port

```text
[docker-compose.yml]

    ports:
      - "443:443"

    ports:
      - "8080:443"

Note:https://hakobori.42.fr:8080/
```