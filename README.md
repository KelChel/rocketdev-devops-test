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

## Grafana dashboards

Grafana dashboards are authored in Jsonnet under `grafana/jsonnet`. The reusable
core library contains dashboard and panel constructors, while components contain
Prometheus queries, standard panels and template variables. Rendered JSON stays
under `grafana/dashboards` because that directory is mounted into Grafana. Each
`grafana/jsonnet/dashboards/*.jsonnet` source is rendered to a same-named JSON
file, so additional dashboards do not require Makefile changes.

```text
grafana/jsonnet/
|-- dashboards/              # Dashboard entry points
`-- lib/
    |-- core.libsonnet       # Dashboard, panel, target and grid constructors
    |-- constants.libsonnet  # Datasource, units, tags and thresholds
    `-- components/          # Reusable panels, PromQL queries and variables
```

Go is the only bootstrap prerequisite for the pinned local Jsonnet toolchain.

```shell
make install          # install jsonnet and jsonnetfmt into .tools/bin
make fmt              # format Jsonnet sources
make render           # regenerate dashboard JSON
make validate         # render and validate dashboard JSON
make check            # run formatting, stale-output and validation checks
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
