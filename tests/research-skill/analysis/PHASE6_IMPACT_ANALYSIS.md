# Phase 6: Cleanup Impact Analysis

**Date**: 2025-11-17
**Phase**: 6 - Cleanup & Documentation
**Status**: Pre-execution analysis

---

## Executive Summary

This document analyzes the impact of cleaning up the `.claude/` directory after completing the hook-based orchestration migration. All orchestrator agents have been converted to skills (Phases 2-4), and the old v2.0 internet-search skill needs archiving. This analysis ensures no system breakage occurs during cleanup.

**Key Principle**: The `.claude/` folder should contain ONLY configuration, settings, and essential files used by hooks, skills, and Claude Code infrastructure.

---

## 1. Files to Delete

### 1.1 `.claude/agents/internet-light-orchestrator.md`

**Type**: Obsolete agent file (replaced by skill)
**Size**: ~200 lines (estimated)
**Status**: Replaced by `.claude/skills/internet-light-orchestrator/SKILL.md` in Phase 2

#### Impact Assessment

**Direct References**:
- ❌ **agent_registry.json**: Contains entry for this agent (search for "internet-light-orchestrator")
  - Entry includes: name, type, category, capabilities, query_patterns, cost_multiplier, model, tools, success_criteria, fallback_agent
  - Must be REMOVED or MODIFIED to reflect skill conversion

**Fallback Chains**:
- ✅ **No incoming fallbacks**: Other agents do NOT use this as their fallback_agent
- ⚠️ **Has outgoing fallback**: This agent's fallback_agent is "web-researcher"
  - No impact since agent entry will be removed entirely

**Router References**:
- ✅ **Not directly referenced**: Router uses tier-based routing, not specific agent names
- ✅ **Skill registration verified**: Skill already registered in `.claude/skills/`

#### Required Updates

1. **Remove from agent_registry.json**:
   ```json
   // DELETE this entire entry
   {
     "name": "internet-light-orchestrator",
     "type": "orchestrator",
     ...
   }
   ```

2. **Verify skill registration**:
   - ✅ Already exists: `.claude/skills/internet-light-orchestrator/SKILL.md`
   - ✅ Router can invoke via Skill tool

#### Rollback Procedure

```bash
# Backup before deletion
cp .claude/agents/internet-light-orchestrator.md .claude/agents/_backup/internet-light-orchestrator.md.bak

# Restore if needed
cp .claude/agents/_backup/internet-light-orchestrator.md.bak .claude/agents/internet-light-orchestrator.md
```

---

### 1.2 `.claude/agents/internet-deep-orchestrator.md`

**Type**: Obsolete agent file (replaced by skill)
**Size**: ~300 lines (estimated)
**Status**: Replaced by `.claude/skills/internet-deep-orchestrator/SKILL.md` in Phase 3

#### Impact Assessment

**Direct References**:
- ❌ **agent_registry.json**: Contains entry at lines 391-451
  - Entry details: RBMAS architecture, 7-phase methodology, tools list
  - Must be REMOVED or MODIFIED

**Fallback Chains**:
- ⚠️ **CRITICAL**: Multiple agents use this as fallback_agent:
  - `academic-researcher` → fallback to internet-deep-orchestrator
  - `trend-analyst` → fallback to internet-deep-orchestrator
  - `market-researcher` → fallback to internet-deep-orchestrator
  - `competitive-analyst` → fallback to internet-deep-orchestrator
  - `search-specialist` → fallback to internet-deep-orchestrator
  - `synthesis-researcher` → fallback to internet-deep-orchestrator

- ⚠️ **Has outgoing fallback**: This agent's fallback_agent is "internet-research-orchestrator"
  - Must update to alternative or remove

**Router References**:
- ✅ **Not directly referenced**: Router uses tier-based routing
- ✅ **Skill registration verified**: Skill exists in `.claude/skills/`

#### Required Updates

1. **Update fallback chains in agent_registry.json**:
   ```json
   // For academic-researcher, trend-analyst, market-researcher, competitive-analyst, search-specialist, synthesis-researcher
   // OPTION A: Change fallback to skill (if Claude Code supports this)
   "fallback_agent": "internet-deep-orchestrator-skill"

   // OPTION B: Remove fallback (agents operate independently)
   "fallback_agent": null

   // OPTION C: Fallback to web-researcher (safer option)
   "fallback_agent": "web-researcher"
   ```

