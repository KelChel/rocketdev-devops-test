# Pinned component versions

Versions were checked against official upstream release information on
2026-08-03. Exact image tags are used so the same repository revision deploys
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
| Ansible Core | `2.19.11` | Host provisioning and deployment orchestration |
| community.docker | `4.8.7` | Idempotent Docker Compose v2 deployment module |
| actions/checkout | `v7` | Repository checkout in CI jobs |
| actions/setup-go | `v7` | Go 1.24 toolchain setup for Jsonnet validation |
| actions/setup-python | `v7` | Python 3.12 setup for dashboard and Ansible validation |

## Official sources

- [Nginx downloads](https://nginx.org/en/download.html)
- [WordPress version API](https://api.wordpress.org/core/version-check/1.7/)
- [MariaDB release API](https://downloads.mariadb.org/rest-api/mariadb/)
- [Prometheus releases](https://github.com/prometheus/prometheus/releases)
- [Grafana releases](https://github.com/grafana/grafana/releases)
- [node_exporter releases](https://github.com/prometheus/node_exporter/releases)
- [go-jsonnet releases](https://github.com/google/go-jsonnet/releases)
- [Ansible Core releases](https://pypi.org/project/ansible-core/)
- [community.docker collection](https://galaxy.ansible.com/ui/repo/published/community/docker/)
- [actions/checkout](https://github.com/actions/checkout)
- [actions/setup-go](https://github.com/actions/setup-go)
- [actions/setup-python](https://github.com/actions/setup-python)
- [Docker Official Images](https://hub.docker.com/search?image_filter=official)
