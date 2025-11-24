# File Allocation Map
## Complete File Distribution for Hook-Based Migration

**Created**: 2025-11-16
**Purpose**: Map ALL files from internet-search skill to their destination in hook-based architecture

---

## Current Internet-Search Skill Structure

```
.claude/skills/internet-search/
├── SKILL.md (2162 lines) - Main skill logic
├── research-agents-registry.json (467 lines) - 15 agent metadata
├── routing-logic-reference.md - Detailed routing rules
├── confidence-scoring-guide.md - Scoring methodology
├── fallback-chains-reference.md - Fallback logic
├── IMPLEMENTATION_VALIDATION.md - Validation docs
├── routing-examples/
│   ├── tier-1-simple-queries.md
│   ├── tier-2-specialists.md
│   ├── tier-3-comprehensive.md
│   └── tier-4-novel-domains.md
├── agent-prompt-templates/
│   ├── research-agent-template.md
│   ├── verification-agent-template.md
│   ├── citations-agent-template.md
│   └── synthesis-agent-template.md
├── json-schemas/
│   ├── research-output-schema.json
│   ├── verification-schema.json
│   ├── citations-schema.json
│   └── synthesis-schema.json
├── hooks/ (old hook experiments)
│   ├── pre_tool_use.sh
│   ├── post_tool_use.sh
│   ├── subagent_stop.sh
│   ├── test_hook_input.sh
│   ├── identify_subagent_calls.sh
│   ├── analyze_test_results.sh
│   └── [documentation .md files]
└── tools/ (Python utilities)
    ├── message_handler.py
    ├── subagent_tracker_anthropic.py
    └── transcript_anthropic.py
```

**Total Files**: ~35 files

---

## File Destination Mapping

### 1. HOOK ROUTER (.claude/hooks/pre-prompt/)

**New File Created**:
```
.claude/hooks/pre-prompt/
└── internet-search-router.sh (NEW - 200-300 lines)
```

**Sourced From**:
- ✅ `SKILL.md` - Steps 2-5 (query analysis, routing logic)
- ✅ `routing-logic-reference.md` - Routing rules converted to bash
- ✅ `research-agents-registry.json` - Embedded as bash variables
- ✅ `confidence-scoring-guide.md` - Simplified for bash
- ✅ `fallback-chains-reference.md` - Optional fallback logic
- ✅ `routing-examples/` - Test cases for validation

**What Gets Extracted**:
| Source File | Extracted Content | Hook Function |
|-------------|-------------------|---------------|
| SKILL.md Step 2 | Intent classification | `analyze_intent()` |
| SKILL.md Step 2 | Complexity assessment | `analyze_complexity()` |
| SKILL.md Step 2 | Domain identification | `analyze_domain()` |
| SKILL.md Step 5 | Dimension counting | `count_dimensions()` |
| SKILL.md Step 3 | Tier selection | `route_to_tier()` |
| routing-logic-reference.md | Routing rules | If/elif logic |
| research-agents-registry.json | Agent metadata | Bash arrays/variables |

---

### 2. TIER 3 SKILL (.claude/skills/tier-3-light-research/)

**New Files Created**:
```
.claude/skills/tier-3-light-research/
├── SKILL.md (NEW - 180-220 lines)
└── README.md (optional - usage guide)
```