2. **Remove orchestrator entry from agent_registry.json**:
   ```json
   // DELETE lines 391-451
   {
     "name": "internet-deep-orchestrator",
     "type": "orchestrator",
     ...
   }
   ```

3. **Verify skill registration**:
   - ✅ Already exists: `.claude/skills/internet-deep-orchestrator/SKILL.md`
   - ✅ Router can invoke via Skill tool

#### Rollback Procedure

```bash
# Backup
cp .claude/agents/internet-deep-orchestrator.md .claude/agents/_backup/internet-deep-orchestrator.md.bak
cp .claude/agents/agent_registry.json .claude/agents/_backup/agent_registry.json.bak

# Restore if needed
cp .claude/agents/_backup/internet-deep-orchestrator.md.bak .claude/agents/internet-deep-orchestrator.md
cp .claude/agents/_backup/agent_registry.json.bak .claude/agents/agent_registry.json
```

---

### 1.3 `.claude/agents/internet-research-orchestrator.md`

**Type**: Obsolete agent file (replaced by skill)
**Size**: ~400 lines (estimated)
**Status**: Replaced by `.claude/skills/internet-research-orchestrator/SKILL.md` in Phase 4

#### Impact Assessment

**Direct References**:
- ❌ **agent_registry.json**: Contains entry at lines 452-504
  - Entry details: TODAS architecture, adaptive complexity, Self-Challenge framework
  - Must be REMOVED or MODIFIED

**Fallback Chains**:
- ⚠️ **Incoming fallback**: `internet-deep-orchestrator` uses this as fallback_agent
  - Since internet-deep-orchestrator agent will also be deleted, this reference becomes moot
  - BUT if we keep deep-orchestrator entry for fallback purposes, must update its fallback

- ✅ **No outgoing fallback**: This is the highest tier, fallback_agent is null

**Router References**:
- ✅ **Not directly referenced**: Router uses tier-based routing
- ✅ **Skill registration verified**: Skill exists in `.claude/skills/`

#### Required Updates

1. **Remove from agent_registry.json**:
   ```json
   // DELETE lines 452-504
   {
     "name": "internet-research-orchestrator",
     "type": "orchestrator",
     ...
   }
   ```

2. **Update internet-deep-orchestrator's fallback** (if keeping entry):
   ```json
   // In internet-deep-orchestrator entry (if we keep it)
   "fallback_agent": null  // or "web-researcher"
   ```

3. **Verify skill registration**:
   - ✅ Already exists: `.claude/skills/internet-research-orchestrator/SKILL.md`
   - ✅ Router can invoke via Skill tool

#### Rollback Procedure

```bash
# Backup
cp .claude/agents/internet-research-orchestrator.md .claude/agents/_backup/internet-research-orchestrator.md.bak

# Restore if needed
cp .claude/agents/_backup/internet-research-orchestrator.md.bak .claude/agents/internet-research-orchestrator.md
```

---

## 2. Files to Archive

### 2.1 `.claude/skills/internet-search/` (entire directory)

**Type**: Old v2.0 skill (~700 lines, 35 files)
**Created**: Phase 0 (pre-hook architecture)
**Status**: Replaced by hook-based tier system + 3 orchestrator skills

#### Impact Assessment

**Direct References**:
- ⚠️ **Check router scripts**: Search for "internet-search" in hook scripts
  - `.claude/hooks/user-prompt-submit/internet-search-router.sh`
  - May contain references to old skill name

**Active Usage**:
- ✅ **Not actively used**: Hook-based system uses tier routing now
- ✅ **Replaced by**: Tier 1-5 agent/skill routing

**Historical Value**:
- ⚠️ **Contains original design**: 700-line SKILL.md with v2.0 architecture
- ⚠️ **Research artifacts**: JSON schemas, agent definitions, routing logic
- ✅ **Should be preserved**: Move to archive, not delete

#### Archive Location

```bash
# Archive path
.claude/skills/_archived/internet-search-v2.0-20251117/

# Contents to archive
- SKILL.md (2162 lines)
- json-schemas/ (routing templates)
- temp/ (extraction documents)
- All supporting files
```

#### Required Updates

1. **Verify no active references**:
   ```bash
   grep -r "internet-search" .claude/hooks/
   grep -r "internet-search" .claude/settings.json
   grep -r "internet-search" .claude/agents/agent_registry.json
   ```

