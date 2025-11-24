# Production Deployment: File Classification Analysis

**Date**: 2025-11-17
**Scope**: Comprehensive analysis for production deployment or clean copy creation
**Total Project Size**: 6.6MB (infrastructure + docs + archives)

---

## Executive Summary

### Current State
- **Total Files**: ~400 files (infrastructure, tests, research, archives)
- **.claude/ Size**: 884KB (includes 304KB archived)
- **docs/ Size**: 5.3MB (includes 3.2MB test/research outputs)
- **archive/ Size**: 464KB (complete duplicates)

### Recommended Actions
- **KEEP for Production**: 32 core files (580KB) - 8.8% of total
- **ARCHIVE for Reference**: 200+ files (3.7MB) - 56% of total
- **DELETE (in git history)**: 150+ files (1.3MB) - 20% of total
- **SELECTIVE KEEP**: Research outputs based on value

### Production-Ready Size
**Minimal**: ~580KB (core infrastructure only)
**Standard**: ~1.2MB (core + selected docs)
**Complete**: ~2.5MB (core + all valuable docs)

---

## Category 1: CORE PRODUCTION FILES (KEEP)

These files are **essential** for the system to function. **MUST keep** in production.

### A. Skills (8 files, ~160KB)

#### Tier 3-5 Orchestrators (KEEP ALL)
```
✅ .claude/skills/internet-light-orchestrator/SKILL.md
   Purpose: Tier 3 light parallel research (2-4 dimensions)
   Size: ~25KB
   Reason: Active orchestrator for standard multi-dimensional queries

✅ .claude/skills/internet-deep-orchestrator/SKILL.md
   Purpose: Tier 4 comprehensive RBMAS research (4+ dimensions)
   Size: ~45KB
   Reason: Active orchestrator for comprehensive established domain research

✅ .claude/skills/internet-research-orchestrator/SKILL.md
   Purpose: Tier 5 novel TODAS research (adaptive 1-7 agents)
   Size: ~75KB
   Reason: Active orchestrator for novel/emerging domain research
```

#### Requirements Management (KEEP)
```
✅ .claude/skills/spec-proposal-creation/SKILL.md
   Purpose: Create structured change proposals
   Size: ~15KB

✅ .claude/skills/spec-context-loading/SKILL.md
   Purpose: Load project context and existing specs

✅ .claude/skills/spec-implementation/SKILL.md
   Purpose: Execute approved specifications

✅ .claude/skills/spec-archiving/SKILL.md
   Purpose: Archive completed changes
```

#### Test/Deprecated (OPTIONAL)
```
⚠️ .claude/skills/test-skill-nesting/SKILL.md
   Purpose: Test skill nesting capability
   Decision: ARCHIVE (development testing only)
```

### B. Agents (11 files, ~110KB)

#### Specialist Research Agents (KEEP ALL 11)
```
✅ .claude/agents/web-researcher.md
   Purpose: Tier 1 simple queries, general web information
   Reason: Most frequently used specialist

✅ .claude/agents/academic-researcher.md
   Purpose: Tier 2, scholarly papers, peer-reviewed sources

✅ .claude/agents/search-specialist.md
   Purpose: Tier 2, complex boolean queries, deep investigation

✅ .claude/agents/trend-analyst.md
   Purpose: Tier 2, future forecasting, emerging trends

✅ .claude/agents/market-researcher.md
   Purpose: Tier 2, market sizing, TAM/SAM/SOM analysis

✅ .claude/agents/competitive-analyst.md
   Purpose: Tier 2, competitor profiling, SWOT analysis

✅ .claude/agents/synthesis-researcher.md
   Purpose: Tier 2, multi-source synthesis, pattern identification

✅ .claude/agents/fact-checker.md
   Purpose: Tier 1/2, claim verification, source validation
   Reason: MANDATORY for security/compliance domains

✅ .claude/agents/citations-agent.md
   Purpose: Tier 1, add citations to research reports

✅ .claude/agents/light-research-researcher.md
   Purpose: Tier 3 workers, parallel execution

✅ .claude/agents/light-research-report-writer.md
   Purpose: Tier 3 synthesizer, combines parallel findings
```

