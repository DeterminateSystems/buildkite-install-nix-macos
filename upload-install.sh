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
      - set -x
      - if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'; fi
      - nix --help &>/dev/null || cat /dev/null | sh <(curl -L https://nixos.org/nix/install) --daemon
      - if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'; fi
      - buildkite-agent meta-data set hostname "\$(nix --extra-experimental-features 'flakes nix-command' run nixpkgs#jq -- -r '.BUILDKITE_AGENT_META_DATA_HOSTNAME' <(buildkite-agent env))"
      - ./upload-erase.sh $arch | buildkite-agent pipeline upload
      # Set this as a nix=1 machine
      # - sudo sed -i '' 's@nix=0@nix=1@' /var/lib/buildkite-agent/buildkite-agent.cfg
      # - sudo bash -xc 'sleep 1; launchctl unload /Library/LaunchDaemons/com.buildkite.buildkite-agent.plist &>/tmp/buildkite-unload.log && echo unloaded &>/tmp/buildkite-unload2.log; launchctl load /Library/LaunchDaemons/com.buildkite.buildkite-agent.plist &>/tmp/buildkite-load.log && echo loaded &>/tmp/buildkite-load2.log' &>/tmp/buildkite-restart & disown
      - sudo bash -xc 'sleep 1; echo hi &>/Users/ephemeraladmin/wat1 ; echo bye &>/Users/ephemeraladmin/wat2' &>/Users/ephemeraladmin/wat & disown
EOF
