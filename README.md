# N8N Automations
## Project Overview

- **Purpose:** A small repo to run and manage n8n automations using Docker Compose. It includes example workflows and a simple update script.
- **Included files:**
  - `docker_compose.yaml` — Docker Compose config.
  - `update_n8n.sh` — update helper
  - `Forward posts from Channels to Telegram n8n news.json` — my workflow export.

---

## Server / Environment

- **Platform:** Docker.
- **Server:** I'm using oracle cloud infrastructure (OCI) free tier, just a simple VM based on `VM.Standard.E2.1.Micro` running Debian ([this](https://gist.github.com/4abhinavjain/893ec13c651bee08088c8f4661998952) might be out of date, but consider this a starting point)

---

## Quick Setup

### Requirements: 
Install Docker and Docker Compose (or Docker Desktop).

### Installation
- Clone repo:
  ```bash
  git clone <your-repo-url>
  cd N8N
  ```
- **Configuration:** Before starting the containers, create a `.env` file in the root directory and configure your variables.
This file is required for Traefik (SSL) and n8n to communicate correctly.
  - Example .env:
  ``` properties
  # DOMAIN_NAME and SUBDOMAIN together determine where n8n will be reachable from
  # The top level domain to serve from
  DOMAIN_NAME=yourdomain.com
  # The subdomain to serve from
  SUBDOMAIN=yoursubdomain
  GENERIC_TIMEZONE=UTC
  # The email address to use for the TLS/SSL certificate creation
  SSL_EMAIL=your-email@example.com
  # Enforce correct permissions for n8n settings file (recommended for security)
  N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
  # Enable task runners to prevent deprecation warnings and future issues
  N8N_RUNNERS_ENABLED=true
  # Trust X-Forwarded-For header from reverse proxy (Traefik)
  N8N_PROXY_HOPS=1
  ```
  **DON'T FORGET** to change `DOMAIN_NAME`, `SUBDOMAIN`, `GENERIC_TIMEZONE`, `SSL_EMAIL`.
- Start n8n:
  ```bash
  docker compose -f docker_compose.yaml up -d
  ```
- Stop n8n:
  ```bash
  docker compose -f docker_compose.yaml down
  ```
- To backup the n8n data volume to a local tar file:
  ```bash
  docker run --rm -v n8n_data:/volume -v $(pwd):/backup alpine tar czf /backup/n8n_backup.tar.gz -C /volume .
  ```

---

## Updating n8n
- **Automatic helper**: Run the included script to pull the latest images and restart the service:
  ```bash
  ./update_n8n.sh
  ```
- Manual update (recommended when scripting or debugging):
  ```bash
  docker compose -f docker_compose.yaml pull
  docker compose -f docker_compose.yaml up -d
  ```

---

## Workflows — Add, Configure, and Use

### Import a workflow:
  - Open the n8n UI (as configured in docker_compose.yaml).
  - Click the workflow menu → Import and upload the JSON file (for example the included "Forward posts from Channels to Telegram n8n news.json").
### Credentials:
After importing, open the workflow and configure any node credentials via the Credentials section in the UI.
Common credentials include Telegram Bot API token or third-party API keys.

### Export / Backup a workflow:
  - In the n8n UI, open the workflow → Workflow menu → Export to download the JSON.
  - For full backups, copy the persistent data directory (configured as a Docker volume in docker_compose.yaml).

### Forward posts from Channels to Telegram (workflow details)
This workflow consolidates posts from multiple source channels and forwards them into a single Telegram channel using a bot. It is set to run every 30 min and collect all of the new posts since the last run.

- **Required credentials & setup:**
  - Create a Telegram bot via BotFather and copy the Bot Token.
  - Create a Telegram channel for consolidated posts and add the bot as administrator with permission to post.
  - In n8n, add a Telegram credential using the bot token.

- **Data Table:**
  - Create a Data Table named TelegramState with these fields:
  - channel_name (string) — channel identifier (e.g., my_channel)
  - last_message_id (number) — last handled message id
  - Example row:
    | channel_name | last_message_id |
    | :--- | :--- |
    | MotoMagazineIL | 1900 |

---

## Troubleshooting

**Logs:** Follow logs to diagnose issues:
  ```bash
  docker compose -f docker_compose.yaml logs -f
  ```
