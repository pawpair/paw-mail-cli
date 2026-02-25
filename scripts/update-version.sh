#!/usr/bin/env bash
set -euo pipefail

# update-version.sh — Updates version.json and regenerates all package definitions
#
# Usage:
#   ./scripts/update-version.sh <version> [release-tag]
#
# If release-tag is omitted, defaults to "v<version>".
# Expects binaries to already exist on the GitHub Release.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="pawpair/paw-mail-cli"

VERSION="${1:?Usage: update-version.sh <version> [release-tag]}"
TAG="${2:-v${VERSION}}"

BINARIES=("mail-cli" "mail-tui" "mail")
ARCHES=("x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin")

DOWNLOAD_BASE="https://paw-mail-releases.pawpair.pet/${TAG}"

echo "Updating to version ${VERSION} (tag: ${TAG})"
echo "Download base: ${DOWNLOAD_BASE}"
echo ""

# Build version.json in memory
json_binaries=""
for bin in "${BINARIES[@]}"; do
    json_arches=""
    for arch in "${ARCHES[@]}"; do
        url="${DOWNLOAD_BASE}/${bin}-${arch}.tar.gz"
        echo "Fetching SHA-256 for ${bin}-${arch}..."

        sha256=$(curl -fSL "${url}" 2>/dev/null | sha256sum | awk '{print $1}')
        if [[ -z "${sha256}" || "${sha256}" == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]]; then
            echo "  ERROR: Failed to download or empty file: ${url}"
            exit 1
        fi
        echo "  ${sha256}"

        entry="\"${arch}\": { \"sha256\": \"${sha256}\" }"
        if [[ -n "${json_arches}" ]]; then
            json_arches="${json_arches}, ${entry}"
        else
            json_arches="${entry}"
        fi
    done

    bin_entry="\"${bin}\": { ${json_arches} }"
    if [[ -n "${json_binaries}" ]]; then
        json_binaries="${json_binaries}, ${bin_entry}"
    else
        json_binaries="${bin_entry}"
    fi
done

# Write version.json (use jq to format if available, else raw)
raw_json="{ \"version\": \"${VERSION}\", \"download_base\": \"${DOWNLOAD_BASE}\", \"binaries\": { ${json_binaries} } }"
if command -v jq &>/dev/null; then
    echo "${raw_json}" | jq '.' > "${REPO_ROOT}/version.json"
else
    echo "${raw_json}" > "${REPO_ROOT}/version.json"
fi
echo ""
echo "Updated version.json"

# ── Regenerate Nix flake ──────────────────────────────────────────────
echo "Regenerating nix/flake.nix..."

generate_nix_fetch() {
    local bin="$1" arch="$2" sha256="$3"
    local nix_system
    case "${arch}" in
        x86_64-linux)   nix_system="x86_64-linux" ;;
        aarch64-linux)  nix_system="aarch64-linux" ;;
        x86_64-darwin)  nix_system="x86_64-darwin" ;;
        aarch64-darwin) nix_system="aarch64-darwin" ;;
    esac
    echo "              \"${nix_system}\" = { url = \"${DOWNLOAD_BASE}/${bin}-${arch}.tar.gz\"; sha256 = \"${sha256}\"; };"
}

# We regenerate the full flake from template inline — see nix/flake.nix

# ── Regenerate AUR PKGBUILDs ──────────────────────────────────────────
echo "Regenerating AUR PKGBUILDs..."

for bin in "${BINARIES[@]}"; do
    pkgname="${bin}-bin"
    pkgbuild_dir="${REPO_ROOT}/aur/${pkgname}"
    pkgbuild="${pkgbuild_dir}/PKGBUILD"

    # Read current sha256 values from version.json
    x86_sha=$(echo "${raw_json}" | jq -r ".binaries.\"${bin}\".\"x86_64-linux\".sha256" 2>/dev/null || echo "SKIP")
    arm_sha=$(echo "${raw_json}" | jq -r ".binaries.\"${bin}\".\"aarch64-linux\".sha256" 2>/dev/null || echo "SKIP")

    sed -i "s/^pkgver=.*/pkgver=${VERSION}/" "${pkgbuild}"
    sed -i "s/^pkgrel=.*/pkgrel=1/" "${pkgbuild}"
    sed -i "s|^sha256sums_x86_64=.*|sha256sums_x86_64=('${x86_sha}')|" "${pkgbuild}"
    sed -i "s|^sha256sums_aarch64=.*|sha256sums_aarch64=('${arm_sha}')|" "${pkgbuild}"

    echo "  Updated ${pkgbuild}"
done

# ── Regenerate Homebrew formulas ──────────────────────────────────────
echo "Regenerating Homebrew formulas..."

for bin in "${BINARIES[@]}"; do
    formula="${REPO_ROOT}/homebrew/Formula/${bin}.rb"

    x86_linux_sha=$(echo "${raw_json}" | jq -r ".binaries.\"${bin}\".\"x86_64-linux\".sha256" 2>/dev/null)
    arm_linux_sha=$(echo "${raw_json}" | jq -r ".binaries.\"${bin}\".\"aarch64-linux\".sha256" 2>/dev/null)
    x86_darwin_sha=$(echo "${raw_json}" | jq -r ".binaries.\"${bin}\".\"x86_64-darwin\".sha256" 2>/dev/null)
    arm_darwin_sha=$(echo "${raw_json}" | jq -r ".binaries.\"${bin}\".\"aarch64-darwin\".sha256" 2>/dev/null)

    sed -i "s|version \".*\"|version \"${VERSION}\"|" "${formula}"

    # Update sha256 values — each formula has labeled comments for matching
    sed -i "/# x86_64-linux/{n;s/sha256 \".*\"/sha256 \"${x86_linux_sha}\"/;}" "${formula}"
    sed -i "/# aarch64-linux/{n;s/sha256 \".*\"/sha256 \"${arm_linux_sha}\"/;}" "${formula}"
    sed -i "/# x86_64-darwin/{n;s/sha256 \".*\"/sha256 \"${x86_darwin_sha}\"/;}" "${formula}"
    sed -i "/# aarch64-darwin/{n;s/sha256 \".*\"/sha256 \"${arm_darwin_sha}\"/;}" "${formula}"

    echo "  Updated ${formula}"
done

echo ""
echo "All package definitions updated to v${VERSION}."
echo "Review changes with: git diff"
