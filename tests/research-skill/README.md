# Research Skill Tests

> **SOURCE**: multi-agent-research project (November 2025)
> **PURPOSE**: Test documentation for the multi-agent-researcher skill
> **STATUS**: Active reference for research skill testing

---

## Overview

Comprehensive testing documentation for the `multi-agent-researcher` skill. The tests cover:

- **5-Tier Research System**: Simple lookups to novel domain research
- **Hook-Based Routing**: UserPromptSubmit hook for query classification
- **Agent Orchestration**: Parallel researcher spawning and synthesis
- **Quality Gates**: Citation density, source diversity, fact-checking

---

## Directory Structure

```
tests/research-skill/
├── README.md                          # This file
├── manual/                            # Layer 3: Human evaluation tests
│   ├── README.md                     # Manual test documentation
│   ├── skill-execution-tests.md      # Skill activation, agent spawning
│   ├── edge-case-tests.md            # Error handling, edge cases
│   └── integration-test-report.md    # Real-world validation
├── phase-results/                     # Historical test results by phase
│   ├── PHASE1_TEST_RESULTS.md        # Hook router validation (32 queries)
│   ├── PHASE2_TEST_RESULTS.md        # Tier 3 skill (4 sessions, 15 subagents)
│   ├── PHASE3_TEST_RESULTS.md        # Tier 4 RBMAS (7-phase, 87.5% verification)
│   ├── PHASE4_TEST_RESULTS.md        # Tier 5 TODAS (agent spawning issues)
│   ├── PHASE5_INTEGRATION_RESULTS.md # Integration testing
│   ├── PHASE6_TESTING_COMPLETE.md    # End-to-end validation (5 tiers)
│   └── TIER3_TEST_FINDINGS.md        # Tier 3 failure analysis
├── design-docs/                       # Design and implementation docs
│   ├── DESIGN_DECISIONS.md           # 4 key design decisions
│   ├── IMPLEMENTATION_PLAN.md        # Full implementation plan (93KB)
│   ├── BASELINE_REPORT.md            # Pre-implementation baseline
│   ├── AGENT_TO_SKILL_CONVERSION_MAP.md
│   ├── SKILL_TO_HOOK_CONVERSION_MAP.md
│   ├── FILE_ALLOCATION_MAP.md
│   ├── DEPLOYMENT_INDEX.md
│   ├── PRODUCTION_DEPLOYMENT_ANALYSIS.md
│   └── PRODUCTION_DEPLOYMENT_EXECUTIVE_SUMMARY.md
├── test-scripts/                      # Executable test scripts
│   ├── phase1-test-queries.sh        # 32 router test queries (7 categories)
│   ├── production_validation.sh      # Production validation
│   ├── production_deploy_standard.sh # Deployment script
│   └── production_cleanup_inplace.sh # Cleanup script
├── lessons-learned/                   # Lessons and insights
│   ├── NEW_LESSONS_PHASE1-2.md       # 8 lessons from Phases 1-2
│   └── HONEST_ASSESSMENT_PRE_PHASE7.md
└── analysis/                          # Bug fixes and failure analysis
    ├── EMPIRICAL_TEST_RESULTS.md     # Hook input validation (21 captures)
    ├── ULTRA_DEEP_ANALYSIS_TEST2_FAILURE.md
    ├── FIX_APPROACHES_CRITICAL_ANALYSIS.md
    ├── DUPLICATE_HOOK_CALLS_FIX.md
    ├── DUPLICATE_HOOK_VALIDATION.md
    ├── PHASE6_CLEANUP_REPORT.md
    ├── PHASE6_IMPACT_ANALYSIS.md
    └── PHASE6_PRODUCTION_READINESS.md
```

---

## Key Test Categories

### 1. Phase Test Results

| Phase | Focus | Tests | Status |
|-------|-------|-------|--------|
| Phase 1 | Hook Router | 32 queries across 7 categories | ✅ PASSED |
| Phase 2 | Tier 3 (Light Parallel) | 4 sessions, 15 subagents | ✅ PASSED |
| Phase 3 | Tier 4 (RBMAS 7-phase) | Comprehensive research | ✅ PASSED |
| Phase 4 | Tier 5 (TODAS Adaptive) | Novel domain research | ⚠️ PARTIAL |
| Phase 5 | Integration | End-to-end flow | ✅ PASSED |
| Phase 6 | Validation | All 5 tiers | ✅ PASSED |