2. **Create archive directory**:
   ```bash
   mkdir -p .claude/skills/_archived/internet-search-v2.0-20251117/
   ```

3. **Move (not delete)**:
   ```bash
   mv .claude/skills/internet-search/* .claude/skills/_archived/internet-search-v2.0-20251117/
   rmdir .claude/skills/internet-search/
   ```

#### Rollback Procedure

```bash
# Restore from archive
mkdir -p .claude/skills/internet-search/
cp -r .claude/skills/_archived/internet-search-v2.0-20251117/* .claude/skills/internet-search/
```

---

## 3. Files to Update

### 3.1 `.claude/agents/agent_registry.json`

**Current State**: 663 lines, 13 agents
**Required Changes**: Remove 3 orchestrator entries, update 6 fallback chains

#### Changes Required

**DELETE these entries**:
1. `internet-light-orchestrator` (estimated lines: search for name in file)
2. `internet-deep-orchestrator` (lines 391-451)
3. `internet-research-orchestrator` (lines 452-504)

**UPDATE fallback chains** (6 agents affected):
```json
// academic-researcher
{
  "name": "academic-researcher",
  "fallback_agent": "web-researcher"  // CHANGE FROM: "internet-deep-orchestrator"
}

// trend-analyst
{
  "name": "trend-analyst",
  "fallback_agent": "web-researcher"  // CHANGE FROM: "internet-deep-orchestrator"
}

// market-researcher
{
  "name": "market-researcher",
  "fallback_agent": "web-researcher"  // CHANGE FROM: "internet-deep-orchestrator"
}

// competitive-analyst
{
  "name": "competitive-analyst",
  "fallback_agent": "web-researcher"  // CHANGE FROM: "internet-deep-orchestrator"
}

// search-specialist
{
  "name": "search-specialist",
  "fallback_agent": "web-researcher"  // CHANGE FROM: "internet-deep-orchestrator"
}

// synthesis-researcher
{
  "name": "synthesis-researcher",
  "fallback_agent": "web-researcher"  // CHANGE FROM: "internet-deep-orchestrator"
}
```

#### Rationale for Fallback Changes

**Why change to "web-researcher"?**
- ✅ **Simplest tier**: Basic web search capability
- ✅ **Always available**: Not a skill, direct agent spawn
- ✅ **Safe fallback**: No complex orchestration dependencies
- ✅ **Maintains graceful degradation**: If specialist fails, fall back to general search

**Alternative considered**: Setting fallback_agent to null
- ❌ **Less graceful**: Agent fails with no recovery
- ❌ **Breaks fallback chain**: Original design assumed fallback orchestration

#### Validation Steps

After updating agent_registry.json:

1. **Verify JSON syntax**:
   ```bash
   jq empty .claude/agents/agent_registry.json
   ```

2. **Count remaining agents**:
   ```bash
   jq '.agents | length' .claude/agents/agent_registry.json
   # Should be 10 (13 - 3 orchestrators)
   ```

3. **Verify fallback chains**:
   ```bash
   jq '.agents[] | select(.fallback_agent == "internet-deep-orchestrator")' .claude/agents/agent_registry.json
   # Should return EMPTY (no results)
   ```

4. **Test router functionality**:
   - Use a test query to verify tier routing still works
   - Confirm skills can be invoked

---

### 3.2 `.claude/CLAUDE.md` (Project Instructions)

**Current State**: 893 lines (as of Phase 5)
**Last Updated**: 2025-11-14 (added .claude/ directory separation rules)

#### Changes Required

**Section: Available Agents**
- ❌ **REMOVE**: References to orchestrator agents in "Research (Automatic)" section
- ✅ **KEEP**: References to orchestrator skills (already documented)

**Section: Agent Interaction Map**
- ✅ **UPDATE**: Show skills as entry points, not agents
- Current diagram shows agents spawning agents
- New diagram should show skills spawning agents

**Section: Workflow Examples**
- ✅ **UPDATE**: Use Skill tool instead of Task tool for orchestrators
- Example: "Use internet-deep-orchestrator skill" (not "Launch internet-deep-orchestrator agent")

**Section: Decision Matrix**
- ✅ **UPDATE**: "Use internet-search skill when..." section
- Clarify that orchestrators are now skills, not agents

