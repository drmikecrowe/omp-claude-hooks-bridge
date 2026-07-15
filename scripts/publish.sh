#!/usr/bin/env bash
# publish.sh — publish @drmikecrowe/omp-claude-hooks-bridge to npm with the
# publishing token injected from 1Password (op://Private/NPMJS_PUBLISHING_TOKEN)
# via varlock. Mirrors the ~/.config/dorothy/commands/*-with-env pattern.
#
# Usage:
#   bash scripts/publish.sh              # real publish
#   bash scripts/publish.sh --dry-run    # validate without publishing
#   npm run release / npm run release:dry
set -euo pipefail

# Run from the repo root regardless of where the script is invoked.
cd "$(dirname "${BASH_SOURCE[0]}")/.."

command -v op >/dev/null || { echo "ERROR: op (1Password CLI) required" >&2; exit 1; }
command -v varlock >/dev/null || { echo "ERROR: varlock not found on PATH" >&2; exit 1; }
[ -f ".env.schema" ] || { echo "ERROR: .env.schema not found in $(pwd)" >&2; exit 1; }

# varlock resolves NPM_TOKEN from 1Password into the environment; .npmrc reads it
# as //registry.npmjs.org/:_authToken=${NPM_TOKEN}. --no-redact-stdout keeps npm's
# tarball/version output intact instead of masking it.
exec varlock run --no-redact-stdout -- npm publish "$@"
