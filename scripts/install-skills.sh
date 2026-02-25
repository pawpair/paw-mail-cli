#!/usr/bin/env bash
set -euo pipefail

# install-skills.sh — Install mail-cli skills into a project
#
# Usage:
#   ./scripts/install-skills.sh [target-dir]
#
# If target-dir is omitted, installs to .agents/skills/ in the current directory.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="${SCRIPT_DIR}/../skills"
TARGET_DIR="${1:-.agents/skills}"

if [[ ! -d "${SKILLS_SOURCE}" ]]; then
    echo "Error: Skills source directory not found: ${SKILLS_SOURCE}"
    exit 1
fi

mkdir -p "${TARGET_DIR}"

skill_count=0
for skill_dir in "${SKILLS_SOURCE}"/*/; do
    [[ -d "${skill_dir}" ]] || continue
    skill_name="$(basename "${skill_dir}")"

    # Skip if no SKILL.md
    if [[ ! -f "${skill_dir}/SKILL.md" ]]; then
        echo "Skipping ${skill_name} (no SKILL.md)"
        continue
    fi

    echo "Installing ${skill_name}..."
    cp -r "${skill_dir}" "${TARGET_DIR}/${skill_name}"
    ((skill_count++))
done

echo ""
echo "Installed ${skill_count} skill(s) to ${TARGET_DIR}/"
echo ""
echo "Installed skills:"
for skill in "${TARGET_DIR}"/*/; do
    [[ -d "${skill}" ]] || continue
    echo "  - $(basename "${skill}")"
done
