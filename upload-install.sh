#!/usr/bin/env bash

set -eu
set -o pipefail

arch="$1"

cat <<EOF
steps:
  - label: "Test on $arch"
    concurrency_group: $arch-install
    concurrency: 1
    agents:
      mac: 1
      nix: 0
      system: $arch
    command:
      - cat /dev/null | sh <(curl -L https://nixos.org/nix/install) --daemon
      - if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'; fi

      # Run whatever test / verification stuff that depends on Nix here
      - nix --extra-experimental-features 'flakes nix-command' run nixpkgs#hello

      # The machine that accepted this job will be erased after the job
      # finishes. We have to do this in one step in order to +-guarantee that we
      # don't try to reuse this machine as a "fresh" machine without Nix
      # installed.
EOF
