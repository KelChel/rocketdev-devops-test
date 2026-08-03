# RocketDev DevOps test task

[![CI](https://github.com/KelChel/rocketdev-devops-test/actions/workflows/ci.yml/badge.svg)](https://github.com/KelChel/rocketdev-devops-test/actions/workflows/ci.yml)

Reproducible deployment of WordPress, MariaDB, Nginx, Prometheus, Grafana and
node_exporter on Ubuntu using Docker Compose and Ansible.

## Project status

The implementation is complete and verified on Ubuntu 24.04. Docker Compose,
Prometheus configuration, Grafana provisioning, Nginx routing, Ansible
idempotency and the complete container startup are covered by automated or
recorded acceptance checks.

## Target environment

- Ubuntu Server 24.04 LTS
- Docker Engine with Docker Compose v2
- 2 CPU, 4 GB RAM and 20 GB free disk space recommended
- TCP ports 22, 80 and 443

## Endpoints

| Address | Purpose |
| --- | --- |
| `http://site.local` | Redirect to HTTPS |
| `https://site.local` | WordPress through Nginx |
| `http://metrics.local` | Grafana through Nginx |

## Quick start with Docker Compose

The manual path starts the application stack on an existing Linux Docker host.
Use the Ansible deployment below for full host provisioning, including Docker,
Fail2ban and nftables.

```shell
git clone https://github.com/KelChel/rocketdev-devops-test.git
cd rocketdev-devops-test

cp .env.example .env
chmod 600 .env
# Replace every CHANGE_ME value and set WP_ADMIN_ALLOWED_CIDR.

bash scripts/generate-self-signed-cert.sh
docker compose config --quiet
docker compose up -d --wait --wait-timeout 240
docker compose ps
```

Use strong unique values in `.env`. For Ansible compatibility, passwords must
contain at least 24 letters, digits, underscores or hyphens. Set
`WP_ADMIN_ALLOWED_CIDR` to the public administrator address with a `/32` mask.

Resolve the test names to the server address using DNS or the client hosts file:

```text
<server-ip> site.local metrics.local
```

The hosts file is `/etc/hosts` on Linux and macOS, or
`C:\Windows\System32\drivers\etc\hosts` on Windows. Open
`https://site.local` to complete WordPress setup and `http://metrics.local` for
Grafana. A browser warning is expected because the test certificate is
self-signed.

Stop containers without deleting persistent data:

```shell
docker compose down
```

Named volumes keep MariaDB, WordPress, Prometheus and Grafana data. Add
`--volumes` only when an explicit destructive reset is intended.

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

The dashboard toolchain runs in a POSIX shell and requires Make, Go and Python 3.
The `make install` command installs pinned Jsonnet tools locally under `.tools/bin`.
On Windows, run these commands from WSL or another Linux environment.

```shell
make install          # install jsonnet and jsonnetfmt into .tools/bin
make fmt              # format Jsonnet sources
make render           # regenerate dashboard JSON
make validate         # render and validate dashboard JSON
make check            # run formatting, stale-output and validation checks
```

## Ansible deployment

Ansible runs from a Linux control node; Windows users can use WSL 2. The
playbook targets Debian or Ubuntu and separates deployment into three roles:

- `docker` installs deployment prerequisites and Docker Compose when missing;
- `application` manages the repository, protected `.env`, TLS certificate and
  Compose project;
- `fail2ban` installs nftables and Fail2ban, applies the SSH policy and verifies
  that the jail is operational.

Create local inventory and Vault files from the committed examples. The real
`inventory/hosts.yml`, encrypted `vault.yml` and downloaded collections are
ignored by Git.

```shell
cd ansible
python3 -m venv ~/.venvs/rocketdev-ansible
source ~/.venvs/rocketdev-ansible/bin/activate
python -m pip install -r requirements.txt
ansible-galaxy collection install -r requirements.yml -p .collections

cp inventory/hosts.example.yml inventory/hosts.yml
export ANSIBLE_CONFIG="$PWD/ansible.cfg"
ansible-vault create vault.yml

ansible-inventory --graph
ansible rocketdev -m ansible.builtin.ping

ansible-playbook site.yml --check --diff -e @vault.yml --ask-vault-pass
ansible-playbook site.yml --diff -e @vault.yml --ask-vault-pass
```

The first real run converges the host to the declared state. A second run with
the same inputs must complete with `changed=0`; this was verified against the
deployment VPS. Secret-bearing template output is protected with `no_log`.

## Continuous integration

The `.github/workflows/ci.yml` workflow runs for pull requests, pushes to
`main` and manual dispatches. It uses two dependent jobs:

- `validate` checks Jsonnet formatting and generated dashboards, the Docker
  Compose model, shell syntax and the Ansible playbook syntax;
- `integration` generates an ephemeral certificate, validates Prometheus,
  starts the complete Compose project and checks services, Nginx routes,
  Prometheus targets and the provisioned Grafana dashboard.

The integration job uses test-only credentials on an isolated GitHub runner;
it does not connect to the deployment VPS or read production secrets. Compose
logs are printed on failure, and containers, networks and volumes are removed
with an `if: always()` cleanup step.

## Key design and security decisions

- Only Nginx publishes web ports, which keeps a single controlled entry point
  and reduces the externally reachable attack surface.
- Database and monitoring traffic use internal Docker networks, so MariaDB,
  Prometheus and node_exporter are not directly reachable from the host.
- Nginx, Prometheus and Grafana configuration is mounted read-only to prevent
  containers from changing the declared host configuration.
- Named volumes hold mutable application data so container replacement does
  not remove MariaDB, WordPress, Prometheus or Grafana state.
- Image versions are pinned instead of using floating `latest` tags to make
  deployments and CI runs reproducible.
- A generated self-signed certificate is sufficient for the isolated test
  environment; its private key and all deployment secrets stay outside Git.
- WordPress administration endpoints are restricted by source CIDR, while
  Fail2ban runs on the host because it protects the host SSH service.

See [docs/architecture.md](docs/architecture.md) for the detailed design.

Pinned component versions and their official sources are documented in
[docs/versions.md](docs/versions.md).
