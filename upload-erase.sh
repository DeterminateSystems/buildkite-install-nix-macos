#!/usr/bin/env bash

set -eu
set -o pipefail

arch="$1"
hostname="$(buildkite-agent meta-data get hostname)"

cat <<EOF
steps:
  - block: "$arch erase"
    key: $arch-erase
  - block: "$arch really erase"
    depends_on: $arch-erase
    key: $arch-really-erase
  - label: "Erase $arch"
    depends_on: $arch-really-erase
    agents:
      system: $arch
      hostname: $hostname
    command:
      - curl http://bonk
EOF
