#!/usr/bin/env bash

set -eu
set -o pipefail

arch="$1"
hostname="$(buildkite-agent meta-data get hostname)"

cat <<EOF
steps:
  - block: "$arch erase"
    key: $arch-erase
  - label: "Erase $arch"
    depends_on: $arch-erase
    agents:
      system: $arch
      hostname: $hostname
    command:
      - echo curl http://bonk
EOF
