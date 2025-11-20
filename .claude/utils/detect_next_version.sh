#!/bin/bash
# Detect next available version for a project
# Usage: detect_next_version.sh <project-slug>
# Returns: next-version-slug (e.g., "task-tracker-pwa-v2")
# Exit code: 0 on success, 1 if version limit reached

set -euo pipefail

PROJECT_SLUG="$1"
PROJECTS_DIR="docs/projects"

# Maximum version to check (prevents infinite loops)
MAX_VERSION=99

# Check if base project exists
if [ ! -d "$PROJECTS_DIR/$PROJECT_SLUG" ]; then
    echo "ERROR: Base project '$PROJECT_SLUG' does not exist" >&2
    exit 1
fi

# Function to check if version exists
version_exists() {
    local version=$1
    [ -d "$PROJECTS_DIR/$PROJECT_SLUG-$version" ]
}

# Find next available version
NEXT_VERSION=""
for i in $(seq 2 $MAX_VERSION); do
    VERSION="v$i"
    if ! version_exists "$VERSION"; then
        NEXT_VERSION="$VERSION"
        break
    fi
done

# Check if we found an available version
if [ -z "$NEXT_VERSION" ]; then
    echo "ERROR: Version limit reached (v2-v$MAX_VERSION all exist)" >&2
    exit 1
fi

# Output the next version slug
echo "$PROJECT_SLUG-$NEXT_VERSION"
exit 0
