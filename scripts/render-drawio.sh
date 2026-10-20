#!/usr/bin/env bash
# Renders every drawio diagram in the repository to PNG next to its source.
# Skips _-prefixed files (shared element definitions, no standalone render),
# matching the render-puml.sh convention.
#
# Uses drawio CLI if available; otherwise falls back to a container image
# (rlespinasse/drawio-export: bundled drawio + Xvfb), via docker or podman.
set -euo pipefail

die() {
  echo "error: $*" >&2
  exit 1
}

ENGINE=""
if command -v drawio >/dev/null 2>&1; then
  render() {
    local file=$1
    local out="${file%.drawio}.png"
    drawio -x -f png -s 2 --border 20 -o "$out" "$file"
  }
elif command -v docker >/dev/null 2>&1 || command -v podman >/dev/null 2>&1; then
  command -v docker >/dev/null 2>&1 && ENGINE=docker || ENGINE=podman
  render() {
    local file=$1
    $ENGINE run --rm \
      -v "$PWD:/data" -w /data \
      rlespinasse/drawio-export:latest \
      -f png -s 2 --border 20 --remove-page-suffix --output . "$file"
  }
else
  die "neither drawio nor docker/podman is installed"
fi

found=0

# shellcheck disable=SC2012  # -print0/newline NUL handling keeps spaces in filenames safe
while IFS= read -r -d '' file; do
  found=1
  echo "Rendering $file"
  render "$file"
done < <(find . -type f -name '*.drawio' ! -name '_*.drawio' ! -path './.git/*' -print0)

[ "$found" -eq 1 ] || die "no drawio files found"
