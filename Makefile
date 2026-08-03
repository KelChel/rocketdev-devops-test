SHELL := /bin/sh

GO_JSONNET_VERSION := v0.21.0
TOOLS_DIR := $(CURDIR)/.tools
GOBIN := $(TOOLS_DIR)/bin
JSONNET := $(GOBIN)/jsonnet
JSONNETFMT := $(GOBIN)/jsonnetfmt
PYTHON ?= python3

DASHBOARD_SOURCES := $(wildcard grafana/jsonnet/dashboards/*.jsonnet)
DASHBOARD_OUTPUT_DIR := grafana/dashboards

.DEFAULT_GOAL := help
.NOTPARALLEL:

.PHONY: help install deps ensure-tools fmt fmt-check render validate validate-json check-generated check clean

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*## "; printf "Usage: make <target>\n\nTargets:\n"} /^[a-zA-Z_-]+:.*## / {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install pinned Jsonnet tools into .tools/bin
	@command -v go >/dev/null 2>&1 || { echo "error: Go is required (https://go.dev/doc/install)" >&2; exit 1; }
	@mkdir -p "$(GOBIN)"
	GOBIN="$(GOBIN)" go install github.com/google/go-jsonnet/cmd/jsonnet@$(GO_JSONNET_VERSION)
	GOBIN="$(GOBIN)" go install github.com/google/go-jsonnet/cmd/jsonnetfmt@$(GO_JSONNET_VERSION)

deps: install ## Alias for dependency installation

ensure-tools:
	@test -x "$(JSONNET)" && test -x "$(JSONNETFMT)" || { echo "error: Jsonnet tools are missing; run 'make install'" >&2; exit 1; }

fmt: ensure-tools ## Format all Jsonnet sources in place
	@find grafana/jsonnet -type f \( -name '*.jsonnet' -o -name '*.libsonnet' \) -exec "$(JSONNETFMT)" -i {} \;

fmt-check: ensure-tools ## Check Jsonnet formatting without changing files
	@find grafana/jsonnet -type f \( -name '*.jsonnet' -o -name '*.libsonnet' \) -exec "$(JSONNETFMT)" --test {} \;

render: ensure-tools ## Render Jsonnet into Grafana dashboard JSON
	@test -n "$(strip $(DASHBOARD_SOURCES))" || { echo "error: no dashboard Jsonnet sources found" >&2; exit 1; }
	@set -eu; for source in $(DASHBOARD_SOURCES); do \
	  name="$$(basename "$$source" .jsonnet)"; \
	  output="$(DASHBOARD_OUTPUT_DIR)/$$name.json"; \
	  tmp="$$output.tmp"; trap 'rm -f "$$tmp"' EXIT; \
	  "$(JSONNET)" --indent 2 -J grafana/jsonnet "$$source" > "$$tmp"; \
	  mv "$$tmp" "$$output"; trap - EXIT; \
	done

validate: render validate-json ## Render and validate Grafana dashboards

validate-json: ## Validate generated dashboard JSON structure and layout
	@command -v "$(PYTHON)" >/dev/null 2>&1 || { echo "error: $(PYTHON) is required" >&2; exit 1; }
	@"$(PYTHON)" scripts/validate_dashboards.py grafana/dashboards

check-generated: ensure-tools ## Check that committed JSON matches Jsonnet sources
	@test -n "$(strip $(DASHBOARD_SOURCES))" || { echo "error: no dashboard Jsonnet sources found" >&2; exit 1; }
	@set -eu; status=0; for source in $(DASHBOARD_SOURCES); do \
	  name="$$(basename "$$source" .jsonnet)"; \
	  output="$(DASHBOARD_OUTPUT_DIR)/$$name.json"; \
	  tmp="$$(mktemp)"; trap 'rm -f "$$tmp"' EXIT; \
	  "$(JSONNET)" --indent 2 -J grafana/jsonnet "$$source" > "$$tmp"; \
	  diff -u "$$output" "$$tmp" || status=1; \
	  rm -f "$$tmp"; trap - EXIT; \
	done; exit $$status

check: fmt-check check-generated validate-json ## Run formatting, generation and dashboard validation checks

clean: ## Remove locally installed Jsonnet tools
	@rm -rf "$(TOOLS_DIR)"
