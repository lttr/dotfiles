#!/bin/sh
set -e
DOWNLOAD_URL="https://github.com/getantibody/antibody/releases/download"
test -z "$TMPDIR" && TMPDIR="$(mktemp -d)"

last_version() {
    echo "v3.4.5"
}

download() {
  version="$(last_version)" || true
  test -z "$version" && {
    echo "Unable to get antibody version."
    exit 1
  }
  echo "Downloading antibody $version for $(uname -s)_$(uname -m)..."
  rm -f /tmp/antibody.tar.gz
  curl -s -L -o /tmp/antibody.tar.gz \
    "$DOWNLOAD_URL/$version/antibody_$(uname -s)_$(uname -m).tar.gz"
}

extract() {
  tar -xf /tmp/antibody.tar.gz -C "$TMPDIR"
}

download
extract || true
sudo mv -f "$TMPDIR"/antibody /usr/local/bin/antibody
which antibody
