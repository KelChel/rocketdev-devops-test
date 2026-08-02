# RocketDev DevOps test task

Reproducible deployment of WordPress, MariaDB, Nginx, Prometheus, Grafana and
node_exporter on Ubuntu using Docker Compose and Ansible.

## Project status

The repository contains the container topology and supporting deployment
configuration. See the implementation checklist below for verification status.

## Target environment

- Ubuntu Server 24.04 LTS
- Docker Engine with Docker Compose v2
- 2 CPU, 4 GB RAM and 20 GB free disk space recommended
- TCP ports 22, 80 and 443

## Planned endpoints

| Address | Purpose |
| --- | --- |
| `http://site.local` | Redirect to HTTPS |
| `https://site.local` | WordPress through Nginx |
| `http://metrics.local` | Grafana through Nginx |

## Repository layout

```text
.
|-- ansible/                 # Automated host provisioning and deployment
|-- docs/                    # Architecture, decisions and time log
|-- grafana/                 # Datasource and dashboard provisioning
|-- nginx/                   # Reverse proxy configuration
|-- prometheus/              # Prometheus configuration
|-- .github/workflows/       # CI checks and smoke tests
|-- .env.example             # Safe environment variable template
`-- compose.yaml             # Container topology, networks and volumes
```

## Security rules

- Secrets and generated private keys are not committed to Git.
- Only Nginx publishes web ports; application and monitoring services use
  private Docker networks.
- WordPress administration endpoints are restricted by source IP.
- SSH brute-force protection is configured on the host with fail2ban.

See [docs/architecture.md](docs/architecture.md) for the detailed design.

Pinned component versions and their official sources are documented in
[docs/versions.md](docs/versions.md).