#### Deprecated/Test Agents (ARCHIVE)
```
⚠️ .claude/agents/research-subagent.md
   Status: DEPRECATED (use specialist agents instead)
   Decision: ARCHIVE with note to use specialists

⚠️ .claude/agents/test-spawner.md
   Purpose: Test agent-to-agent spawning
   Decision: ARCHIVE (development testing only)
```

#### Requirements Agents (KEEP)
```
✅ .claude/agents/requirements/spec-analyst.md
✅ .claude/agents/requirements/spec-architect.md
✅ .claude/agents/requirements/spec-orchestrator.md
✅ .claude/agents/requirements/spec-planner.md
✅ .claude/agents/requirements/spec-validator.md
```

#### Registry (KEEP)
```
✅ .claude/agents/agent_registry.json
   Purpose: Authoritative registry of all 11 specialist agents
   Size: ~15KB
   Reason: Referenced by router and skills for capability lookup
```

### C. Hooks (4 files, ~20KB)

```
✅ .claude/hooks/user-prompt-submit/internet-search-router.sh
   Purpose: Query analysis and automatic tier routing
   Size: ~11KB
   Reason: Core routing infrastructure

✅ .claude/hooks/monitoring/pre_tool_use.sh
   Purpose: Log tool calls before execution
   Size: ~3.4KB
   Reason: Monitoring and debugging

✅ .claude/hooks/monitoring/post_tool_use.sh
   Purpose: Log tool completion, errors, token usage
   Size: ~2.1KB
   Reason: Monitoring and debugging

✅ .claude/hooks/monitoring/subagent_stop.sh
   Purpose: Track agent lifecycle
   Size: ~2.7KB
   Reason: Agent spawn/stop tracking
```

### D. Configuration (2 files, ~5KB)

```
✅ .claude/CLAUDE.md
   Purpose: Project-specific Claude Code instructions
   Size: ~4KB
   Reason: Documents routing directive automation, agent usage workflows

❓ .claude/settings.json
   Purpose: Claude Code settings
   Decision: REVIEW - may contain local paths

❌ .claude/settings.local.json
   Purpose: User-specific local settings
   Decision: DELETE - user-specific, not for production
```

### E. Documentation (SELECTIVE KEEP)

```
✅ .claude/agents/README.md
   Purpose: Agent overview and categorization
   Reason: Helps users understand specialist agents

✅ .claude/hooks/README.md
   Purpose: Hook infrastructure explanation
   Reason: Documents hook behavior

⚠️ .claude/agents/requirements/LESSONS_LEARNED.md
   Purpose: Requirements workflow lessons
   Decision: ARCHIVE (development history)
```

---

## Category 2: TESTING & VALIDATION (ARCHIVE)

These files document testing but aren't needed for production operation. **Recommend archiving** for reference.

### A. Phase Testing Documents (19 files, ~720KB)

**Location**: `docs/hook-migration-tests/`

```
📦 ARCHIVE - Testing Documentation
├── HONEST_ASSESSMENT_PRE_PHASE7.md ⭐ (KEEP - honest review)
├── PHASE6_PRODUCTION_READINESS.md ⭐ (KEEP - production status)
├── PHASE6_TESTING_COMPLETE.md ⭐ (KEEP - validation proof)
├── IMPLEMENTATION_PLAN.md (6-phase plan)
├── PHASE1_TEST_RESULTS.md
├── PHASE2_TEST_RESULTS.md
├── PHASE3_TEST_RESULTS.md
├── PHASE4_TEST_RESULTS.md
├── PHASE5_INTEGRATION_RESULTS.md
├── PHASE6_CLEANUP_REPORT.md
├── BASELINE_REPORT.md
├── DESIGN_DECISIONS.md
├── FILE_ALLOCATION_MAP.md
├── FIX_APPROACHES_CRITICAL_ANALYSIS.md
├── NEW_LESSONS_PHASE1-2.md
├── ULTRA_DEEP_ANALYSIS_TEST2_FAILURE.md
├── AGENT_TO_SKILL_CONVERSION_MAP.md
├── SKILL_TO_HOOK_CONVERSION_MAP.md
└── PHASE6_IMPACT_ANALYSIS.md
```

