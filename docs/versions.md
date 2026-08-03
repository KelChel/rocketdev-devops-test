# Pinned component versions

Versions were checked against official upstream release information on
2026-08-02. Exact image tags are used so the same repository revision deploys
the same software versions.

| Component | Image | Selection |
| --- | --- | --- |
| Nginx | `nginx:1.30.4-alpine` | Current stable branch, not mainline |
| WordPress | `wordpress:7.0.2-php8.4-apache` | Current stable WordPress release |
| MariaDB | `mariadb:12.3.2` | Current stable LTS release |
| Prometheus | `prom/prometheus:v3.13.2` | Current stable GitHub release |
| Grafana | `grafana/grafana:13.1.1` | Current stable GitHub release |
| node_exporter | `prom/node-exporter:v1.12.1` | Current stable GitHub release |

## Development tools

| Tool | Version | Purpose |
| --- | --- | --- |
| go-jsonnet | `v0.21.0` | Reproducible dashboard rendering and formatting |

## Official sources

- [Nginx downloads](https://nginx.org/en/download.html)
- [WordPress version API](https://api.wordpress.org/core/version-check/1.7/)
- [MariaDB release API](https://downloads.mariadb.org/rest-api/mariadb/)
- [Prometheus releases](https://github.com/prometheus/prometheus/releases)
- [Grafana releases](https://github.com/grafana/grafana/releases)
- [node_exporter releases](https://github.com/prometheus/node_exporter/releases)
- [go-jsonnet releases](https://github.com/google/go-jsonnet/releases)
- [Docker Official Images](https://hub.docker.com/search?image_filter=official)
