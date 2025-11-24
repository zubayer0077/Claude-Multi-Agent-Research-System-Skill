#!/bin/bash
#
# Production Validation Script
# Verifies production deployment is complete and functional
#
# Usage: ./production_validation.sh
# Run from production deployment root
#

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect project root
if [ -d ".claude" ]; then
    PROJECT_ROOT="$(pwd)"
else
    echo -e "${RED}Error: Cannot find .claude directory. Please run from project root.${NC}"
    exit 1
fi

cd "$PROJECT_ROOT"

echo -e "${GREEN}=== RTC Mobile Production Validation ===${NC}"
echo ""
echo "Project Root: $PROJECT_ROOT"
echo "Validation Date: $(date +%Y-%m-%d_%H:%M:%S)"
echo ""

# Track validation results
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# Test function
check_exists() {
    local path="$1"
    local type="$2"  # "file" or "directory"
    local name="$3"

    if [ "$type" = "file" ]; then
        if [ -f "$path" ]; then
            echo -e "  ${GREEN}✓${NC} $name"
            ((PASS_COUNT++))
            return 0
        else
            echo -e "  ${RED}✗${NC} $name (missing)"
            ((FAIL_COUNT++))
            return 1
        fi
    elif [ "$type" = "directory" ]; then
        if [ -d "$path" ]; then
            echo -e "  ${GREEN}✓${NC} $name"
            ((PASS_COUNT++))
            return 0
        else
            echo -e "  ${RED}✗${NC} $name (missing)"
            ((FAIL_COUNT++))
            return 1
        fi
    fi
}

check_count() {
    local path="$1"
    local expected="$2"
    local name="$3"

    local actual=$(find $path | wc -l | tr -d ' ')
    if [ "$actual" -eq "$expected" ]; then
        echo -e "  ${GREEN}✓${NC} $name: $actual (expected $expected)"
        ((PASS_COUNT++))
        return 0
    else
        echo -e "  ${YELLOW}⚠${NC} $name: $actual (expected $expected)"
        ((WARN_COUNT++))
        return 1
    fi
}

# 1. Core Directories
echo -e "${BLUE}[1/8] Core Directory Structure${NC}"
check_exists ".claude" "directory" ".claude directory"
check_exists ".claude/skills" "directory" "Skills directory"
check_exists ".claude/agents" "directory" "Agents directory"
check_exists ".claude/hooks" "directory" "Hooks directory"
check_exists "hooks_logs" "directory" "Runtime logs directory"
check_exists "docs/research-sessions" "directory" "Research sessions directory"
echo ""

# 2. Skills
echo -e "${BLUE}[2/8] Production Skills (7 expected)${NC}"
check_exists ".claude/skills/internet-light-orchestrator/SKILL.md" "file" "Tier 3 - internet-light-orchestrator"
check_exists ".claude/skills/internet-deep-orchestrator/SKILL.md" "file" "Tier 4 - internet-deep-orchestrator"
check_exists ".claude/skills/internet-research-orchestrator/SKILL.md" "file" "Tier 5 - internet-research-orchestrator"
check_exists ".claude/skills/spec-proposal-creation/SKILL.md" "file" "Spec - proposal-creation"
check_exists ".claude/skills/spec-context-loading/SKILL.md" "file" "Spec - context-loading"
check_exists ".claude/skills/spec-implementation/SKILL.md" "file" "Spec - implementation"
check_exists ".claude/skills/spec-archiving/SKILL.md" "file" "Spec - archiving"
echo ""

# 3. Specialist Agents
echo -e "${BLUE}[3/8] Specialist Research Agents (11 expected)${NC}"
check_exists ".claude/agents/web-researcher.md" "file" "web-researcher"
check_exists ".claude/agents/academic-researcher.md" "file" "academic-researcher"
check_exists ".claude/agents/search-specialist.md" "file" "search-specialist"
check_exists ".claude/agents/trend-analyst.md" "file" "trend-analyst"
check_exists ".claude/agents/market-researcher.md" "file" "market-researcher"
check_exists ".claude/agents/competitive-analyst.md" "file" "competitive-analyst"
check_exists ".claude/agents/synthesis-researcher.md" "file" "synthesis-researcher"
check_exists ".claude/agents/fact-checker.md" "file" "fact-checker"
check_exists ".claude/agents/citations-agent.md" "file" "citations-agent"
check_exists ".claude/agents/light-research-researcher.md" "file" "light-research-researcher"
check_exists ".claude/agents/light-research-report-writer.md" "file" "light-research-report-writer"
echo ""

# 4. Requirements Agents
echo -e "${BLUE}[4/8] Requirements Agents (5 expected)${NC}"
check_exists ".claude/agents/spec-analyst.md" "file" "spec-analyst" || \
check_exists ".claude/agents/requirements/spec-analyst.md" "file" "spec-analyst (in requirements/)"
check_exists ".claude/agents/spec-architect.md" "file" "spec-architect" || \
check_exists ".claude/agents/requirements/spec-architect.md" "file" "spec-architect (in requirements/)"
check_exists ".claude/agents/spec-orchestrator.md" "file" "spec-orchestrator" || \
check_exists ".claude/agents/requirements/spec-orchestrator.md" "file" "spec-orchestrator (in requirements/)"
check_exists ".claude/agents/spec-planner.md" "file" "spec-planner" || \
check_exists ".claude/agents/requirements/spec-planner.md" "file" "spec-planner (in requirements/)"
check_exists ".claude/agents/spec-validator.md" "file" "spec-validator" || \
check_exists ".claude/agents/requirements/spec-validator.md" "file" "spec-validator (in requirements/)"
echo ""