#### Specific Line Changes

**OLD**:
```markdown
### Research (Automatic)
- **internet-search skill**: MANDATORY for all research/search/analysis tasks
  - Manages 15 research agents internally (5-tier system)
```

**NEW**:
```markdown
### Research (Automatic)
- **internet-search skill**: MANDATORY for all research/search/analysis tasks
  - Manages 10 research agents + 3 orchestrator skills (5-tier system)
  - Tier 3-5 use skills: internet-light-orchestrator, internet-deep-orchestrator, internet-research-orchestrator
```

**OLD** (Agent Interaction Map):
```
internet-deep-orchestrator
(Research Orchestrator)
```

**NEW**:
```
internet-deep-orchestrator SKILL
(spawns specialist agents)
```

---

## 4. Verification Checklist

Before executing cleanup, verify these conditions:

### Pre-Cleanup Checks

- [ ] **Backup created**: All files to be deleted/modified backed up
- [ ] **Git committed**: All current work committed to git
- [ ] **Tag created**: Milestone tag for pre-cleanup state
- [ ] **Registry validated**: agent_registry.json syntax verified with jq
- [ ] **Router tested**: internet-search-router.sh still functional
- [ ] **Skills verified**: All 3 orchestrator skills exist in .claude/skills/

### Post-Cleanup Checks

- [ ] **JSON valid**: agent_registry.json still valid after updates
- [ ] **Agent count correct**: 10 agents remain (13 - 3 orchestrators)
- [ ] **No broken references**: No "internet-deep-orchestrator" in fallback chains
- [ ] **Skills functional**: Can invoke orchestrator skills via Skill tool
- [ ] **Router works**: Test query routes correctly to tiers
- [ ] **Archive created**: Old internet-search skill preserved in _archived/
- [ ] **CLAUDE.md updated**: Documentation reflects skill-based architecture
- [ ] **No .claude/ pollution**: Only config/settings/essential files remain

### Functional Tests

**Test 1: Tier 1 routing**
```
Query: "What is WebRTC?"
Expected: web-researcher direct spawn (no orchestration)
```

**Test 2: Tier 3 routing**
```
Query: "Research WebRTC security across network, browser, implementation dimensions"
Expected: internet-light-orchestrator skill invoked
```

**Test 3: Tier 4 routing**
```
Query: "Comprehensive analysis of WebRTC performance optimization across codecs, network, hardware, software dimensions"
Expected: internet-deep-orchestrator skill invoked
```

**Test 4: Fallback chain**
```
Scenario: academic-researcher fails
Expected: Falls back to web-researcher (not internet-deep-orchestrator)
```

---

## 5. Execution Plan

### Step 1: Pre-Cleanup Preparation

```bash
# 1. Create backup directory
mkdir -p .claude/agents/_backup/
mkdir -p .claude/skills/_archived/

# 2. Backup files to be modified
cp .claude/agents/agent_registry.json .claude/agents/_backup/agent_registry.json.$(date +%Y%m%d_%H%M%S)
cp .claude/CLAUDE.md .claude/_backup/CLAUDE.md.$(date +%Y%m%d_%H%M%S)

# 3. Backup files to be deleted
cp .claude/agents/internet-light-orchestrator.md .claude/agents/_backup/
cp .claude/agents/internet-deep-orchestrator.md .claude/agents/_backup/
cp .claude/agents/internet-research-orchestrator.md .claude/agents/_backup/

# 4. Create git commit for pre-cleanup state
git add -A
git commit -m "chore(phase-6): Pre-cleanup backup - agent registry and orchestrator agents"
git tag -a "phase-6-pre-cleanup" -m "Backup before Phase 6 cleanup operations"
```

### Step 2: Archive Old Skill

```bash
# 1. Create archive directory with timestamp
mkdir -p .claude/skills/_archived/internet-search-v2.0-20251117/

# 2. Move old skill
mv .claude/skills/internet-search/* .claude/skills/_archived/internet-search-v2.0-20251117/

# 3. Remove empty directory
rmdir .claude/skills/internet-search/

# 4. Commit archive
git add -A
git commit -m "chore(phase-6): Archive old internet-search v2.0 skill"
```

### Step 3: Update Agent Registry

