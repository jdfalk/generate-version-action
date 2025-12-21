#!/bin/bash
# file: src/generate_version.sh
# version: 1.0.0
# guid: 8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e

set -euo pipefail

# Get latest tag
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "Latest tag: $latest_tag"

# Parse version (strip 'v' prefix)
version="${latest_tag#v}"
IFS='.' read -r major minor patch_full <<< "$version"
patch="${patch_full%%-*}"  # Strip prerelease suffix

# Increment based on release type
release_type="${RELEASE_TYPE,,}"
case "$release_type" in
  major)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  minor)
    minor=$((minor + 1))
    patch=0
    ;;
  patch)
    patch=$((patch + 1))
    ;;
  auto)
    # Auto-detect from commit messages
    if git log "$latest_tag..HEAD" --oneline 2>/dev/null | grep -qE '^[a-f0-9]+ (feat|feature)' || true; then
      minor=$((minor + 1))
      patch=0
    else
      patch=$((patch + 1))
    fi
    ;;
esac

# Build version string
new_version="$major.$minor.$patch"

# Add prerelease suffix if provided
if [[ -n "${PRERELEASE_SUFFIX:-}" ]]; then
  # Count existing prereleases
  prerelease_count=$(git tag -l "v$new_version-$PRERELEASE_SUFFIX.*" 2>/dev/null | wc -l || echo 0)
  prerelease_num=$((prerelease_count + 1))
  new_version="$new_version-$PRERELEASE_SUFFIX.$prerelease_num"
fi

# Write outputs
{
  echo "tag=v$new_version"
  echo "version=$new_version"
  echo "major=$major"
  echo "minor=$minor"
  echo "patch=$patch"
  echo "prerelease=${PRERELEASE_SUFFIX:-}"
} >> "$GITHUB_OUTPUT"

# Summary
{
  echo "## 🏷️ Generated Version"
  echo "- **Previous:** \`$latest_tag\`"
  echo "- **New:** \`v$new_version\`"
  echo "- **Release type:** \`$release_type\`"
  echo "- **Branch:** \`$BRANCH_NAME\`"
} >> "$GITHUB_STEP_SUMMARY"

echo "✅ Version generated: v$new_version"