# 5. Hooks
echo -e "${BLUE}[5/8] Hooks (4 expected)${NC}"
check_exists ".claude/hooks/user-prompt-submit/internet-search-router.sh" "file" "Query router (UserPromptSubmit)"
check_exists ".claude/hooks/monitoring/pre_tool_use.sh" "file" "PreToolUse hook"
check_exists ".claude/hooks/monitoring/post_tool_use.sh" "file" "PostToolUse hook"
check_exists ".claude/hooks/monitoring/subagent_stop.sh" "file" "SubagentStop hook"
echo ""

# 6. Configuration
echo -e "${BLUE}[6/8] Configuration Files${NC}"
check_exists ".claude/CLAUDE.md" "file" "Project instructions (CLAUDE.md)"
check_exists ".claude/agents/agent_registry.json" "file" "Agent registry"
check_exists ".mcp.json" "file" "MCP configuration" || echo -e "  ${YELLOW}⚠${NC} .mcp.json (optional)"
echo ""

# 7. Deprecated Files Check (should NOT exist)
echo -e "${BLUE}[7/8] Deprecated Files Check (should NOT exist)${NC}"
DEPRECATED_COUNT=0

if [ -d ".claude/skills/_archived" ]; then
    echo -e "  ${RED}✗${NC} .claude/skills/_archived should be deleted"
    ((DEPRECATED_COUNT++))
fi

if [ -f ".claude/settings.local.json" ]; then
    echo -e "  ${RED}✗${NC} .claude/settings.local.json should be deleted"
    ((DEPRECATED_COUNT++))
fi

if [ -f ".claude/agents/test-spawner.md" ]; then
    echo -e "  ${RED}✗${NC} .claude/agents/test-spawner.md should be deleted"
    ((DEPRECATED_COUNT++))
fi

if [ -f ".claude/agents/research-subagent.md" ]; then
    echo -e "  ${RED}✗${NC} .claude/agents/research-subagent.md should be deleted"
    ((DEPRECATED_COUNT++))
fi

if [ -d ".claude/skills/test-skill-nesting" ]; then
    echo -e "  ${RED}✗${NC} .claude/skills/test-skill-nesting should be deleted"
    ((DEPRECATED_COUNT++))
fi

if [ -d "archive" ]; then
    echo -e "  ${YELLOW}⚠${NC} archive/ directory still exists (should be archived)"
    ((WARN_COUNT++))
fi

if [ -d "docs/implementation-backups" ]; then
    echo -e "  ${YELLOW}⚠${NC} docs/implementation-backups/ still exists (should be archived)"
    ((WARN_COUNT++))
fi

if [ "$DEPRECATED_COUNT" -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} No deprecated files found"
    ((PASS_COUNT++))
else
    echo -e "  ${RED}Found $DEPRECATED_COUNT deprecated files${NC}"
    ((FAIL_COUNT += DEPRECATED_COUNT))
fi
echo ""

# 8. Documentation
echo -e "${BLUE}[8/8] Essential Documentation${NC}"
check_exists "docs/hook-migration-tests/HONEST_ASSESSMENT_PRE_PHASE7.md" "file" "Honest Assessment (known issues)"
check_exists "docs/hook-migration-tests/PHASE6_PRODUCTION_READINESS.md" "file" "Production Readiness"
check_exists "docs/hook-migration-tests/PHASE6_TESTING_COMPLETE.md" "file" "Testing Validation"
check_exists "docs/hook-migration-tests/PRODUCTION_DEPLOYMENT_EXECUTIVE_SUMMARY.md" "file" "Executive Summary" || echo -e "  ${YELLOW}⚠${NC} Executive Summary (optional)"
echo ""

# Summary
echo -e "${GREEN}=== Validation Summary ===${NC}"
echo ""
echo "Total Checks: $((PASS_COUNT + FAIL_COUNT + WARN_COUNT))"
echo -e "${GREEN}✓ Passed: $PASS_COUNT${NC}"
echo -e "${RED}✗ Failed: $FAIL_COUNT${NC}"
echo -e "${YELLOW}⚠ Warnings: $WARN_COUNT${NC}"
echo ""

# Size summary
TOTAL_SIZE=$(du -sh . | awk '{print $1}')
SKILLS_COUNT=$(find .claude/skills -maxdepth 1 -type d ! -path ".claude/skills" ! -path "*/_archived" | wc -l | tr -d ' ')
AGENTS_COUNT=$(find .claude/agents -name "*.md" ! -name "README.md" | wc -l | tr -d ' ')
HOOKS_COUNT=$(find .claude/hooks -name "*.sh" | wc -l | tr -d ' ')

echo "Deployment Size: $TOTAL_SIZE"
echo "Active Skills: $SKILLS_COUNT (expected 7)"
echo "Active Agents: $AGENTS_COUNT (expected 16)"
echo "Active Hooks: $HOOKS_COUNT (expected 4)"
echo ""

# Final verdict
if [ "$FAIL_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ Production deployment validation PASSED${NC}"
    if [ "$WARN_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Some warnings present (review above)${NC}"
    fi
    exit 0
else
    echo -e "${RED}✗ Production deployment validation FAILED${NC}"
    echo "Please review failed checks above and fix missing files."
    exit 1
fi