```bash
# 1. Read current registry
jq . .claude/agents/agent_registry.json > /tmp/registry_current.json

# 2. Remove orchestrator entries and update fallbacks using jq
# (Detailed jq commands in next section)

# 3. Validate new registry
jq empty .claude/agents/agent_registry.json

# 4. Commit registry update
git add .claude/agents/agent_registry.json
git commit -m "chore(phase-6): Remove orchestrator agents from registry, update fallback chains"
```

### Step 4: Delete Obsolete Agent Files

```bash
# 1. Delete orchestrator agent files
rm .claude/agents/internet-light-orchestrator.md
rm .claude/agents/internet-deep-orchestrator.md
rm .claude/agents/internet-research-orchestrator.md

# 2. Verify deletion
ls .claude/agents/*.md | grep -E "orchestrator"
# Should return empty

# 3. Commit deletion
git add -A
git commit -m "chore(phase-6): Delete obsolete orchestrator agent files (replaced by skills)"
```

### Step 5: Update Documentation

```bash
# 1. Update CLAUDE.md (using Edit tool)
# (Specific edits detailed in Section 3.2)

# 2. Commit documentation update
git add .claude/CLAUDE.md
git commit -m "docs(phase-6): Update CLAUDE.md to reflect skill-based orchestration"
```

### Step 6: Verification & Finalization

```bash
# 1. Run all verification checks (from Section 4)

# 2. Create cleanup report
# (Generate PHASE6_CLEANUP_REPORT.md)

# 3. Final commit
git add docs/hook-migration-tests/PHASE6_CLEANUP_REPORT.md
git commit -m "docs(phase-6): Add cleanup report and verification results"

# 4. Create milestone tag
git tag -a "phase-6-cleanup-complete" -m "Phase 6: Cleanup completed - skill-based architecture finalized"
```

---

## 6. Rollback Procedures

### If Cleanup Breaks System

**Scenario 1: Router stops working**
```bash
# Restore agent registry
cp .claude/agents/_backup/agent_registry.json.YYYYMMDD_HHMMSS .claude/agents/agent_registry.json

# Verify
jq empty .claude/agents/agent_registry.json
```

**Scenario 2: Skills not found**
```bash
# Verify skill directories exist
ls -la .claude/skills/internet-*-orchestrator/

# If missing, restore from git
git checkout HEAD~1 -- .claude/skills/
```

**Scenario 3: Complete rollback needed**
```bash
# Reset to pre-cleanup tag
git reset --hard phase-6-pre-cleanup

# Verify state
git log --oneline -5
ls .claude/agents/*.md
```

---

## 7. Impact Summary

### Files Affected

| File | Action | Impact | Risk Level |
|------|--------|--------|------------|
| `.claude/agents/internet-light-orchestrator.md` | DELETE | None (replaced by skill) | 🟢 LOW |
| `.claude/agents/internet-deep-orchestrator.md` | DELETE | Fallback chains broken | 🟡 MEDIUM |
| `.claude/agents/internet-research-orchestrator.md` | DELETE | None (replaced by skill) | 🟢 LOW |
| `.claude/agents/agent_registry.json` | UPDATE | Fallback chains, entry removal | 🟡 MEDIUM |
| `.claude/skills/internet-search/` | ARCHIVE | None (not actively used) | 🟢 LOW |
| `.claude/CLAUDE.md` | UPDATE | Documentation accuracy | 🟢 LOW |

### System Components Affected

| Component | Change | Impact |
|-----------|--------|--------|
| **Router** | None | ✅ No changes needed |
| **Hook System** | None | ✅ No changes needed |
| **Agent Registry** | 3 deletions, 6 updates | ⚠️ Fallback chains modified |
| **Skill System** | 1 archive | ✅ Old skill preserved |
| **Orchestration** | Agent → Skill paradigm | ✅ Already migrated in Phases 2-4 |

### Risk Mitigation

**Medium Risk Items**:
1. **Fallback chain updates**: Changed 6 agents to fallback to web-researcher
   - Mitigation: Backups created, git tags for rollback
   - Validation: Test fallback scenarios before finalizing

2. **Agent registry modifications**: Removing 3 entries, updating JSON structure
   - Mitigation: jq validation before/after changes
   - Validation: JSON syntax check, agent count verification

**Low Risk Items**:
- Deleting agent files already replaced by skills
- Archiving old skill (preserved in _archived/)
- Documentation updates (can be reverted from git)

---