**Recommendation**:
- **KEEP Top 3**: Honest assessment, production readiness, testing complete
- **ARCHIVE Rest**: Move to `docs/archive/phase-testing/`
- **Size Impact**: 720KB → 100KB (keep) + 620KB (archive)

### B. Test Execution Files (3 files, ~20KB)

```
📦 ARCHIVE - Test Scripts
├── docs/hook-migration-tests/phase1-test-queries.sh
├── docs/hook-migration-tests/router-log.jsonl (cleaned)
└── docs/hook-migration-tests/router-log-broken.jsonl (pre-cleanup)
```

**Recommendation**: Archive all (historical record only)

### C. Monitoring Logs (3 files, ~7MB in hooks_logs/)

```
❌ DELETE - Logs (regenerated in production)
├── hooks_logs/tool_calls.jsonl (7.1MB)
├── hooks_logs/agent_mapping.jsonl (17KB)
├── hooks_logs/agent_start_log.jsonl (17KB)
├── hooks_logs/allocation-decision.json (19KB)
└── hooks_logs/allocation-decision-summary.json (768B)
```

**Recommendation**: DELETE ALL
- Reason: Logs are .gitignored, regenerated at runtime
- Production starts with empty hooks_logs/
- Keep directory structure, delete contents

---

## Category 3: BACKUPS & ARCHIVES (DELETE)

These are complete duplicates already in git history. **Safe to delete**.

### A. Git History Backups (DELETE ALL)

```
❌ DELETE - archive/ (464KB total)
├── claude_backup_20251113_143637/ (complete .claude copy)
│   ├── agents/ (23 files)
│   ├── archive/ (old routing agent)
│   └── research-backup-20251112194800/ (v1.0 backup)
└── [ALL subdirectories and files]
```

**Reason**: Complete duplicates of files already in git history
**Git Safety**: Can recover from commits if needed

### B. Implementation Backups (DELETE ALL)

```
❌ DELETE - docs/implementation-backups/ (504KB total)
├── hook-migration-20251116_200811/ (Phase 2-4 backup)
│   ├── CLAUDE.md
│   ├── internet-deep-orchestrator.md
│   ├── internet-light-orchestrator.md
│   ├── internet-research-orchestrator.md
│   └── internet-search-v2.0-backup/ (70 files)
└── phase-6-cleanup-20251117_153705/ (Phase 6 backup)
    ├── internet-deep-orchestrator.md
    ├── internet-light-orchestrator.md
    └── internet-research-orchestrator.md
```

**Reason**: Duplicates of files already in git (commits 5973b9e, c186cc4, dee6e16)
**Git Recovery**: All content in commit history

### C. Archived Skills (DELETE)

```
❌ DELETE - .claude/skills/_archived/ (304KB)
└── internet-search-v2.0-20251117/ (70 files)
    ├── SKILL.md (v2.0 monolithic skill)
    ├── hooks/ (7 hook scripts + 4 docs)
    ├── json-schemas/ (4 schemas)
    ├── agent-prompt-templates/ (4 templates)
    ├── routing-examples/ (4 tier examples)
    └── [6 reference docs]
```

**Reason**: Superseded by Tier 3-5 skills (internet-{light,deep,research}-orchestrator)
**Git Recovery**: Available in commit history

---

## Category 4: RESEARCH OUTPUTS (SELECTIVE KEEP)

**Location**: `docs/research-sessions/` (2.5MB, 188 files across 40+ sessions)

### Analysis Strategy

```
KEEP IF:
- ✅ Demonstrates system capabilities
- ✅ Provides value as examples
- ✅ Referenced in documentation
- ✅ Recent (Nov 14-17, 2025)

DELETE IF:
- ❌ Early testing (Nov 13 WebRTC tests)
- ❌ Duplicate queries (same topic researched multiple times)
- ❌ Failed/incomplete research
- ❌ Development testing artifacts
```

