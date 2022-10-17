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
      - if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'; fi
      - nix --help || cat /dev/null | sh <(curl -L https://nixos.org/nix/install) --daemon
      - if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'; fi
      - buildkite-agent meta-data set hostname "\$(nix --extra-experimental-features 'flakes nix-command' run nixpkgs#jq -- -r '.BUILDKITE_AGENT_META_DATA_HOSTNAME' <(buildkite-agent env))"
      # - echo buildkite-agent meta-data set nix 1
      - ./upload-erase.sh $arch | buildkite-agent pipeline upload
EOF