## 8. Expected Outcomes

### After Successful Cleanup

**`.claude/` Directory Structure**:
```
.claude/
├── settings.json                    # Hook configuration
├── CLAUDE.md                        # Updated documentation
├── agents/
│   ├── agent_registry.json          # 10 agents (down from 13)
│   ├── web-researcher.md
│   ├── academic-researcher.md
│   ├── fact-checker.md
│   ├── trend-analyst.md
│   ├── market-researcher.md
│   ├── competitive-analyst.md
│   ├── search-specialist.md
│   ├── synthesis-researcher.md
│   ├── research-subagent.md
│   ├── citations-agent.md
│   ├── Explore.md
│   └── _backup/                     # Deleted agent backups
├── skills/
│   ├── internet-light-orchestrator/
│   ├── internet-deep-orchestrator/
│   ├── internet-research-orchestrator/
│   ├── spec-*/                      # Requirements skills
│   └── _archived/
│       └── internet-search-v2.0-20251117/
└── hooks/
    ├── user-prompt-submit/
    │   └── internet-search-router.sh
    └── monitoring/
        ├── pre_tool_use.sh
        ├── post_tool_use.sh
        └── subagent_stop.sh
```

**Agent Count**: 10 active agents (13 - 3 orchestrators)

**Orchestration Model**:
- Tier 1-2: Direct agent spawning
- Tier 3-5: Skill-based orchestration

**Fallback Chains**:
- All specialist agents → web-researcher
- No circular dependencies
- Graceful degradation maintained

---

## 9. Open Questions

### Q1: Should we keep orchestrator entries in agent_registry.json?

**Option A**: Delete orchestrator entries entirely
- ✅ Pro: Clean separation (agents vs. skills)
- ✅ Pro: No confusion about orchestrator type
- ❌ Con: Lose metadata about orchestrator capabilities

**Option B**: Keep entries but mark as "deprecated" or "skill"
- ✅ Pro: Preserve routing metadata
- ✅ Pro: Document orchestrator capabilities in registry
- ❌ Con: Registry contains non-agent entities

**Recommendation**: **Option A (Delete)** - Registry should only contain agents, skills have their own SKILL.md files with full metadata

### Q2: What should fallback_agent be for specialist agents?

**Option A**: Change to "web-researcher"
- ✅ Pro: Simple, always available
- ✅ Pro: Maintains graceful degradation
- ❌ Con: Loss of orchestration fallback capability

**Option B**: Set to null
- ✅ Pro: Clean, no dependencies
- ❌ Con: No graceful degradation
- ❌ Con: Agent fails with no recovery

**Option C**: Reference orchestrator skills somehow
- ❌ Con: Registry doesn't support skill references
- ❌ Con: Fallback mechanism expects agent names

**Recommendation**: **Option A (web-researcher)** - Maintains graceful degradation while avoiding broken references

### Q3: Should we archive or delete the old internet-search skill?

**Option A**: Archive (preserve in _archived/)
- ✅ Pro: Historical reference preserved
- ✅ Pro: Can study v2.0 design decisions
- ✅ Pro: Rollback possible if needed
- ❌ Con: Takes up space

**Option B**: Delete entirely
- ✅ Pro: Cleaner directory structure
- ❌ Con: Lose 700 lines of design documentation
- ❌ Con: No way to reference v2.0 architecture

**Recommendation**: **Option A (Archive)** - Historical value justifies space cost

---

## 10. Conclusion

This impact analysis provides a comprehensive plan for Phase 6 cleanup operations. All deletions have documented impacts, rollback procedures, and verification steps.

**Key Takeaways**:
1. **3 agent files to delete**: All replaced by skills
2. **6 fallback chains to update**: Change to web-researcher
3. **1 skill to archive**: Preserve v2.0 for historical reference
4. **2 files to update**: agent_registry.json, CLAUDE.md
5. **All changes reversible**: Backups + git tags ensure safety

**Next Steps**:
1. Get user approval on open questions (Section 9)
2. Execute cleanup following Section 5 plan
3. Run verification checklist (Section 4)
4. Create PHASE6_CLEANUP_REPORT.md documenting results

**Estimated Time**: 30-45 minutes for careful execution with verification

---

**Document Status**: ✅ Ready for review
**Author**: Claude Code (Phase 6 Planning)
**Review Required**: User approval on open questions before execution
