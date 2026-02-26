#!/usr/bin/env bash
set -euo pipefail

# build-deb.sh — Builds .deb packages from version.json
#
# Usage:
#   ./deb/build-deb.sh [output-dir]
#
# Reads version.json for version and SHA-256 hashes.
# Downloads binaries and packages them as .deb files.
# Supports amd64 (x86_64) and arm64 (aarch64).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${1:-${REPO_ROOT}/dist}"
REPO="pawpair/paw-mail-cli"

VERSION=$(jq -r '.version' "${REPO_ROOT}/version.json")
TAG="v${VERSION}"
DOWNLOAD_BASE="https://paw-mail-releases.pawpair.pet/${TAG}"

declare -A ARCH_MAP=(
    ["x86_64-linux"]="amd64"
    ["aarch64-linux"]="arm64"
)

declare -A DESCRIPTIONS=(
    ["mail-cli"]="Command-line interface for the Paw Mail email client"
    ["mail-tui"]="Terminal UI for the Paw Mail email client"
    ["mail"]="Paw Mail email client — unified CLI and TUI"
)

BINARIES=("mail-cli" "mail-tui" "mail")

mkdir -p "${OUTPUT_DIR}"

for bin in "${BINARIES[@]}"; do
    for arch in x86_64-linux aarch64-linux; do
        deb_arch="${ARCH_MAP[${arch}]}"
        deb_name="${bin}_${VERSION}_${deb_arch}"
        work_dir=$(mktemp -d)
        trap "rm -rf ${work_dir}" EXIT

        echo "Building ${deb_name}.deb..."

        # Create directory structure
        mkdir -p "${work_dir}/DEBIAN"
        mkdir -p "${work_dir}/usr/bin"

        # Download and extract binary
        url="${DOWNLOAD_BASE}/${bin}-${arch}.tar.gz"
        curl -fSL "${url}" | tar xz -C "${work_dir}/usr/bin/"
        chmod 755 "${work_dir}/usr/bin/${bin}"

        # Generate control file
        sed \
            -e "s/__PACKAGE__/${bin}/" \
            -e "s/__VERSION__/${VERSION}/" \
            -e "s/__ARCH__/${deb_arch}/" \
            -e "s/__DESCRIPTION__/${DESCRIPTIONS[${bin}]}/" \
            "${SCRIPT_DIR}/control.template" > "${work_dir}/DEBIAN/control"

        # Build .deb
        dpkg-deb --build --root-owner-group "${work_dir}" "${OUTPUT_DIR}/${deb_name}.deb"

        rm -rf "${work_dir}"
        trap - EXIT

        echo "  Created ${OUTPUT_DIR}/${deb_name}.deb"
    done
done

echo ""
echo "All .deb packages built in ${OUTPUT_DIR}/"
ls -lh "${OUTPUT_DIR}"/*.deb
