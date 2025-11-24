#!/bin/bash
#
# Production Cleanup Script - In-Place Archive
# Cleans current project directory by archiving test artifacts and deleting duplicates
#
# Usage: ./production_cleanup_inplace.sh
# Run from project root or it will detect automatically
#

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect project root (look for .claude directory)
if [ -d ".claude" ]; then
    PROJECT_ROOT="$(pwd)"
elif [ -d "../../.claude" ]; then
    PROJECT_ROOT="$( cd ../.. && pwd )"
else
    echo -e "${RED}Error: Cannot find .claude directory. Please run from project root.${NC}"
    exit 1
fi

cd "$PROJECT_ROOT"

echo -e "${GREEN}=== RTC Mobile Production Cleanup - In-Place Archive ===${NC}"
echo ""
echo "Project Root: $PROJECT_ROOT"
echo "Current Size: $(du -sh . | awk '{print $1}')"
echo ""

# Safety checks
echo -e "${YELLOW}Pre-flight Safety Checks:${NC}"

# Check git status
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not a git repository. Git is required for safety.${NC}"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Warning: You have uncommitted changes!${NC}"
    echo "Please commit or stash your changes before cleanup."
    git status --short
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled."
        exit 0
    fi
fi

echo -e "${GREEN}✓ Git repository detected${NC}"
echo -e "${GREEN}✓ Safety checks passed${NC}"
echo ""

# Show what will be done
echo -e "${BLUE}=== Cleanup Plan ===${NC}"
echo ""
echo "Will ARCHIVE (moved to timestamped directory):"
echo "  - archive/ (464KB - complete git duplicates)"
echo "  - docs/implementation-backups/ (504KB - git commits)"
echo "  - .claude/skills/_archived/ (304KB - superseded)"
echo "  - 18 test docs (keep top 3)"
echo "  - 60+ research sessions (keep 10)"
echo "  - Analysis docs (development history)"
echo ""
echo "Will DELETE (regenerated at runtime):"
echo "  - hooks_logs/*.jsonl"
echo ""
echo "Will DELETE (deprecated):"
echo "  - .claude/settings.local.json"
echo "  - .claude/agents/test-spawner.md"
echo "  - .claude/agents/research-subagent.md"
echo "  - .claude/skills/test-skill-nesting/"
echo ""
echo "Expected size after cleanup: ~1.5-2MB"
echo ""

# Confirm
read -p "Proceed with cleanup? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Create archive directory
ARCHIVE_DIR="_ARCHIVED_$(date +%Y%m%d_%H%M%S)"
echo ""
echo -e "${YELLOW}[1/9] Creating archive directory: $ARCHIVE_DIR${NC}"
mkdir -p "$ARCHIVE_DIR"

# Move archives
echo -e "${YELLOW}[2/9] Archiving duplicate backups...${NC}"
if [ -d "archive" ]; then
    mv archive "$ARCHIVE_DIR/"
    echo "  ✓ Moved archive/ (git duplicates)"
fi

if [ -d "docs/implementation-backups" ]; then
    mv docs/implementation-backups "$ARCHIVE_DIR/"
    echo "  ✓ Moved docs/implementation-backups/ (git commits)"
fi

if [ -d ".claude/skills/_archived" ]; then
    mv .claude/skills/_archived "$ARCHIVE_DIR/"
    echo "  ✓ Moved .claude/skills/_archived/ (superseded)"
fi