### Recommended Keep (10-15 sessions, ~500KB)

**High-Value Examples**:
```
✅ 17112025_000001_notification_sync_distributed_systems/
   Purpose: Tier 5 TODAS academic research example
   Quality: 12 peer-reviewed papers (2020-2025), CRDT theory
   Size: ~30KB

✅ 17112025_133015_ai_notification_2026/
   Purpose: Tier 5 TODAS trend forecasting example
   Quality: 5 emerging AI approaches for 2026
   Size: ~25KB

✅ 17112025_153045_superapp_notifications_2026/
   Purpose: Tier 5 TODAS platform evolution forecast
   Quality: 3 scenario probabilities, weak signals
   Size: ~30KB

✅ 17112025_test3_miniapp_consent/
   Purpose: Tier 3 light parallel orchestration example
   Quality: 4 parallel researchers + synthesizer
   Size: ~40KB

✅ 16112025_221009_mini_apps_super_apps_notifications/
   Purpose: Tier 3 light parallel with synthesis
   Quality: 5 dimensions researched, comprehensive synthesis
   Size: ~50KB

✅ 16112025_210147_restarted_research_webrtc_security_in_terms_of_enc/
   Purpose: Tier 3 light parallel (encryption + authentication)
   Quality: Clean 3-dimension research
   Size: ~35KB

✅ 15112025_215936_webrtc_adoption_trends_enterprise_3years/
   Purpose: Tier 2 specialist (trend-analyst)
   Quality: 3-year enterprise adoption forecast
   Size: ~20KB

✅ 15112025_000539_super_app_trends_2025_2027/
   Purpose: Tier 2 specialist (trend-analyst)
   Quality: Super app evolution trends
   Size: ~18KB

✅ 14112025_232822_rest_vs_graphql_api/
   Purpose: Tier 3 light parallel comparison
   Quality: 2-dimension technical comparison
   Size: ~25KB

✅ 14112025_224007_push_notification_fcm_apns/
   Purpose: Tier 3 light parallel (FCM + APNs)
   Quality: Platform-specific research + synthesis
   Size: ~30KB
```

**Subtotal**: ~300KB (10 high-value sessions)

### Recommended Delete (~2.0MB)

**Early Testing** (Delete):
```
❌ 13112025_110621_webrtc-definition/ (early Tier 1 test)
❌ 13112025_113154_stun-server-definition/ (early test)
❌ 13112025_133341_webrtc-definition/ (duplicate)
❌ 13112025_135430_webrtc-tier0-test/ (tier 0 doesn't exist)
```

**Duplicate Topics** (Delete):
```
❌ 14112025_173000_webrtc/ (5+ WebRTC sessions exist)
❌ 15112025_210939_webrtc/ (duplicate)
❌ 15112025_215311_webrtc/ (duplicate)
❌ 16112025_092539_mini_app_notification_arch_delivery/ (7 attempts)
❌ 16112025_093252_mini_app_notification_arch_delivery/
❌ 16112025_122732_mini_app_notification_arch_delivery/
❌ 16112025_125051_mini_app_notification_arch_delivery/
❌ 16112025_175550_mini_app_notification_arch_delivery/
```

**Failed/Incomplete** (Delete):
```
❌ 15112025_000000_emerging_tech_convergence_super_app/ (incomplete)
❌ 15112025_140000_emerging_tech_convergence_retest/ (no output)
❌ 16112025_010536_mini_app_privacy_performance/ (empty .meta.json only)
❌ 16112025_140700_tier3_orchestration_test/ (test, not real research)
❌ 16112025_180750_tier3_direct_spawn_test/ (test, not real research)
```

**Experimental/Quantum** (Delete - speculative):
```
❌ 15112025_172249_quantum_webrtc_crypto/ (too speculative)
❌ 15112025_172534_quantum_resistant_cryptography_webrtc_security/
❌ 15112025_174834_webrtc_decentralized_identity_did_convergence/
```

---

