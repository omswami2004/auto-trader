# Auto-Trader Infrastructure & Operations Monitoring

This directory contains the production-ready monitoring and telemetry stack for the Auto-Trader system, powered by **Prometheus**, **Grafana**, and **Node Exporter**.

---

## Architecture Overview

```
+-----------------------------------------------------------+
|                        Host System                        |
|                                                           |
|   +-------------------+           +-------------------+   |
|   |   Auto-Trader     |           |   Node Exporter   |   |
|   |   (Backend :8080) |           |   (:9100)         |   |
|   +---------+---------+           +---------+---------+   |
|             |                               |             |
|             | Scrapes /api/health           | Scrapes     |
|             |                               | host metrics|
|             +---------------v---------------+             |
|                             |                             |
|                    +--------+--------+                    |
|                    |   Prometheus    |                    |
|                    |   (:9090)       |                    |
|                    +--------+--------+                    |
|                             |                             |
|                             | Datasource                  |
|                             v                             |
|                    +-----------------+                    |
|                    |     Grafana     |                    |
|                    |     (:3000)     |                    |
|                    +-----------------+                    |
+-----------------------------------------------------------+
```

### Components

1. **Auto-Trader**: The high-frequency trading server running on port `8080` (providing `/api/health` diagnostics and trading telemetry).
2. **Node Exporter**: Collects deep host-level operational metrics including CPU utilization per core, memory distribution, disk I/O, system load averages, and network throughput.
3. **Prometheus**: Time-series database scraping metrics from Node Exporter and the Auto-Trader daemon.
4. **Grafana**: Preconfigured visualization dashboard displaying operational health, system telemetry, and resource usage.

---

## Quick Start

### 1. Launch the Complete Containerized Stack

To build and run all services (Auto-Trader, Node Exporter, Prometheus, Grafana) with Docker Compose:

```bash
docker compose up -d
```

### 2. Run Telemetry Only (Native / Bare-Metal Trader)

If running the trading binary natively on the host for ultra-low latency, you can run only the monitoring containers:

```bash
docker compose up -d node-exporter prometheus grafana
```

---

## Dashboards & Access

| Service | URL | Default Credentials | Description |
|---|---|---|---|
| **Grafana** | `http://localhost:3000` | `admin` / `admin` | Telemetry & Operations Dashboard |
| **Prometheus** | `http://localhost:9090` | None | Raw metrics & query console |
| **Node Exporter** | `http://localhost:9100/metrics` | None | Host machine metrics endpoint |
| **Auto-Trader** | `http://localhost:8080/api/health` | None | Trading daemon diagnostic endpoint |

### Preconfigured Dashboards

Grafana is provisioned automatically with the **Auto-Trader Host & Operations Overview** dashboard (`autotrader-host-overview`), which includes:
- Real-time trader service and node exporter health flags
- Host uptime counter
- CPU usage percentage and per-core breakdown
- Memory distribution (Used, Cached, Buffers, Free)
- Root filesystem utilization
- System load averages (1m, 5m, 15m)
- Disk I/O read/write throughput
- Network ingress/egress bandwidth
