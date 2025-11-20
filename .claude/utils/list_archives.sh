#!/bin/bash
# List all archived versions of a project
# Usage: list_archives.sh <project-slug>
# Example: list_archives.sh task-tracker-pwa

set -euo pipefail

PROJECT_SLUG="$1"
PROJECT_DIR="docs/projects/$PROJECT_SLUG"
ARCHIVE_BASE="$PROJECT_DIR/.archive"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📚 Archives for: $PROJECT_SLUG${NC}"
echo "═══════════════════════════════════════"

# Check if project exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Project not found: $PROJECT_DIR"
    exit 1
fi

# Check if archives exist
if [ ! -d "$ARCHIVE_BASE" ]; then
    echo "No archives found"
    exit 0
fi

# List all archives (sorted by timestamp)
ARCHIVE_COUNT=0
for archive_dir in "$ARCHIVE_BASE"/*/ ; do
    if [ -d "$archive_dir" ]; then
        TIMESTAMP=$(basename "$archive_dir")

        # Skip backup directories
        if [[ "$TIMESTAMP" == backup-* ]]; then
            continue
        fi

        ARCHIVE_COUNT=$((ARCHIVE_COUNT + 1))

        # Count files in archive
        FILE_COUNT=$(find "$archive_dir" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

        # Format timestamp for display
        DATE_DISPLAY=$(echo "$TIMESTAMP" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)-\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')

        echo ""
        echo -e "${GREEN}📦 Archive: $TIMESTAMP${NC}"
        echo "   Date: $DATE_DISPLAY"
        echo "   Files: $FILE_COUNT"
        echo "   Location: $archive_dir"

        # Show metadata if exists
        if [ -f "$archive_dir/archive_metadata.json" ]; then
            REASON=$(python3 -c "import json; print(json.load(open('$archive_dir/archive_metadata.json')).get('reason', 'N/A'))" 2>/dev/null || echo "N/A")
            echo "   Reason: $REASON"
        fi

        echo "   Restore: .claude/utils/restore_archive.sh $PROJECT_SLUG $TIMESTAMP"
    fi
done

echo ""
echo "═══════════════════════════════════════"
if [ $ARCHIVE_COUNT -eq 0 ]; then
    echo "No archives found"
else
    echo "Total archives: $ARCHIVE_COUNT"
fi
echo ""