## Category 5: DOCUMENTATION (SELECTIVE KEEP)

### A. Top-Level Docs (SELECTIVE)

```
✅ README.md
   Purpose: Project overview
   Decision: KEEP - update for production

⚠️ VERIFICATION_REPORT.md + VERIFICATION_REPORT copy.md
   Purpose: Early verification testing
   Decision: ARCHIVE (early development, superseded by Phase 6 reports)

❌ competitive_intelligence_extensibility_systems.md
   Purpose: Early brainstorming doc
   Decision: DELETE (not relevant to RTC mobile project)
```

### B. Analysis Documents (ARCHIVE)

**Location**: `docs/` (root level, ~1.5MB)

```
📦 ARCHIVE - Analysis Documents
├── AGENT_SPAWNING_ARCHITECTURE.md
├── AGENT_START_LOG_INVESTIGATION.md
├── FALSE_INVESTIGATION_ROOT_CAUSE.md
├── MCP_vs_Skills_Technical_Comparison.md
├── ORCHESTRATION_TIMELINE_ANALYSIS.md
├── PHASE3_ANALYSIS.md
├── ULTRA_DEEP_ANALYSIS_ALL_3_ORCHESTRATORS.md
├── ULTRA_DEEP_ANALYSIS_ORCHESTRATOR_INSTRUCTIONS.md
├── ULTRA_INVESTIGATION_TIER5_HONEST_REPORT.md
├── agent-spawning-test-results.md
├── orchestrator-enforcement-solution.md
├── notification-research-00-EXECUTIVE-SUMMARY.md
├── notification-research-01-architecture.md
├── notification-research-02-scalability.md
├── notification-research-03-providers.md
├── notification-research-04-channels.md
├── notification-research-05-multiapp.md
├── notification-research-06-flexibility.md
├── notification_system_architecture_diagram.md
├── notification_system_architecture_research.md
├── notification_system_quick_reference.md
├── competitive-analysis-mini-app-notifications.md
├── mini-app-notification-architecture-comprehensive-report.md (⭐ 12K words, KEEP)
└── mini-app-push-notification-protocols-technical-specs.md
```

**Recommendation**:
- **KEEP**: mini-app-notification-architecture-comprehensive-report.md (Test 4 output)
- **ARCHIVE**: All analysis documents (development history)
- **Size**: 1.5MB → 150KB (keep) + 1.35MB (archive)

### C. Architecture Docs (ARCHIVE)

**Location**: `docs/architecture/`

```
📦 ARCHIVE - Architecture Analysis
├── INVESTIGATION_SUMMARY.md
├── architecture_analysis.md
├── hook_based_orchestration_proposal.md
└── skill_nesting_investigation.md
```

**Recommendation**: Archive all (historical design decisions)

### D. Agent Configuration Docs (ARCHIVE)

**Location**: `agents-and-config/`

```
📦 ARCHIVE - Agent Configuration Research
├── 00_MCP_SETUP.md
├── 01_agents_overview.md
├── 02_mcp_requirements.md
├── 03_agent_expansion_analysis.md
└── 04_research_agents_deep_dive.md
```

**Recommendation**: Archive all (pre-Phase 1 research)

---

## Production File Structure

### Minimal Production Deployment (~580KB)