**Sourced From**:
- ✅ `.claude/agents/internet-light-orchestrator.md` - Main conversion source
- ✅ `.claude/skills/internet-search/SKILL.md` - Session management (Step 0)
- ❌ No templates needed (Tier 3 doesn't use JSON schemas)
- ❌ No schemas needed (markdown output only)

**What Tier 3 Inherits**:
- Session creation logic (from internet-search SKILL.md Step 0)
- researchPath coordination pattern
- Worker spawning pattern

---

### 3. TIER 4 SKILL (.claude/skills/tier-4-deep-research/)

**New Files Created**:
```
.claude/skills/tier-4-deep-research/
├── SKILL.md (NEW - 250-350 lines)
├── agent-prompt-templates/ (COPY from internet-search)
│   ├── research-agent-template.md
│   ├── verification-agent-template.md
│   ├── citations-agent-template.md
│   └── synthesis-agent-template.md
└── json-schemas/ (COPY from internet-search)
    ├── research-output-schema.json
    ├── verification-schema.json
    ├── citations-schema.json
    └── synthesis-schema.json
```

**Sourced From**:
- ✅ `.claude/agents/internet-deep-orchestrator.md` - Main conversion source
- ✅ `.claude/skills/internet-search/agent-prompt-templates/` - **REUSE** (copy to tier-4)
- ✅ `.claude/skills/internet-search/json-schemas/` - **REUSE** (copy to tier-4)
- ✅ `.claude/skills/internet-search/SKILL.md` - Session management, quality gates

**Why Tier 4 Needs These**:
- Tier 4 uses JSON schemas for structured output
- Tier 4 spawns specialist agents (web-researcher, academic-researcher, etc.)
- Agent prompt templates generate prompts dynamically

---

### 4. TIER 5 SKILL (.claude/skills/tier-5-novel-research/)

**New Files Created**:
```
.claude/skills/tier-5-novel-research/
├── SKILL.md (NEW - 300-400 lines)
├── agent-prompt-templates/ (COPY from internet-search)
│   └── research-agent-template.md (ADAPT for research-subagent)
└── json-schemas/ (COPY from internet-search)
    ├── research-output-schema.json
    └── synthesis-schema.json
```

**Sourced From**:
- ✅ `.claude/agents/internet-research-orchestrator.md` - Main conversion source
- ✅ `.claude/skills/internet-search/agent-prompt-templates/research-agent-template.md` - **ADAPT**
- ✅ `.claude/skills/internet-search/json-schemas/` - **REUSE** (partial)
- ✅ `.claude/skills/internet-search/SKILL.md` - Session management

**Why Tier 5 Needs Fewer Files**:
- Tier 5 spawns generic `research-subagent` (not specialists)
- Only needs basic research template (not verification/citations)
- Adaptive workflow (TODAS) is more flexible

---

### 5. ARCHIVED (.claude/skills/_archived/internet-search-v2.0-YYYYMMDD/)

**All Files Preserved**:
```
.claude/skills/_archived/internet-search-v2.0-20251116/
├── SKILL.md (original)
├── research-agents-registry.json
├── routing-logic-reference.md
├── confidence-scoring-guide.md
├── fallback-chains-reference.md
├── IMPLEMENTATION_VALIDATION.md
├── routing-examples/
├── agent-prompt-templates/
├── json-schemas/
├── hooks/ (old experiments)
├── tools/
└── ARCHIVE_README.md (NEW - explains archival)
```

**Why Archive Entire Skill**:
- Complete rollback capability
- Historical reference
- Preserves working state before migration
- Documentation of v2.0 architecture

**What Gets Deleted** (NOT archived):
- `.DS_Store` files
- `__pycache__/` directories

---

### 6. DELETED (Obsolete After Migration)

**Old Hook Experiments** (`.claude/skills/internet-search/hooks/`):
```
❌ DELETE (after verification):
├── pre_tool_use.sh - Superseded by new hook router
├── post_tool_use.sh - Not needed in new architecture
├── subagent_stop.sh - Not needed in new architecture
├── test_hook_input.sh - Testing only
├── identify_subagent_calls.sh - Diagnostic only
├── analyze_test_results.sh - Testing only
└── [documentation .md files] - Archive instead
```

**Rationale**: These were experiments for the Agent → Agent spawning workaround. New hook router replaces this approach.

**Tools** (`.claude/skills/internet-search/tools/`):
```
❓ EVALUATE (may delete):
├── message_handler.py - Diagnostic tool
├── subagent_tracker_anthropic.py - Tracked agent spawning
└── transcript_anthropic.py - Analyzed transcripts
```

**Decision**: Archive (don't delete) - may be useful for debugging.

---

### 7. DOCUMENTATION UPDATES

**CLAUDE.md** (`.claude/CLAUDE.md`):

**Update Sections**:
```markdown
## Available Agents (DELETE orchestrator agents)
- ❌ internet-light-orchestrator
- ❌ internet-deep-orchestrator
- ❌ internet-research-orchestrator

## Available Skills (UPDATE)
### Research (Automatic via Hook)
- ✅ tier-3-light-research - Lightweight parallel (2-3 dimensions)
- ✅ tier-4-deep-research - Comprehensive RBMAS (4+ dimensions)
- ✅ tier-5-novel-research - Adaptive TODAS (novel domains)

Note: Hook router automatically selects appropriate tier based on query analysis.

### Research Workers (No Change)
- web-researcher
- academic-researcher
- etc. (Tier 1-2 agents stay)
```

---

## File Movement Summary

### Phase 0: Backup

```bash
# Create timestamped backup
BACKUP_DIR="docs/implementation-backups/hook-migration-$(date +%Y%m%d)/"
mkdir -p "$BACKUP_DIR"

# Backup current state
cp -r .claude/skills/internet-search "$BACKUP_DIR/internet-search-v2.0-backup/"
cp .claude/agents/internet-light-orchestrator.md "$BACKUP_DIR/"
cp .claude/agents/internet-deep-orchestrator.md "$BACKUP_DIR/"
cp .claude/agents/internet-research-orchestrator.md "$BACKUP_DIR/"
cp .claude/CLAUDE.md "$BACKUP_DIR/"
```

### Phase 1: Hook Router Creation

```bash
# Create hook directory
mkdir -p .claude/hooks/pre-prompt/

# Create hook router (NEW FILE - use SKILL_TO_HOOK_CONVERSION_MAP.md)
# Source content from:
#   - internet-search/SKILL.md (Steps 2-5)
#   - internet-search/routing-logic-reference.md
#   - internet-search/research-agents-registry.json
#   - internet-search/confidence-scoring-guide.md

touch .claude/hooks/pre-prompt/internet-search-router.sh
chmod +x .claude/hooks/pre-prompt/internet-search-router.sh
```

### Phase 2: Tier 3 Skill Creation

```bash
# Create Tier 3 skill directory
mkdir -p .claude/skills/tier-3-light-research/

# Create Tier 3 skill (NEW FILE - use AGENT_TO_SKILL_CONVERSION_MAP.md)
# Source content from:
#   - .claude/agents/internet-light-orchestrator.md (main source)
#   - internet-search/SKILL.md (Step 0 - session management)

touch .claude/skills/tier-3-light-research/SKILL.md
```

### Phase 3: Tier 4 Skill Creation

```bash
# Create Tier 4 skill directory
mkdir -p .claude/skills/tier-4-deep-research/

# Copy supporting files (REUSE from internet-search)
cp -r .claude/skills/internet-search/agent-prompt-templates/ \
      .claude/skills/tier-4-deep-research/

cp -r .claude/skills/internet-search/json-schemas/ \
      .claude/skills/tier-4-deep-research/

# Create Tier 4 skill (NEW FILE - use AGENT_TO_SKILL_CONVERSION_MAP.md)
# Source content from:
#   - .claude/agents/internet-deep-orchestrator.md (main source)
#   - internet-search/SKILL.md (Steps 0, 7-13 - session, quality gates)

touch .claude/skills/tier-4-deep-research/SKILL.md
```

### Phase 4: Tier 5 Skill Creation

```bash
# Create Tier 5 skill directory
mkdir -p .claude/skills/tier-5-novel-research/

# Copy & adapt templates
cp .claude/skills/internet-search/agent-prompt-templates/research-agent-template.md \
   .claude/skills/tier-5-novel-research/research-subagent-template.md

# Copy schemas (partial)
mkdir -p .claude/skills/tier-5-novel-research/json-schemas/
cp .claude/skills/internet-search/json-schemas/research-output-schema.json \
   .claude/skills/tier-5-novel-research/json-schemas/
cp .claude/skills/internet-search/json-schemas/synthesis-schema.json \
   .claude/skills/tier-5-novel-research/json-schemas/

# Create Tier 5 skill (NEW FILE - use AGENT_TO_SKILL_CONVERSION_MAP.md)
# Source content from:
#   - .claude/agents/internet-research-orchestrator.md (main source)
#   - internet-search/SKILL.md (Step 0 - session management)

touch .claude/skills/tier-5-novel-research/SKILL.md
```

### Phase 6: Cleanup & Archive

```bash
# Archive old internet-search skill
mkdir -p .claude/skills/_archived/internet-search-v2.0-$(date +%Y%m%d)/
mv .claude/skills/internet-search/* \
   .claude/skills/_archived/internet-search-v2.0-$(date +%Y%m%d)/

# Create archive README
cat > .claude/skills/_archived/internet-search-v2.0-$(date +%Y%m%d)/ARCHIVE_README.md <<EOF
# Internet-Search Skill v2.0 (Archived)

**Archived**: $(date +%Y-%m-%d)
**Reason**: Replaced by hook-based routing architecture

## Migration

This skill was decomposed into:
1. Hook Router: .claude/hooks/pre-prompt/internet-search-router.sh
2. Tier 3 Skill: .claude/skills/tier-3-light-research/
3. Tier 4 Skill: .claude/skills/tier-4-deep-research/
4. Tier 5 Skill: .claude/skills/tier-5-novel-research/

## Rollback

To restore this skill:
\`\`\`bash
cp -r .claude/skills/_archived/internet-search-v2.0-$(date +%Y%m%d)/* \
      .claude/skills/internet-search/
\`\`\`

## Files Preserved

- SKILL.md (2162 lines) - Main skill logic
- research-agents-registry.json - Agent metadata
- routing-logic-reference.md - Routing rules
- agent-prompt-templates/ - Prompt templates (reused in Tier 4-5)
- json-schemas/ - JSON schemas (reused in Tier 4-5)
- All other supporting files

See docs/hook-migration-tests/FILE_ALLOCATION_MAP.md for full migration details.
EOF

# Delete obsolete agents
rm .claude/agents/internet-light-orchestrator.md
rm .claude/agents/internet-deep-orchestrator.md
rm .claude/agents/internet-research-orchestrator.md

# Update CLAUDE.md (remove orchestrator agents, add skills section)
# (Manual edit or scripted update)
```

---

## File Reuse Strategy

### Templates (agent-prompt-templates/)

**Tier 3**: ❌ Not needed (markdown output only)
**Tier 4**: ✅ **COPY** all 4 templates (spawns specialists)
**Tier 5**: ✅ **COPY** research-agent-template.md only (spawns generic workers)

**Rationale**:
- Tier 4 spawns web-researcher, academic-researcher, fact-checker, etc. → Needs all templates
- Tier 5 spawns research-subagent (generic) → Needs basic template only
- Tier 3 spawns light-research-researcher (no templates used, simple prompts)

### JSON Schemas (json-schemas/)

**Tier 3**: ❌ Not needed (markdown output only)
**Tier 4**: ✅ **COPY** all 4 schemas (structured JSON output)
**Tier 5**: ✅ **COPY** 2 schemas (research-output, synthesis only)

**Rationale**:
- Tier 4: Full quality gates (research + verification + citations + synthesis)
- Tier 5: Simplified (research + synthesis only)
- Tier 3: No JSON (saves to markdown directly)

### Registry (research-agents-registry.json)

**Hook Router**: ✅ **EMBED** as bash variables (simplified)
**Skills**: ❌ Not needed (skills don't route, hook does)

**Bash Conversion Example**:
```bash
# Embedded agent metadata (simplified from registry)
TIER1_AGENTS="web-researcher fact-checker citations-agent"
TIER2_SPECIALISTS=(
    "academic:academic-researcher"
    "market:market-researcher"
    "competitive:competitive-analyst"
    "trends:trend-analyst"
)
TIER3_SKILL="tier-3-light-research"
TIER4_SKILL="tier-4-deep-research"
TIER5_SKILL="tier-5-novel-research"
```

---

## Validation Checklist

### Pre-Migration

- [ ] Backup all files (Phase 0)
- [ ] Verify backup completeness (compare file counts)
- [ ] Document current state (git commit hash)

### During Migration

**Phase 1 (Hook)**:
- [ ] Hook router created with routing logic
- [ ] Bash functions tested standalone
- [ ] Agent registry embedded correctly

**Phase 2 (Tier 3)**:
- [ ] Skill created with session management
- [ ] No templates/schemas (not needed)
- [ ] Worker spawning pattern preserved

**Phase 3 (Tier 4)**:
- [ ] Skill created with quality gates
- [ ] All 4 templates copied
- [ ] All 4 schemas copied
- [ ] Specialist spawning logic intact

**Phase 4 (Tier 5)**:
- [ ] Skill created with adaptive logic
- [ ] 1 template copied (research-agent)
- [ ] 2 schemas copied (research, synthesis)
- [ ] Generic worker spawning logic intact

**Phase 6 (Cleanup)**:
- [ ] Internet-search skill archived
- [ ] Archive README created
- [ ] Orchestrator agents deleted
- [ ] CLAUDE.md updated
- [ ] Old hooks deleted

### Post-Migration

- [ ] Verify file counts match expectations
- [ ] Test hook router routing
- [ ] Test Tier 3 skill activation
- [ ] Test Tier 4 skill activation
- [ ] Test Tier 5 skill activation
- [ ] Rollback test (restore from archive)

---

## File Count Summary

### Before Migration

```
.claude/skills/internet-search/: ~35 files
.claude/agents/: 3 orchestrator agents
```

### After Migration

```
.claude/hooks/pre-prompt/: 1 hook router
.claude/skills/tier-3-light-research/: 1-2 files
.claude/skills/tier-4-deep-research/: ~11 files (skill + 4 templates + 4 schemas + readme)
.claude/skills/tier-5-novel-research/: ~5 files (skill + 1 template + 2 schemas + readme)
.claude/skills/_archived/internet-search-v2.0-YYYYMMDD/: ~36 files (complete archive)
.claude/agents/: 0 orchestrator agents (deleted)
```

**Total New Files**: ~18 production files + ~36 archived files

---

**Status**: File allocation map complete
**Dependencies**:
- SKILL_TO_HOOK_CONVERSION_MAP.md (how to convert)
- AGENT_TO_SKILL_CONVERSION_MAP.md (how to convert)
- This map (where files go)

**Ready for**: Implementation with complete file handling strategy
