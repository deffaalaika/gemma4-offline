#!/bin/bash
# Download gemma4:12b parts from this repo's GitHub Release, verify,
# join, unzip and install into the local Ollama (no ollama.com access needed).
#
# Usage:
#   bash get-gemma4.sh            # download parts into ./gemma4-download, then install
#   bash get-gemma4.sh <dir>      # use parts already downloaded into <dir>
set -euo pipefail

REPO="deffaalaika/gemma4-offline"
TAG="gemma4-12b"
BASE="https://github.com/$REPO/releases/download/$TAG"
PARTS="aa ab ac ad ae"
ZIP="gemma4-12b-offline.zip"

DIR="${1:-$PWD/gemma4-download}"
mkdir -p "$DIR"
cd "$DIR"

info() { printf '\033[36m==> %s\033[0m\n' "$*"; }
die()  { printf '\033[31m%s\033[0m\n' "$*"; exit 1; }

# 1. Checksums file
if [ ! -f SHA256SUMS ]; then
  info "Downloading SHA256SUMS"
  curl -fL --retry 5 -o SHA256SUMS "$BASE/SHA256SUMS"
fi

# 2. Parts (resumable; skips parts that already verify)
for p in $PARTS; do
  f="$ZIP.part-$p"
  want="$(grep " $f\$" SHA256SUMS | awk '{print $1}')"
  [ -n "$want" ] || die "No checksum for $f in SHA256SUMS"
  if [ -f "$f" ] && [ "$(shasum -a 256 "$f" | awk '{print $1}')" = "$want" ]; then
    echo "   ok   $f (already downloaded)"
    continue
  fi
  info "Downloading $f"
  for attempt in 1 2 3 4 5; do
    curl -fL --retry 5 --retry-delay 3 -C - -o "$f" "$BASE/$f" && break
    echo "   retry $attempt..."; sleep 3
  done
  got="$(shasum -a 256 "$f" | awk '{print $1}')"
  if [ "$got" != "$want" ]; then
    rm -f "$f"
    die "Checksum mismatch for $f. It was deleted; run this script again."
  fi
  echo "   ok   $f"
done

# 3. Join
info "Joining parts into $ZIP"
cat $(for p in $PARTS; do printf '%s ' "$ZIP.part-$p"; done) > "$ZIP"
want="$(grep " $ZIP\$" SHA256SUMS | awk '{print $1}')"
[ "$(shasum -a 256 "$ZIP" | awk '{print $1}')" = "$want" ] || die "Joined zip checksum mismatch."
echo "   ok   $ZIP"

# 4. Unzip + install
info "Unzipping"
rm -rf gemma4-12b-offline
unzip -q "$ZIP"
bash gemma4-12b-offline/install.sh

echo
echo "Done. To free ~15 GB you can now delete: $DIR"