```
rtc_mobile/
├── .claude/
│   ├── CLAUDE.md                                    # Core instructions
│   ├── settings.json                                # Project settings (review paths)
│   ├── agents/
│   │   ├── agent_registry.json                      # 11 specialist registry
│   │   ├── web-researcher.md
│   │   ├── academic-researcher.md
│   │   ├── search-specialist.md
│   │   ├── trend-analyst.md
│   │   ├── market-researcher.md
│   │   ├── competitive-analyst.md
│   │   ├── synthesis-researcher.md
│   │   ├── fact-checker.md
│   │   ├── citations-agent.md
│   │   ├── light-research-researcher.md
│   │   ├── light-research-report-writer.md
│   │   └── requirements/                            # 5 spec agents
│   │       ├── spec-analyst.md
│   │       ├── spec-architect.md
│   │       ├── spec-orchestrator.md
│   │       ├── spec-planner.md
│   │       └── spec-validator.md
│   ├── hooks/
│   │   ├── user-prompt-submit/
│   │   │   └── internet-search-router.sh            # Query router
│   │   └── monitoring/
│   │       ├── pre_tool_use.sh
│   │       ├── post_tool_use.sh
│   │       └── subagent_stop.sh
│   └── skills/
│       ├── internet-light-orchestrator/
│       │   └── SKILL.md                             # Tier 3
│       ├── internet-deep-orchestrator/
│       │   └── SKILL.md                             # Tier 4
│       ├── internet-research-orchestrator/
│       │   └── SKILL.md                             # Tier 5
│       ├── spec-proposal-creation/
│       │   ├── SKILL.md
│       │   ├── templates/
│       │   │   ├── proposal.md
│       │   │   ├── spec-delta.md
│       │   │   └── tasks.md
│       │   └── reference/
│       │       ├── EARS_FORMAT.md
│       │       └── VALIDATION_PATTERNS.md
│       ├── spec-context-loading/SKILL.md
│       ├── spec-implementation/SKILL.md
│       └── spec-archiving/SKILL.md
├── hooks_logs/                                      # Empty (created at runtime)
├── docs/
│   └── research-sessions/                           # 10 high-value examples (~300KB)
├── .mcp.json                                        # MCP configuration
└── README.md                                        # Updated for production
```

### Standard Production Deployment (~1.2MB)

Minimal + Selected Documentation:

```
rtc_mobile/
├── [All files from Minimal]
└── docs/
    ├── research-sessions/                           # 10 high-value examples
    ├── hook-migration-tests/
    │   ├── HONEST_ASSESSMENT_PRE_PHASE7.md          # Critical review
    │   ├── PHASE6_PRODUCTION_READINESS.md           # Production status
    │   └── PHASE6_TESTING_COMPLETE.md               # Validation proof
    └── mini-app-notification-architecture-comprehensive-report.md  # Test 4 output
```

### Complete Archival Copy (~6.6MB)

Everything including archives and all test results (for reference/audit).

---

## Clean Copy Creation Instructions

### Option A: Minimal Production Copy

```bash
# Create new clean directory
mkdir -p rtc_mobile_production
cd rtc_mobile_production

# Copy core infrastructure
cp -r /path/to/rtc_mobile/.claude .
cp /path/to/rtc_mobile/.mcp.json .
cp /path/to/rtc_mobile/README.md .

# Remove archived/deprecated from .claude
rm -rf .claude/skills/_archived
rm -f .claude/settings.local.json
rm -f .claude/agents/test-spawner.md
rm -f .claude/agents/research-subagent.md
rm -rf .claude/agents/requirements/LESSONS_LEARNED.md
rm -f .claude/skills/test-skill-nesting/SKILL.md

# Create hooks_logs directory (empty)
mkdir -p hooks_logs

# Copy selected research examples (optional)
mkdir -p docs/research-sessions
# ... copy 10 high-value sessions manually

# Review and update README.md for production
```

**Result**: ~580KB production-ready system

### Option B: Standard Production Copy

```bash
# Start with Minimal (above)
# Then add documentation

mkdir -p docs/hook-migration-tests

# Copy key docs
cp /path/to/rtc_mobile/docs/hook-migration-tests/HONEST_ASSESSMENT_PRE_PHASE7.md docs/hook-migration-tests/
cp /path/to/rtc_mobile/docs/hook-migration-tests/PHASE6_PRODUCTION_READINESS.md docs/hook-migration-tests/
cp /path/to/rtc_mobile/docs/hook-migration-tests/PHASE6_TESTING_COMPLETE.md docs/hook-migration-tests/

# Copy comprehensive report
cp /path/to/rtc_mobile/docs/mini-app-notification-architecture-comprehensive-report.md docs/
```

**Result**: ~1.2MB with essential documentation

### Option C: Archive Existing Project (In-Place Cleanup)

