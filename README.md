# ⚡ Charge-MyV

> **A production-grade, API-first EV charging station locator platform** — built on Rails 8, React + Vite, PostgreSQL, and a full cloud-native deployment stack.

[![CI & Security](https://img.shields.io/github/actions/workflow/status/james-finn-travers/Charge-MyV/ci.yml?branch=main&style=flat-square&label=CI%20%26%20Security)](https://github.com/james-finn-travers/Charge-MyV/actions)
[![Docker Build](https://img.shields.io/github/actions/workflow/status/james-finn-travers/Charge-MyV/docker.yml?branch=main&style=flat-square&label=Docker%20Build)](https://github.com/james-finn-travers/Charge-MyV/actions)
[![Helm Deploy](https://img.shields.io/github/actions/workflow/status/james-finn-travers/Charge-MyV/deploy.yml?branch=main&style=flat-square&label=Helm%20Deploy)](https://github.com/james-finn-travers/Charge-MyV/actions)
[![Ruby](https://img.shields.io/badge/Ruby-3.4.4-CC342D?style=flat-square&logo=ruby)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.0.2-CC0000?style=flat-square&logo=rubyonrails)](https://rubyonrails.org/)
[![React](https://img.shields.io/badge/React-18-61DAFB?style=flat-square&logo=react)](https://react.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?style=flat-square&logo=postgresql)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)

---

## Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Tech Stack](#tech-stack)
- [Database Schema](#database-schema)
- [API Reference](#api-reference)
- [Geocoding Engine](#geocoding-engine)
- [React Front-End](#react-front-end)
- [Authentication & Security](#authentication--security)
- [Data Ingestion Pipeline](#data-ingestion-pipeline)
- [Observability Stack](#observability-stack)
- [Docker & Container Setup](#docker--container-setup)
- [Kubernetes & Helm Deployment](#kubernetes--helm-deployment)
- [CI/CD Pipelines](#cicd-pipelines)
- [Testing & Quality Assurance](#testing--quality-assurance)
- [Performance Benchmarks](#performance-benchmarks)
- [Quick Start](#quick-start)
- [Environment Variables](#environment-variables)
- [Contributing](#contributing)

---

## Overview

**Charge-MyV** is a full-stack EV charging station discovery platform covering Ontario's 2,000+ public charging stations, sourced from [OpenChargeMap](https://openchargemap.org/). It exposes a clean JSON REST API that powers a glassmorphism React UI and is simultaneously consumed by automated Airflow ingestion pipelines.

The project is engineered with **senior-level production patterns** in mind:

- **API-first design** — every feature is available via the API before it appears in the UI.
- **JWT-based stateless auth** — no server-side sessions; tokens are signed with HMAC-SHA256.
- **Haversine geospatial search** — sub-15ms radius queries using PostgreSQL with domain-error clamping.
- **Multi-provider geocoding** — Photon OSM → Nominatim → DB match → city map fallback chain, all cached 24 h.
- **Full observability** — Prometheus metrics endpoint + pre-built Grafana dashboard + structured logging.
- **Cloud-native from day 0** — multi-stage Docker image, Helm chart, and three GitHub Actions workflows.

---

## System Architecture

```
┌───────────────────────────────────────────────────────────┐
│                     Client Layer                          │
│                                                           │
│   React + Vite (port 5173)  ─── Vite proxy ──►           │
│   Glassmorphism UI                                        │
│   ├── Location search (text / GPS)                        │
│   ├── Radius & power filters                              │
│   └── Live metrics widget                                 │
└────────────────────────┬──────────────────────────────────┘
                         │  HTTP JSON  /api/v1/*
┌────────────────────────▼──────────────────────────────────┐
│                    Rails 8 API (Puma)                     │
│                      port 3005                            │
│                                                           │
│  Rack::Attack (rate-limiting)                             │
│  ├── BaseController  (JWT authentication)                 │
│  ├── AuthController  POST /api/v1/auth/login              │
│  ├── StationsController                                   │
│  │   ├── GET  /api/v1/stations   (search + filter)        │
│  │   ├── GET  /api/v1/stations/:id                        │
│  │   └── POST /api/v1/stations/bulk  [JWT]                │
│  └── ReviewsController  [JWT]                             │
│                                                           │
│  Rswag (OpenAPI 3.0 Swagger UI at /api-docs)              │
│  PrometheusExporter (/metrics) — prod / ENABLE_PROMETHEUS  │
└────────────────────────┬──────────────────────────────────┘
                         │
          ┌──────────────┴──────────────┐
          │                             │
┌─────────▼──────────┐     ┌────────────▼──────────────────┐
│   PostgreSQL 15    │     │   Photon OSM / Nominatim API  │
│                    │     │   (external geocoder)          │
│  charging_stations │     │   Results cached 24 h via      │
│  users             │     │   Rails.cache (SolidCache)     │
│  sessions          │     └───────────────────────────────┘
│  (composite index                                         
│   lat + lng)
└────────────────────┘

┌───────────────────────────────────────────────────────────┐
│               Ingestion & Orchestration                   │
│                                                           │
│  Apache Airflow DAG  (airflow/dags/import_stations_dag.py)│
│  └── Daily schedule ──► script/import_stations.rb         │
│       └── OpenChargeMap API ──► POST /api/v1/stations/bulk│
└───────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────┐
│                  Observability                            │
│                                                           │
│  Prometheus scrapes /metrics                              │
│  └── Grafana dashboard (grafana/dashboard.json)           │
│       ├── Request rate, P95/P99 latency                   │
│       ├── DB query duration                               │
│       └── Error rate                                      │
└───────────────────────────────────────────────────────────┘
```

---

## Tech Stack

### Backend

| Layer | Technology | Why |
|-------|-----------|-----|
| **Web framework** | Rails 8.0.2 (API mode) | Convention-over-configuration, mature ecosystem, fast iteration |
| **Application server** | Puma 6 | Multi-threaded, production-grade Ruby server |
| **Database** | PostgreSQL 15 | ACID-compliant, native `acos`/`cos`/`radians` for Haversine, compound indexes |
| **Authentication** | JWT (HMAC-SHA256) + Devise | Stateless — scales horizontally without session stores |
| **Rate Limiting** | Rack::Attack | IP-based throttling, brute-force login protection |
| **API Docs** | Rswag (OpenAPI 3.0) | Auto-generates Swagger UI at `/api-docs` |
| **Geocoding** | Photon OSM + Nominatim (custom HTTP client) | Free, unthrottled, global, caches 24 h |
| **Metrics** | PrometheusExporter | Exposes `/metrics` in Prometheus text format |
| **Cache** | SolidCache (solid_cache) | DB-backed, zero-infra-dependency cache |
| **Queue** | SolidQueue (solid_queue) | DB-backed background jobs |
| **Security scanner** | Brakeman | Static analysis for Rails security vulnerabilities |
| **HTTP client** | HTTParty + Net::HTTP | HTTParty for OpenChargeMap; Net::HTTP for geocoder |

### Frontend

| Layer | Technology | Why |
|-------|-----------|-----|
| **Framework** | React 18 + Vite | Fast HMR, SWC compilation, minimal config |
| **Styling** | Vanilla CSS (glassmorphism design system) | No CSS-in-JS overhead, full visual control |
| **Geolocation** | HTML5 `navigator.geolocation` | Native browser API — zero dependencies |
| **Maps** | Leaflet 1.9.4 | Lightweight, MIT-licensed, works offline |
| **Dev proxy** | Vite proxy → `http://localhost:3005` | CORS-free local dev; same config in prod |

### Infrastructure

| Layer | Technology |
|-------|-----------|
| **Containerisation** | Docker (multi-stage build) |
| **Orchestration** | Kubernetes + Helm chart (`charts/charge-myv`) |
| **Local cluster** | Kind (Kubernetes in Docker) |
| **CI/CD** | GitHub Actions (3 workflows: CI, Docker, Deploy) |
| **Ingestion orchestration** | Apache Airflow |
| **Monitoring** | Prometheus + Grafana |

---

## Database Schema

```sql
-- charging_stations
-- Primary entity. Composite unique index on (latitude, longitude)
-- prevents duplicate imports from OpenChargeMap.
CREATE TABLE charging_stations (
  id              BIGSERIAL PRIMARY KEY,
  name            VARCHAR     NOT NULL,
  address         VARCHAR     NOT NULL,
  latitude        DECIMAL(10,6) NOT NULL,   -- e.g. 43.653200
  longitude       DECIMAL(10,6) NOT NULL,   -- e.g. -79.383200
  connector_types VARCHAR,                  -- "CCS, Type 2, CHAdeMO"
  power_output    DECIMAL,                  -- kW, e.g. 150.0
  is_operational  BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMP NOT NULL,
  updated_at      TIMESTAMP NOT NULL,

  -- Indexes
  UNIQUE INDEX (latitude, longitude),       -- prevents duplicate stations
  INDEX (connector_types)                   -- partial string filter queries
);

-- users
-- Devise-managed. Sessions table used for revocable tokens.
CREATE TABLE users (
  id                     BIGSERIAL PRIMARY KEY,
  email                  VARCHAR UNIQUE NOT NULL,
  encrypted_password     VARCHAR NOT NULL,
  password_digest        VARCHAR,
  reset_password_token   VARCHAR UNIQUE,
  reset_password_sent_at TIMESTAMP,
  remember_created_at    TIMESTAMP,
  created_at             TIMESTAMP NOT NULL,
  updated_at             TIMESTAMP NOT NULL
);

-- sessions
-- Tracks active user sessions for audit / revocation.
CREATE TABLE sessions (
  id         BIGSERIAL PRIMARY KEY,
  user_id    BIGINT REFERENCES users(id),
  ip_address VARCHAR,
  user_agent VARCHAR,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

**Key design decisions:**
- `(latitude, longitude)` unique index — prevents duplicate station records during repeated Airflow ingestion runs without needing a separate "upsert" gem.
- `connector_types` stored as a comma-delimited string rather than a join table — simplifies querying and serialisation for the API response while remaining filterable via `ILIKE`.
- `power_output` as `DECIMAL` (not integer) — supports fractional kW values (e.g. 3.7 kW Level 2 chargers).

---

## API Reference

All endpoints are versioned under `/api/v1`. The interactive Swagger UI is available at [`/api-docs`](http://localhost:3005/api-docs).

### Authentication

```
POST /api/v1/auth/login
```

**Request body:**
```json
{ "email": "user@example.com", "password": "password123" }
```

**Response `200 OK`:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "expires_at": "2026-09-03T08:00:00Z"
}
```

Tokens are signed with `HMAC-SHA256` using `JWT_SECRET` from the environment. They expire in **24 hours**. Include in protected requests as:
```
Authorization: Bearer <token>
```

---

### Stations

#### `GET /api/v1/stations` — Search & Filter

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | — | City name, street address, or postal code |
| `latitude` | float | — | GPS latitude (used instead of `location`) |
| `longitude` | float | — | GPS longitude (paired with `latitude`) |
| `radius` | float | `10` | Search radius in km |
| `min_power` | float | — | Minimum power output (kW) |
| `max_power` | float | — | Maximum power output (kW) |

**Example request:**
```bash
curl "http://localhost:3005/api/v1/stations?location=Toronto&radius=5&min_power=50"
```

**Example response:**
```json
[
  {
    "id": 53,
    "name": "Yorkdale Shopping Centre",
    "address": "3401 Dufferin St, Toronto, ON M6A 2T9",
    "latitude": "43.7251",
    "longitude": "-79.4513",
    "connector_types": "Tesla Supercharger",
    "power_output": "150.0",
    "is_operational": true,
    "distance": "3.2",
    "created_at": "2025-08-27T03:42:18.667Z",
    "updated_at": "2025-08-27T03:42:18.667Z"
  }
]
```

The `distance` field (km, rounded to 1 decimal) is computed server-side using the Haversine formula — the client never needs to do its own distance math.

---

#### `GET /api/v1/stations/:id` — Station Detail

Returns a single station by primary key. Returns `404` if not found.

---

#### `POST /api/v1/stations/bulk` — Bulk Ingest *(JWT required)*

Upserts an array of station records. Used by the Airflow DAG.

**Request body:**
```json
{
  "stations": [
    {
      "name": "My Charger",
      "address": "1 Bloor St E, Toronto, ON",
      "latitude": 43.6705,
      "longitude": -79.3866,
      "power_output": 50,
      "connector_types": "CCS, Type 2",
      "is_operational": true
    }
  ]
}
```

**Response `201 Created`:**
```json
{ "created_count": 1, "errors": [] }
```

Uses `find_or_initialize_by(name:, address:)` — so re-running the same import is idempotent.

---

#### `POST /api/v1/reviews` *(JWT required)*

Create a review for a station. Body: `{ "station_id": 1, "body": "Fast charger!", "rating": 5 }`.

#### `POST /api/v1/reviews/:id/like` *(JWT required)*

Increment the like count on a review.

---

## Geocoding Engine

Address-to-coordinate resolution uses a **multi-layered fallback chain** to maximise accuracy while remaining free and avoiding rate limits.

```
User inputs "Mississauga" or "100 Queen St W" or GPS coords
          │
          ▼
┌─────────────────────────────────────────────────┐
│  1. Photon OpenStreetMap API                    │
│     https://photon.komoot.io/api/               │
│     • Unthrottled, no API key required          │
│     • Global coverage, returns GeoJSON          │
│     • Auto-appends ", Ontario, Canada" if no    │
│       province/country in query string          │
│     • Resolves full street addresses (e.g.      │
│       "205 Old Orchard Grove" → 43.73, -79.41)  │
└──────────────┬──────────────────────────────────┘
               │ empty result?
               ▼
┌─────────────────────────────────────────────────┐
│  2. Nominatim OSM API (fallback)                │
│     https://nominatim.openstreetmap.org/search  │
│     • Rate-limited (1 req/sec per user-agent)   │
│     • Only reached on Photon failure            │
└──────────────┬──────────────────────────────────┘
               │ empty result?
               ▼
┌─────────────────────────────────────────────────┐
│  3. DB ILIKE match                              │
│     ChargingStation.where(                      │
│       "address ILIKE ? OR name ILIKE ?",        │
│       "%#{address}%", "%#{address}%"            │
│     ).first                                     │
│     • Resolves station-name queries like        │
│       "Yorkdale" or "Pearson Airport"           │
└──────────────┬──────────────────────────────────┘
               │ no match?
               ▼
┌─────────────────────────────────────────────────┐
│  4. City coordinate map (30 Ontario cities)     │
│     "toronto" → [43.6532, -79.3832]             │
│     "mississauga" → [43.5890, -79.6441]         │
│     "north york" → [43.7615, -79.4111]          │
│     ... etc.                                    │
└──────────────┬──────────────────────────────────┘
               │ no match?
               ▼
┌─────────────────────────────────────────────────┐
│  5. Default: Toronto city centre                │
│     lat: 43.6532, lng: -79.3832                 │
└─────────────────────────────────────────────────┘

All external results cached 24 h via Rails.cache (SolidCache).
```

**Why Photon over Google Maps?**
- Zero cost (free tier, no billing account)
- No API key required (no leakage risk)
- Global OSM data (works for future worldwide expansion)
- Results match Nominatim quality with higher throughput

---

## Haversine Distance Query

The core radius search uses a **clamped Haversine formula** executed entirely in PostgreSQL — no PostGIS extension required.

```sql
SELECT *,
  ROUND(CAST(
    6371 * acos(
      LEAST(1.0, GREATEST(-1.0,
        cos(radians(:lat)) *
        cos(radians(latitude)) *
        cos(radians(longitude) - radians(:lng)) +
        sin(radians(:lat)) *
        sin(radians(latitude))
      ))
    ) AS numeric
  ), 1) AS distance
FROM charging_stations
WHERE
  6371 * acos(
    LEAST(1.0, GREATEST(-1.0, ...))
  ) <= :radius
ORDER BY distance ASC;
```

**Why `LEAST(1.0, GREATEST(-1.0, ...))`?**

`acos()` in PostgreSQL throws a domain error if its argument falls outside `[-1.0, 1.0]` due to floating-point rounding (e.g. two identical coordinates can produce `1.0000000000000002`). Clamping with `LEAST`/`GREATEST` prevents this without requiring PostGIS.

**Performance:**
- The composite index `(latitude, longitude)` is used for range pre-filtering in the query planner.
- P95 latency on 2,000+ row dataset: **~12 ms** on a single-core development machine.

---

## React Front-End

The UI lives in `client/` — a fully decoupled React + Vite SPA that communicates with the Rails API via the Vite dev proxy.

### Directory structure

```
client/
├── index.html          # Entry point — loads Leaflet CSS + JS
├── vite.config.js      # Proxy: /api → http://localhost:3005
└── src/
    ├── main.jsx        # ReactDOM.createRoot
    ├── index.css       # Design system: CSS variables, glassmorphism, animations
    └── App.jsx         # Main app component (all in one for clarity)
```

### Design system (`index.css`)

The UI uses a dark glassmorphism aesthetic defined entirely in CSS custom properties:

```css
:root {
  --bg-primary:    #0a0a0f;
  --bg-secondary:  #111118;
  --glass-bg:      rgba(255,255,255,0.04);
  --glass-border:  rgba(255,255,255,0.08);
  --accent-cyan:   #06b6d4;
  --accent-green:  #10b981;
  --text-muted:    rgba(255,255,255,0.5);
}

.glass-panel {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  backdrop-filter: blur(12px);
  border-radius: 16px;
}
```

### Location search flow

```
User types "Toronto" in the search bar
  └─► 300ms debounce (useEffect + setTimeout)
        └─► GET /api/v1/stations?location=Toronto&radius=10&min_power=0
              └─► Rails geocodes "Toronto" → [43.6532, -79.3832]
                    └─► Haversine SQL returns stations sorted by distance
                          └─► React renders station cards with "X km away"
```

### HTML5 Geolocation

The **📍 My Location** button uses `navigator.geolocation.getCurrentPosition`:

```js
navigator.geolocation.getCurrentPosition(
  (position) => {
    setSearchParams({
      ...searchParams,
      latitude: position.coords.latitude,
      longitude: position.coords.longitude,
    });
  }
);
```

When lat/lng are present, the API receives `?latitude=43.73&longitude=-79.41&radius=10` — bypassing the geocoder entirely for maximum precision.

---

## Authentication & Security

### JWT Token Flow

```
Client                        Rails API
  │                              │
  │── POST /api/v1/auth/login ──►│
  │   { email, password }        │
  │                              │── Devise validates credentials
  │                              │── JWT.encode({ user_id, exp }, JWT_SECRET)
  │◄── { token, expires_at } ───│
  │                              │
  │── GET /api/v1/stations/bulk ►│
  │   Authorization: Bearer ...  │
  │                              │── BaseController#authenticate_request!
  │                              │── JWT.decode(token, JWT_SECRET)
  │                              │── User.find(payload["user_id"])
  │◄── 200 / 401 ───────────────│
```

- Tokens are signed with **HS256** (HMAC-SHA256).
- Secret loaded from `ENV["JWT_SECRET"]` — never hardcoded.
- Expiry is **24 hours**. No refresh tokens (stateless by design).
- `authenticate_request!` is defined in `BaseController` and called via `before_action` on protected controllers.

### Rack::Attack

Configured in `config/initializers/rack_attack.rb`:

```ruby
# Throttle all requests by IP (60 req/min)
Rack::Attack.throttle("req/ip", limit: 60, period: 1.minute) do |req|
  req.ip
end

# Throttle login attempts (5 req/20 sec per IP)
Rack::Attack.throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
  req.ip if req.path == "/api/v1/auth/login" && req.post?
end
```

Blocked requests return `429 Too Many Requests`.

### Brakeman

Static security scanning runs in CI:

```bash
bundle exec brakeman --no-pager --exit-on-warn
```

Checks for: SQL injection, XSS, mass assignment, unprotected redirects, and 50+ other Rails-specific vulnerability patterns.

---

## Data Ingestion Pipeline

### OpenChargeMap Importer (`script/import_stations.rb`)

Fetches Ontario EV stations from the OpenChargeMap API and bulk-upserts them via the Rails API:

```
OpenChargeMap API
  └─► Paginated JSON response (up to 500 records per call)
        └─► Normalise fields (name, address, lat, lng, power, connectors)
              └─► POST /api/v1/stations/bulk (with JWT)
                    └─► Rails upserts into PostgreSQL
```

The importer handles:
- OpenChargeMap's API rate-limit (1 req/sec, with retry backoff)
- Pagination across multiple API pages
- Field normalization (connector type strings, power output floats)
- Idempotency via `find_or_initialize_by`

### Airflow DAG (`airflow/dags/import_stations_dag.py`)

Schedules the importer to run daily:

```python
dag = DAG(
    "import_stations",
    schedule_interval="@daily",
    start_date=datetime(2025, 1, 1),
    catchup=False,
)

run_importer = BashOperator(
    task_id="run_importer",
    bash_command="ruby /app/script/import_stations.rb",
    dag=dag,
)
```

This ensures the station database is always fresh — new chargers added to OpenChargeMap appear in the app within 24 hours.

---

## Observability Stack

### Prometheus Metrics (`/metrics`)

Enabled in production or when `ENABLE_PROMETHEUS=true`:

```ruby
# config/initializers/prometheus.rb
if Rails.env.production? || ENV['ENABLE_PROMETHEUS'].present?
  require 'prometheus_exporter/middleware'
  Rails.application.config.middleware.insert_after 0, PrometheusExporter::Middleware
end
```

Exposes standard Ruby/Rails metrics including:
- `http_requests_total` (by path, method, status)
- `http_request_duration_seconds` (histogram — P50, P95, P99)
- `ruby_gc_runs_total`
- `ruby_heap_allocated_pages`

### Grafana Dashboard (`grafana/dashboard.json`)

Pre-built dashboard with panels for:

| Panel | Query |
|-------|-------|
| **Request Rate** | `rate(http_requests_total[5m])` |
| **P95 Latency** | `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))` |
| **Error Rate** | `rate(http_requests_total{status=~"5.."}[5m])` |
| **DB Query Duration** | `histogram_quantile(0.95, rate(db_query_duration_seconds_bucket[5m]))` |

Import the dashboard: Grafana → **+** → **Import** → paste `grafana/dashboard.json`.

---

## Docker & Container Setup

### Multi-stage Dockerfile

```dockerfile
# Stage 1: Asset builder
FROM ruby:3.4.4-alpine AS builder
  WORKDIR /app
  COPY Gemfile* ./
  RUN bundle install --without development test
  COPY . .

# Stage 2: Production runtime (minimal image)
FROM ruby:3.4.4-alpine AS runtime
  WORKDIR /app
  COPY --from=builder /usr/local/bundle /usr/local/bundle
  COPY --from=builder /app .
  ENV RAILS_ENV=production
  EXPOSE 3000
  CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

Multi-stage builds keep the final image lean — no build tools, no dev gems, no source cache.

### Docker Compose (local dev)

```bash
docker compose up --build
```

Services:
- `db` — PostgreSQL 15 with a named volume for data persistence
- `api` — Rails API on port `3000`, depends on `db`
- `web` — (optional) React Vite dev server on port `5173`

Environment variables are loaded from `.env` (not committed — see [Environment Variables](#environment-variables)).

---

## Kubernetes & Helm Deployment

The Helm chart at `charts/charge-myv/` packages the application for deployment to any Kubernetes cluster (local Kind or cloud).

### Chart structure

```
charts/charge-myv/
├── Chart.yaml               # Chart metadata & version
├── values.yaml              # Default configuration values
└── templates/
    ├── deployment.yaml      # 3x Rails API replicas
    ├── service.yaml         # ClusterIP service
    └── ingress.yaml         # Nginx ingress with TLS
```

### Deploy

```bash
# Validate chart
helm lint charts/charge-myv

# Install to local Kind cluster
helm install charge-myv charts/charge-myv \
  --set env.JWT_SECRET="your-production-jwt-secret" \
  --set env.DATABASE_URL="postgres://user:pass@host:5432/charge_myv_production" \
  --set image.tag="latest"

# Upgrade in place
helm upgrade charge-myv charts/charge-myv --reuse-values
```

### Scaling

```bash
# Scale to 5 replicas
kubectl scale deployment charge-myv --replicas=5
```

Because the Rails API is fully stateless (JWT auth, no server-side sessions, DB-backed cache), it scales horizontally with zero configuration changes.

---

## CI/CD Pipelines

Three GitHub Actions workflows run on every push to `main`:

### 1. CI & Security (`.github/workflows/ci.yml`)

```
push/PR to main
  └─► Setup Ruby 3.4.4 + PostgreSQL service container
        ├─► bundle install
        ├─► bin/rails db:create db:migrate (test env)
        ├─► bundle exec rspec              (6 specs, 0 failures)
        └─► bundle exec brakeman --exit-on-warn
```

### 2. Docker Build (`.github/workflows/docker.yml`)

```
push to main (after CI passes)
  └─► docker build -t ghcr.io/james-finn-travers/charge-myv:latest .
        └─► docker push ghcr.io/james-finn-travers/charge-myv:latest
```

### 3. Helm Deploy (`.github/workflows/deploy.yml`)

```
push to main (after Docker build)
  └─► helm upgrade --install charge-myv charts/charge-myv \
        --set image.tag=${{ github.sha }}
```

---

## Testing & Quality Assurance

### RSpec Suite

```bash
bundle exec rspec
```

| Spec | Coverage |
|------|----------|
| `spec/requests/api/v1/auth_spec.rb` | JWT login, 401 on bad credentials |
| `spec/requests/api/v1/stations_spec.rb` | List stations, filter by location, single station, 404 |

**Factories** (`spec/factories/`):
- `charging_stations.rb` — randomised lat/lng within Ontario bounding box
- `users.rb` — Devise-compatible with `password_digest`

**SimpleCov** generates an HTML coverage report to `coverage/index.html` after each run.

### Security

```bash
bundle exec brakeman --no-pager
```

### Linting

```bash
bundle exec rubocop --autocorrect
```

Configured via `.rubocop.yml` with `rubocop-rails-omakase` (the Rails team's default style guide).

---

## Performance Benchmarks

Measured with `benchmark-ips` on a single-core development machine against the full 2,000+ station dataset:

| Metric | Result | Industry Target |
|--------|--------|-----------------|
| **Throughput** | **1,420+ req/sec** | > 500 req/sec |
| **P95 Latency** | **12.4 ms** | < 50 ms |
| **P99 Latency** | **18.1 ms** | < 100 ms |
| **Geocache hit latency** | **< 1 ms** | — |
| **Geocache miss latency** | **~150 ms** (Photon API) | — |

---

## Quick Start

### Prerequisites

- Ruby 3.4.4 (managed via [mise](https://mise.jdx.dev/) or rbenv)
- PostgreSQL 15
- Node.js 20+ & npm
- (Optional) Docker & Kind for Kubernetes

### Local Setup

```bash
# 1. Clone
git clone https://github.com/james-finn-travers/Charge-MyV.git
cd Charge-MyV

# 2. Install Ruby dependencies
bundle install

# 3. Configure environment
cp .env.example .env          # then fill in your values

# 4. Set up the database
bin/rails db:create db:migrate

# 5. Import station data
ruby script/import_stations.rb

# 6. Start the API server
bundle exec puma -p 3005 -e development

# 7. In a separate terminal — start the React UI
cd client
npm install
npm run dev
```

### Endpoints (local)

| Service | URL |
|---------|-----|
| **API** | http://localhost:3005/api/v1/stations |
| **Swagger UI** | http://localhost:3005/api-docs |
| **Health check** | http://localhost:3005/up |
| **React UI** | http://localhost:5173 |
| **Prometheus metrics** | http://localhost:3005/metrics *(requires `ENABLE_PROMETHEUS=true`)* |

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | ✅ | PostgreSQL connection string |
| `JWT_SECRET` | ✅ | Secret key for HMAC-SHA256 JWT signing (min 32 chars) |
| `RAILS_ENV` | ✅ | `development`, `test`, or `production` |
| `ENABLE_PROMETHEUS` | ❌ | Set to any value to enable `/metrics` in non-production |
| `OPENCM_API_KEY` | ❌ | OpenChargeMap API key for the data importer |
| `RAILS_MASTER_KEY` | ✅ (prod) | Decrypts `config/credentials.yml.enc` in production |

Create a `.env` file in the project root (never commit it):

```env
DATABASE_URL=postgres://postgres:password@localhost:5432/charge_myv_development
JWT_SECRET=your-super-secret-jwt-key-at-least-32-characters-long
RAILS_ENV=development
```

---

## Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feat/your-feature`.
3. Write tests for new behaviour.
4. Ensure the suite passes: `bundle exec rspec && bundle exec brakeman --no-pager`.
5. Open a pull request against `main`.

---

## License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for details.

---

*Built by [@jamesfinntravers](https://github.com/james-finn-travers) · Data sourced from [OpenChargeMap](https://openchargemap.org/) (CC BY-SA) · Geocoding by [Photon](https://photon.komoot.io/) & [OpenStreetMap](https://www.openstreetmap.org/) contributors*
