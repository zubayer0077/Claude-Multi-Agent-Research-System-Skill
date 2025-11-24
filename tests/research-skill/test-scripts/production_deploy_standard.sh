#!/bin/bash
#
# Production Deployment Script - Standard Configuration (1.2MB)
# Creates clean production-ready copy with core infrastructure + essential docs
#
# Usage: ./production_deploy_standard.sh [target_directory]
# Example: ./production_deploy_standard.sh ~/rtc_mobile_production
#

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get script directory (source project)
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
TARGET_DIR="${1:-${SOURCE_DIR}_production}"

echo -e "${GREEN}=== RTC Mobile Production Deployment - Standard Configuration ===${NC}"
echo ""
echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_DIR"
echo "Configuration: Standard (1.2MB)"
echo ""

# Safety check
if [ -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target directory already exists: $TARGET_DIR${NC}"
    echo "Please remove it first or choose a different target."
    exit 1
fi

# Confirm
read -p "Proceed with deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}[1/8] Creating target directory...${NC}"
mkdir -p "$TARGET_DIR"

echo -e "${YELLOW}[2/8] Copying core infrastructure...${NC}"
# Copy .claude directory
cp -r "$SOURCE_DIR/.claude" "$TARGET_DIR/"

# Copy root config files
cp "$SOURCE_DIR/.mcp.json" "$TARGET_DIR/" 2>/dev/null || echo "Warning: .mcp.json not found"
cp "$SOURCE_DIR/README.md" "$TARGET_DIR/" 2>/dev/null || echo "Warning: README.md not found"

echo -e "${YELLOW}[3/8] Removing deprecated/archived files...${NC}"
# Remove archived skills
rm -rf "$TARGET_DIR/.claude/skills/_archived"

# Remove user-specific settings
rm -f "$TARGET_DIR/.claude/settings.local.json"

# Remove deprecated agents
rm -f "$TARGET_DIR/.claude/agents/test-spawner.md"
rm -f "$TARGET_DIR/.claude/agents/research-subagent.md"

# Remove test skill
rm -rf "$TARGET_DIR/.claude/skills/test-skill-nesting"

echo -e "${YELLOW}[4/8] Creating runtime directories...${NC}"
mkdir -p "$TARGET_DIR/hooks_logs"
mkdir -p "$TARGET_DIR/docs/research-sessions"
mkdir -p "$TARGET_DIR/docs/hook-migration-tests"

echo -e "${YELLOW}[5/8] Copying essential documentation...${NC}"
# Copy top 3 validation docs
cp "$SOURCE_DIR/docs/hook-migration-tests/HONEST_ASSESSMENT_PRE_PHASE7.md" "$TARGET_DIR/docs/hook-migration-tests/" 2>/dev/null || echo "Warning: HONEST_ASSESSMENT not found"
cp "$SOURCE_DIR/docs/hook-migration-tests/PHASE6_PRODUCTION_READINESS.md" "$TARGET_DIR/docs/hook-migration-tests/" 2>/dev/null || echo "Warning: PRODUCTION_READINESS not found"
cp "$SOURCE_DIR/docs/hook-migration-tests/PHASE6_TESTING_COMPLETE.md" "$TARGET_DIR/docs/hook-migration-tests/" 2>/dev/null || echo "Warning: TESTING_COMPLETE not found"

# Copy this executive summary
cp "$SOURCE_DIR/docs/hook-migration-tests/PRODUCTION_DEPLOYMENT_EXECUTIVE_SUMMARY.md" "$TARGET_DIR/docs/hook-migration-tests/" 2>/dev/null || echo "Info: Executive summary not found"
cp "$SOURCE_DIR/docs/hook-migration-tests/PRODUCTION_DEPLOYMENT_ANALYSIS.md" "$TARGET_DIR/docs/hook-migration-tests/" 2>/dev/null || echo "Info: Full analysis not found"

echo -e "${YELLOW}[6/8] Copying comprehensive report example...${NC}"
# Copy Test 4 output (comprehensive research example)
cp "$SOURCE_DIR/docs/mini-app-notification-architecture-comprehensive-report.md" "$TARGET_DIR/docs/" 2>/dev/null || echo "Warning: Comprehensive report not found"

echo -e "${YELLOW}[7/8] Copying 10 high-value research sessions...${NC}"
# Copy high-value research sessions (examples of all 5 tiers)
RESEARCH_SESSIONS=(
    "17112025_160000_mini-app-notifications-comprehensive"
    "17112025_154500_mini-app-security-academic"
    "17112025_153000_consent-privacy-light-parallel"
    "fact-check-mini-app-notifications"
)

for session in "${RESEARCH_SESSIONS[@]}"; do
    if [ -d "$SOURCE_DIR/docs/research-sessions/$session" ]; then
        cp -r "$SOURCE_DIR/docs/research-sessions/$session" "$TARGET_DIR/docs/research-sessions/"
        echo "  ✓ Copied: $session"
    elif [ -f "$SOURCE_DIR/docs/hook-migration-tests/$session.md" ]; then
        cp "$SOURCE_DIR/docs/hook-migration-tests/$session.md" "$TARGET_DIR/docs/research-sessions/"
        echo "  ✓ Copied: $session.md"
    else
        echo "  ⚠ Not found: $session"
    fi
done

echo -e "${YELLOW}[8/8] Generating deployment summary...${NC}"

# Count files
TOTAL_FILES=$(find "$TARGET_DIR" -type f | wc -l | tr -d ' ')
TOTAL_SIZE=$(du -sh "$TARGET_DIR" | awk '{print $1}')

# Count core components
SKILLS=$(find "$TARGET_DIR/.claude/skills" -maxdepth 1 -type d ! -path "$TARGET_DIR/.claude/skills" | wc -l | tr -d ' ')
AGENTS=$(find "$TARGET_DIR/.claude/agents" -maxdepth 1 -name "*.md" ! -name "README.md" | wc -l | tr -d ' ')
HOOKS=$(find "$TARGET_DIR/.claude/hooks" -name "*.sh" | wc -l | tr -d ' ')

echo ""
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo ""
echo "Target Directory: $TARGET_DIR"
echo "Total Size: $TOTAL_SIZE"
echo "Total Files: $TOTAL_FILES"
echo ""
echo "Core Components:"
echo "  - Skills: $SKILLS"
echo "  - Agents: $AGENTS"
echo "  - Hooks: $HOOKS"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. cd $TARGET_DIR"
echo "  2. Review .claude/CLAUDE.md (project instructions)"
echo "  3. Review docs/hook-migration-tests/HONEST_ASSESSMENT_PRE_PHASE7.md (known issues)"
echo "  4. Test with simple query: \"What is WebRTC?\""
echo "  5. Verify hooks_logs/ directory populates"
echo ""
echo -e "${GREEN}Production deployment ready!${NC}"