```bash
cd /path/to/rtc_mobile

# Create archive directory
mkdir -p _ARCHIVED_$(date +%Y%m%d)

# Move archives
mv archive _ARCHIVED_*/
mv docs/implementation-backups _ARCHIVED_*/
mv .claude/skills/_archived _ARCHIVED_*/

# Move test files (keep top 3 docs)
mkdir -p _ARCHIVED_*/hook-migration-tests
mv docs/hook-migration-tests/* _ARCHIVED_*/hook-migration-tests/
# Restore top 3
mv _ARCHIVED_*/hook-migration-tests/HONEST_ASSESSMENT_PRE_PHASE7.md docs/hook-migration-tests/
mv _ARCHIVED_*/hook-migration-tests/PHASE6_PRODUCTION_READINESS.md docs/hook-migration-tests/
mv _ARCHIVED_*/hook-migration-tests/PHASE6_TESTING_COMPLETE.md docs/hook-migration-tests/

# Move old research sessions (keep selected 10)
mkdir -p _ARCHIVED_*/research-sessions
mv docs/research-sessions/* _ARCHIVED_*/research-sessions/
# Restore 10 high-value sessions manually

# Move analysis docs
mkdir -p _ARCHIVED_*/docs
mv docs/AGENT_*.md _ARCHIVED_*/docs/
mv docs/ORCHESTRATION_*.md _ARCHIVED_*/docs/
mv docs/PHASE3_ANALYSIS.md _ARCHIVED_*/docs/
mv docs/ULTRA_*.md _ARCHIVED_*/docs/
# ... move other analysis docs

# Move old config research
mv agents-and-config _ARCHIVED_*/

# Delete logs (regenerated at runtime)
rm -rf hooks_logs/*
# Keep directory
mkdir -p hooks_logs

# Delete deprecated agents
rm -f .claude/agents/test-spawner.md
rm -f .claude/agents/research-subagent.md
rm -f .claude/skills/test-skill-nesting/SKILL.md

# Compress archive
tar -czf archived_$(date +%Y%m%d).tar.gz _ARCHIVED_*
rm -rf _ARCHIVED_*
```

**Result**: Clean working directory + archived backup

---

## Migration Checklist

### Pre-Migration

- [ ] **Git commit all work** (safety net)
  ```bash
  git add -A
  git commit -m "chore: Pre-production-cleanup checkpoint"
  git tag pre-production-cleanup
  ```

- [ ] **Backup database** (if applicable)
- [ ] **Document current version**
  - Note git commit hash
  - Note current tag (e.g., `phase-6-production-ready`)

### During Migration

- [ ] **Choose deployment option** (Minimal, Standard, or In-Place Archive)
- [ ] **Execute cleanup commands** (see options above)
- [ ] **Verify core files present**
  - [ ] 8 active skills
  - [ ] 11 specialist agents + agent_registry.json
  - [ ] 4 hooks (router + 3 monitoring)
  - [ ] CLAUDE.md instructions

- [ ] **Review configuration files**
  - [ ] .claude/settings.json (no local paths)
  - [ ] .mcp.json (MCP server config)
  - [ ] README.md (updated for production)

- [ ] **Create empty runtime directories**
  ```bash
  mkdir -p hooks_logs
  mkdir -p docs/research-sessions
  ```

### Post-Migration

- [ ] **Test core functionality**
  - [ ] Query router works (check router-log.jsonl after query)
  - [ ] Tier 1 query routes to web-researcher
  - [ ] Tier 3 query routes to internet-light-orchestrator
  - [ ] Hooks write logs to hooks_logs/

- [ ] **Verify hooks execute without errors**
  - [ ] Run test query
  - [ ] Check hooks_logs/tool_calls.jsonl exists
  - [ ] Check router-log.jsonl has entry

- [ ] **Document production version**
  ```bash
  git add -A
  git commit -m "chore: Production deployment structure"
  git tag production-v1.0-$(date +%Y%m%d)
  ```

- [ ] **Update README.md**
  - Production deployment instructions
  - Known issues (hook UI errors)
  - User guides (when available from Phase 7)

