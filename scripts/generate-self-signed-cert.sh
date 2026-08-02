#!/usr/bin/env bash

set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cert_dir="${project_dir}/nginx/certs"
cert_file="${cert_dir}/site.local.crt"
key_file="${cert_dir}/site.local.key"

if [[ -e "${cert_file}" || -e "${key_file}" ]]; then
    echo "Certificate files already exist in ${cert_dir}." >&2
    echo "Remove them explicitly before generating a replacement." >&2
    exit 1
fi

mkdir -p "${cert_dir}"
umask 077

openssl req \
    -x509 \
    -nodes \
    -newkey rsa:4096 \
    -sha256 \
    -days 365 \
    -keyout "${key_file}" \
    -out "${cert_file}" \
    -subj "/C=RU/O=RocketDev Test/CN=site.local" \
    -addext "subjectAltName=DNS:site.local"

chmod 600 "${key_file}"
chmod 644 "${cert_file}"

echo "Created ${cert_file} and ${key_file}."
