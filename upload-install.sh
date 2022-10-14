#!/usr/bin/env bash

set -eu
set -o pipefail

arch="$1"

cat <<EOF
steps:
  - block: "$arch"
    key: $arch-manual-intervention
  - label: "Test on $arch"
    depends_on: $arch-manual-intervention
    concurrency_group: $arch-install
    concurrency: 1
    agents:
      mac: 1
      nix: 0
      system: $arch
    command:
      - echo 'cat /dev/null | sh <(curl -L https://nixos.org/nix/install) --daemon'
      - buildkite-agent meta-data set agent "$BUILDKITE_AGENT_NAME"
      - echo buildkite-agent meta-data set nix 1
      - ./upload-erase.sh $arch | buildkite-agent pipeline upload
EOF