---

## Size Comparison

| Configuration | Size | Files | Description |
|---------------|------|-------|-------------|
| **Current** | 6.6MB | ~400 | All files (infrastructure + tests + archives) |
| **Minimal** | 580KB | 32 | Core infrastructure only |
| **Standard** | 1.2MB | 45 | Core + key docs |
| **With Examples** | 1.5MB | 55 | Standard + 10 research examples |
| **Complete Archive** | 6.6MB | ~400 | Everything (audit trail) |

---

## Decision Matrix

### Use MINIMAL if:
- ✅ Production environment (cloud, containers)
- ✅ Want smallest footprint
- ✅ Documentation hosted separately
- ✅ Familiar with system already

### Use STANDARD if:
- ✅ Self-contained deployment
- ✅ Need proof of testing (Phase 6 docs)
- ✅ Want honest assessment available
- ✅ Team needs reference docs

### Use WITH EXAMPLES if:
- ✅ Training new users
- ✅ Need demonstration of capabilities
- ✅ Want to show tier differences
- ✅ Documentation includes examples

### Keep COMPLETE ARCHIVE if:
- ✅ Audit requirements
- ✅ Historical reference needed
- ✅ Regulatory compliance
- ✅ Want full development history

---

## Recommendations

### For Production Deployment
**Use STANDARD** configuration (1.2MB):
- Core infrastructure (580KB)
- Key validation docs (100KB)
- Comprehensive report example (150KB)
- Selected research examples (300KB)

**Rationale**:
- Self-contained and complete
- Proof of testing included
- Examples for troubleshooting
- Not bloated with archives

### For Clean Development Copy
**Use WITH EXAMPLES** configuration (1.5MB):
- Everything from Standard
- 10 high-value research sessions
- Demonstrates all 5 tiers
- Training material included

### For Archive/Audit
**Keep COMPLETE** in separate location:
- Compress archive (tar.gz)
- Store on backup server
- Label with date and git commit
- Keep for 1-2 years for reference

---

## File-by-File Quick Reference

### DEFINITE KEEP (32 files, 580KB)
```
Core Infrastructure:
- 8 skills (3 orchestrators + 5 spec management)
- 11 specialist agents
- 5 requirements agents
- 1 agent_registry.json
- 4 hooks
- 1 CLAUDE.md
- 1 .mcp.json
- 1 README.md (updated)
```

### DEFINITE DELETE (150+ files, 1.3MB)
```
Backups (all in git history):
- archive/* (complete duplicate)
- docs/implementation-backups/* (git commits)
- .claude/skills/_archived/* (superseded)

Logs (regenerated):
- hooks_logs/* (all .jsonl files)

Deprecated:
- .claude/settings.local.json
- .claude/agents/test-spawner.md
- .claude/agents/research-subagent.md
- .claude/skills/test-skill-nesting/SKILL.md

Early Testing:
- 13112025_* research sessions (Nov 13 tests)
- VERIFICATION_REPORT*.md (early reports)
- competitive_intelligence_extensibility_systems.md
```

### SELECTIVE ARCHIVE (200+ files, 3.7MB)
```
Test Documentation (keep top 3):
- docs/hook-migration-tests/* (18 files → keep 3)

Research Sessions (keep 10):
- docs/research-sessions/* (40 sessions → keep 10)

Analysis Docs (archive all):
- docs/*.md (15 analysis docs)
- docs/architecture/* (4 docs)
- agents-and-config/* (5 docs)
```

---

## Next Steps

1. **Review this analysis** with stakeholders
2. **Choose deployment configuration** (Minimal, Standard, or With Examples)
3. **Execute migration** using provided commands
4. **Test production deployment** (run test queries)
5. **Update documentation** (README.md, production notes)
6. **Create production tag** (`production-v1.0-YYYYMMDD`)

---

**Created**: 2025-11-17
**Analyst**: Claude Code (Ultra-Deep Analysis)
**Estimated Time to Clean**: 30-60 minutes (depending on configuration)
**Risk Level**: LOW (all files in git history, can revert)
