#!/usr/bin/env bash

set -eu
set -o pipefail

arch="$1"
agent="$(buildkite-agent meta-data get agent)"

cat <<EOF
steps:
  - block: "$arch erase"
    key: $arch-erase
  - label: "Erase $arch"
    depends_on: $arch-erase
    agents:
      system: $arch
      agent: $agent
    command:
      - echo curl http://bonk
EOF
