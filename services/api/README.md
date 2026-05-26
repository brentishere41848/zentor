# Pasus API

Rust Axum backend for local Pasus development.

## Run With Docker Compose

```powershell
cd C:\Users\Brent\CodexProjects\Pasus
docker compose -f infra/docker-compose.yml up --build
```

The Compose API listens on `http://localhost:18080`.

```powershell
Invoke-RestMethod http://localhost:18080/v1/health
```

The compose stack starts:

- PostgreSQL on `localhost:15432`
- Redis on `localhost:16379`
- Pasus API on `localhost:18080`

## Development Seed

On startup, the API creates a local development project and API key:

```text
PASUS_DEV_PROJECT_ID=pasus-default
PASUS_DEV_PUBLIC_GAME_KEY=pasus-public-client
```

Use the key as:

```text
Authorization: Bearer pasus-public-client
```

## Run With Cargo

Start Postgres and Redis:

```powershell
cd C:\Users\Brent\CodexProjects\Pasus
docker compose -f infra/docker-compose.yml up postgres redis
```

Run the API:

```powershell
cd services/api
$env:DATABASE_URL="postgres://pasus:pasus@localhost:15432/pasus"
$env:REDIS_URL="redis://localhost:16379"
cargo run
```

When running with Cargo directly, the API listens on `http://localhost:8080` unless you set `PASUS_API_BIND_ADDR`.

## Endpoints

- `GET /v1/health`
- `POST /v1/projects`
- `POST /v1/players`
- `POST /v1/sessions`
- `POST /v1/sessions/{session_id}/heartbeat`
- `POST /v1/sessions/{session_id}/events`
- `POST /v1/sessions/{session_id}/end`
- `GET /v1/players/{player_id}/risk`
- `POST /v1/bans`
- `POST /v1/detections`
- `POST /v1/quarantine`
- `GET /v1/audit-logs`

## Safety

The API stores only protection-related session, event, risk, detection, quarantine metadata, and audit data. It does not receive raw personal files or credentials from the client.