# Archive test docs (keep top 3)
echo -e "${YELLOW}[3/9] Archiving test documentation (keeping top 3)...${NC}"
mkdir -p "$ARCHIVE_DIR/hook-migration-tests"
if [ -d "docs/hook-migration-tests" ]; then
    # Move all test docs
    mv docs/hook-migration-tests/* "$ARCHIVE_DIR/hook-migration-tests/" 2>/dev/null || true

    # Restore top 3
    mv "$ARCHIVE_DIR/hook-migration-tests/HONEST_ASSESSMENT_PRE_PHASE7.md" docs/hook-migration-tests/ 2>/dev/null && echo "  ✓ Kept HONEST_ASSESSMENT"
    mv "$ARCHIVE_DIR/hook-migration-tests/PHASE6_PRODUCTION_READINESS.md" docs/hook-migration-tests/ 2>/dev/null && echo "  ✓ Kept PRODUCTION_READINESS"
    mv "$ARCHIVE_DIR/hook-migration-tests/PHASE6_TESTING_COMPLETE.md" docs/hook-migration-tests/ 2>/dev/null && echo "  ✓ Kept TESTING_COMPLETE"

    # Restore deployment analysis docs
    mv "$ARCHIVE_DIR/hook-migration-tests/PRODUCTION_DEPLOYMENT_EXECUTIVE_SUMMARY.md" docs/hook-migration-tests/ 2>/dev/null && echo "  ✓ Kept EXECUTIVE_SUMMARY"
    mv "$ARCHIVE_DIR/hook-migration-tests/PRODUCTION_DEPLOYMENT_ANALYSIS.md" docs/hook-migration-tests/ 2>/dev/null && echo "  ✓ Kept DEPLOYMENT_ANALYSIS"

    # Restore deployment scripts
    mv "$ARCHIVE_DIR/hook-migration-tests/production_deploy_standard.sh" docs/hook-migration-tests/ 2>/dev/null && echo "  ✓ Kept production_deploy_standard.sh"
    mv "$ARCHIVE_DIR/hook-migration-tests/production_cleanup_inplace.sh" docs/hook-migration-tests/ 2>/dev/null && echo "  ✓ Kept production_cleanup_inplace.sh"

    ARCHIVED_TEST_DOCS=$(find "$ARCHIVE_DIR/hook-migration-tests" -type f | wc -l | tr -d ' ')
    echo "  ℹ Archived $ARCHIVED_TEST_DOCS test documents"
fi

# Archive research sessions (keep 10 high-value)
echo -e "${YELLOW}[4/9] Archiving research sessions (keeping 10 high-value)...${NC}"
mkdir -p "$ARCHIVE_DIR/research-sessions"
if [ -d "docs/research-sessions" ]; then
    # High-value sessions to keep (comprehensive examples)
    KEEP_SESSIONS=(
        "17112025_160000_mini-app-notifications-comprehensive"
        "17112025_154500_mini-app-security-academic"
        "17112025_153000_consent-privacy-light-parallel"
        "fact-check-mini-app-notifications"
    )

    # Move all sessions
    mv docs/research-sessions/* "$ARCHIVE_DIR/research-sessions/" 2>/dev/null || true

    # Restore high-value sessions
    for session in "${KEEP_SESSIONS[@]}"; do
        if [ -d "$ARCHIVE_DIR/research-sessions/$session" ]; then
            mv "$ARCHIVE_DIR/research-sessions/$session" docs/research-sessions/
            echo "  ✓ Kept $session"
        elif [ -f "$ARCHIVE_DIR/research-sessions/$session.md" ]; then
            mv "$ARCHIVE_DIR/research-sessions/$session.md" docs/research-sessions/
            echo "  ✓ Kept $session.md"
        fi
    done

    ARCHIVED_SESSIONS=$(find "$ARCHIVE_DIR/research-sessions" -type f -o -type d -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')
    echo "  ℹ Archived $ARCHIVED_SESSIONS research sessions"
fi

# Archive analysis docs
echo -e "${YELLOW}[5/9] Archiving analysis documentation...${NC}"
mkdir -p "$ARCHIVE_DIR/docs"
if [ -d "docs" ]; then
    # Move analysis docs matching patterns
    find docs -maxdepth 1 -name "AGENT_*.md" -exec mv {} "$ARCHIVE_DIR/docs/" \; 2>/dev/null || true
    find docs -maxdepth 1 -name "ORCHESTRATION_*.md" -exec mv {} "$ARCHIVE_DIR/docs/" \; 2>/dev/null || true
    find docs -maxdepth 1 -name "PHASE*.md" -exec mv {} "$ARCHIVE_DIR/docs/" \; 2>/dev/null || true
    find docs -maxdepth 1 -name "ULTRA_*.md" -exec mv {} "$ARCHIVE_DIR/docs/" \; 2>/dev/null || true

    ARCHIVED_DOCS=$(find "$ARCHIVE_DIR/docs" -type f | wc -l | tr -d ' ')
    if [ "$ARCHIVED_DOCS" -gt 0 ]; then
        echo "  ✓ Archived $ARCHIVED_DOCS analysis documents"
    fi
fi

# Archive config research
echo -e "${YELLOW}[6/9] Archiving configuration research...${NC}"
if [ -d "agents-and-config" ]; then
    mv agents-and-config "$ARCHIVE_DIR/"
    echo "  ✓ Moved agents-and-config/"
fi

# Delete runtime logs
echo -e "${YELLOW}[7/9] Deleting runtime logs (regenerated)...${NC}"
if [ -d "hooks_logs" ]; then
    rm -rf hooks_logs/*
    echo "  ✓ Cleared hooks_logs/ (keeps directory)"
fi

# Delete deprecated files
echo -e "${YELLOW}[8/9] Deleting deprecated files...${NC}"
rm -f .claude/settings.local.json && echo "  ✓ Deleted .claude/settings.local.json"
rm -f .claude/agents/test-spawner.md && echo "  ✓ Deleted .claude/agents/test-spawner.md"
rm -f .claude/agents/research-subagent.md && echo "  ✓ Deleted .claude/agents/research-subagent.md"
rm -rf .claude/skills/test-skill-nesting && echo "  ✓ Deleted .claude/skills/test-skill-nesting/"

# Compress archive
echo -e "${YELLOW}[9/9] Compressing archive...${NC}"
ARCHIVE_FILE="archived_$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czf "$ARCHIVE_FILE" "$ARCHIVE_DIR"
ARCHIVE_SIZE=$(du -sh "$ARCHIVE_FILE" | awk '{print $1}')
echo "  ✓ Created $ARCHIVE_FILE ($ARCHIVE_SIZE)"

# Remove uncompressed archive
rm -rf "$ARCHIVE_DIR"
echo "  ✓ Removed temporary directory"

# Generate summary
echo ""
echo -e "${GREEN}=== Cleanup Complete ===${NC}"
echo ""
echo "Archive: $ARCHIVE_FILE ($ARCHIVE_SIZE)"
echo "New Size: $(du -sh . | awk '{print $1}')"
echo ""

# Count remaining components
SKILLS=$(find .claude/skills -maxdepth 1 -type d ! -path ".claude/skills" | wc -l | tr -d ' ')
AGENTS=$(find .claude/agents -maxdepth 1 -name "*.md" ! -name "README.md" | wc -l | tr -d ' ')
HOOKS=$(find .claude/hooks -name "*.sh" | wc -l | tr -d ' ')
TEST_DOCS=$(find docs/hook-migration-tests -name "*.md" | wc -l | tr -d ' ')

echo "Remaining Components:"
echo "  - Skills: $SKILLS"
echo "  - Agents: $AGENTS"
echo "  - Hooks: $HOOKS"
echo "  - Test Docs: $TEST_DOCS"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Review current directory (clean)"
echo "  2. Test with query: \"What is WebRTC?\""
echo "  3. Verify hooks_logs/ populates"
echo "  4. Keep archive: $ARCHIVE_FILE (for reference)"
echo "  5. Optional: git add/commit clean state"
echo ""
echo -e "${GREEN}Production-ready directory achieved!${NC}"