### 2. Research Tier System

| Tier | Complexity | Agents | Method |
|------|------------|--------|--------|
| 1 | Simple lookup | 1 web-researcher | Direct spawn |
| 2 | Specialist | 1 academic/search | Direct spawn |
| 3 | Light (2-4 dims) | 2-4 researchers + synthesizer | Skill orchestration |
| 4 | Comprehensive (4+) | 5-7 specialists + fact-checker | RBMAS 7-phase |
| 5 | Novel domain | Adaptive (1-7) | TODAS methodology |

### 3. Test Query Categories (Phase 1)

1. **Standard Queries** (4) - Basic research detection
2. **Queries with Quotes** (4) - JSON escaping validation
3. **Special Characters** (5) - Bash string handling
4. **Verb Derivatives** (10) - Pattern matching (researching, analyzed, etc.)
5. **Question Patterns** (3) - What/How/Why detection
6. **Phrase Patterns** (3) - "Find information", "Look up"
7. **Non-Research (Negative)** (3) - "Fix bug", "Commit changes"

---

## Lessons Learned Summary

From `lessons-learned/NEW_LESSONS_PHASE1-2.md`:

### Lessons #1-8 (Phase 1-2)

1. **Test automation AFTER restart** - Fresh session validates CLAUDE.md rules loaded
2. **Router needs non-research patterns** - Prevent false positives
3. **Check for pre-existing artifacts** - Verify before creating
4. **Comprehensive test evidence docs** - 200-400 line reports
5. **Git tags for milestones** - Annotated tags for reference
6. **User questions reveal gaps** - "Why isn't X working?" exposes issues
7. **Clean historical broken data** - When fixing bugs, clean artifacts
8. **No completion without fresh session test** - Automation must be proven

### Lessons #22-30 (Phase 4)

22. **Explicit agent type prohibition required**
23. **Verification phase criticality depends on domain**
24. **Skill examples must match actual usage**
25. **Agent registry should be explicitly linked**
26. **Specialist diversity ≠ specialist types**
27. **spawned_by matters for automation**
28. **User evidence-based validation is critical**
29. **"Parallel optimization" ≠ "Specialist team"**
30. **Ambiguous instructions enable incorrect behavior**

---

## Key Design Decisions

From `design-docs/DESIGN_DECISIONS.md`:

1. **Naming**: Use original agent names (internet-light-orchestrator, not tier-3-light-research)
2. **Language**: Imperative tone (MUST/SHALL/ALWAYS)
3. **Log Locations**: Production → hooks_logs/, Testing → docs/hook-migration-tests/
4. **Edge Case Testing**: 7 categories including quotes, special chars, verb derivatives

---

## Test Coverage Comparison

| Aspect | Planning Skill | Research Skill |
|--------|----------------|----------------|
| **Automated Tests** | ✅ 18+ tests | ✅ 32 queries in test scripts |
| **Phase Results** | ⚠️ Limited | ✅ PHASE1-6 documented |
| **Hook Router Tests** | ❌ Not implemented | ✅ 32 queries (7 categories) |
| **Tier/Agent Tests** | ✅ 3 agents | ✅ 5 tiers validated |
| **Lessons Learned** | ⚠️ To be documented | ✅ 30+ lessons |

---

## How to Use These Tests

### For Reference
- Review phase results to understand what was tested
- Read lessons learned before implementing similar features
- Use design decisions as patterns for future work

### For Implementation
- Test scripts can be adapted for current router hook
- Phase test checklists provide comprehensive validation templates
- Quality gate patterns applicable to any multi-agent system

### For Debugging
- Failure analyses document common issues
- Fix documentation shows root causes and solutions
- Empirical test results prove hook behavior patterns

---

## Important Notes

1. **File Paths**: Some files contain absolute paths from the original test environment. These are preserved as evidence with context headers.

2. **Test Scripts**: Scripts reference hooks and skills - adapt paths as needed for current project structure.

3. **Lessons Are Universal**: The lessons learned apply broadly to any Claude Code multi-agent orchestration system.

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-24 | Initial restoration from multi-agent-research project |

---

**Total Files**: 30
**Total Documentation**: ~500KB
**Phases Covered**: 0-7
**Lessons Documented**: 30+
