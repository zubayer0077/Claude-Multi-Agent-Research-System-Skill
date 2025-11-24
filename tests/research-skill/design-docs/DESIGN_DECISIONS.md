# Design Decisions & Preferences

**Document Purpose**: Formal record of all user-confirmed preferences and design decisions for the hook-based migration (Phases 0-7).

**Created**: 2025-11-16
**Phase**: 0.5 (Design Decisions & Preferences)
**Status**: ✅ COMPLETE - All 4 decisions documented and confirmed

---

## Decision 1: Naming Conventions

### Question
"Do you prefer tier-based naming (tier-3-light-research, tier-4-deep-research, tier-5-novel-research) or original agent names (internet-light-orchestrator, internet-deep-orchestrator, internet-research-orchestrator)?"

### Decision
**Use original agent names when converting agents to skills**

### Examples
- ✅ `internet-light-orchestrator` (Phase 2)
- ✅ `internet-deep-orchestrator` (Phase 3)
- ✅ `internet-research-orchestrator` (Phase 4)
- ❌ `tier-3-light-research` (NOT used)
- ❌ `tier-4-deep-research` (NOT used)
- ❌ `tier-5-novel-research` (NOT used)

### Rationale
User feedback: **"I prefer to keep the original name to avoid further confusion"** (Phase 2, 2025-11-16)

### Applies To
- Phase 2: internet-light-orchestrator skill conversion
- Phase 3: internet-deep-orchestrator skill conversion
- Phase 4: internet-research-orchestrator skill conversion
- All skill references in hook router directives
- All skill references in documentation

### Implementation Impact
- Hook router directive (Phase 1): MUST reference `internet-light-orchestrator` (NOT `tier-3-light-research`)
- Skill directory names: `.claude/skills/internet-light-orchestrator/` (etc.)
- Skill SKILL.md name field: `internet-light-orchestrator` (etc.)
- CLAUDE.md documentation: Uses original names in all skill listings

---

## Decision 2: Language Style

### Question
"Confirm: Do you prefer imperative tone (MUST/SHALL/ALWAYS) or advisory tone (recommend/suggest/guide) in skill instructions?"

### Decision
**Use imperative tone (MUST/SHALL/ALWAYS) in all skill instructions**

### Examples
- ✅ "Main Claude MUST invoke internet-search skill for research queries"
- ✅ "The skill SHALL spawn agents using the Task tool"
- ✅ "ALWAYS use jq for JSON generation"
- ❌ "We recommend invoking the internet-search skill" (NOT used)
- ❌ "Consider using the Task tool to spawn agents" (NOT used)
- ❌ "It's suggested to use jq for JSON" (NOT used)

### Rationale
User explicitly stated: **"I prefer the imperative tone"** (Phase 2 verification, 2025-11-16)

### Applies To
- All skill delegation rules (SKILL.md files)
- Workflow instructions in skills
- Requirements and constraints in skills
- Hook router directive language
- Implementation plan task descriptions

### Implementation Impact
- Skill SKILL.md files: Use MUST/SHALL/ALWAYS for requirements
- Hook router directives: Imperative instructions to Main Claude
- Testing checklists: Clear mandatory requirements (not suggestions)

---

## Decision 3: Log Locations

### Question
"Where should logs be written for production vs testing scenarios?"

### Decision
**Separate log locations for production and migration/testing**

### Log Location Standards

#### Production Logs
- **Location**: `hooks_logs/`
- **Purpose**: Operational monitoring of production hook system
- **Files**:
  - `hooks_logs/tool_calls.jsonl` - PreToolUse/PostToolUse monitoring
  - `hooks_logs/agent_mapping.jsonl` - SubagentStop monitoring
  - `hooks_logs/errors.log` - Error tracking
- **Applies to**: All monitoring hooks (pre_tool_use.sh, post_tool_use.sh, subagent_stop.sh)

#### Migration/Testing Logs
- **Location**: `docs/hook-migration-tests/`
- **Purpose**: Testing, validation, migration artifacts
- **Files**:
  - `docs/hook-migration-tests/router-log.jsonl` - UserPromptSubmit router decisions
  - `docs/hook-migration-tests/test-results/` - Phase testing outputs
  - `docs/hook-migration-tests/validation-logs/` - Validation command outputs
- **Applies to**: Router logging, test artifacts, validation results

### Rationale
User confusion when logs went to migration directory instead of production: **Monitoring hooks should write to operational location, not test directory** (Phase 2, 2025-11-16)

### Applies To
- Phase 1: Router logging → `docs/hook-migration-tests/router-log.jsonl`
- Phases 2-4: Monitoring hooks → `hooks_logs/` (production)
- Phase 5: Integration testing → `docs/hook-migration-tests/test-results/`
- Phase 7: Final validation → `docs/hook-migration-tests/validation-logs/`

### Implementation Impact
- Hook scripts MUST use correct log paths
- Testing checklists verify logs in correct locations
- Rollback procedures account for separate log locations
- Documentation clearly distinguishes production vs testing logs

---

## Decision 4: Edge Case Testing Scope

### Question
"What edge cases should be tested to ensure robust query detection and routing?"

### Decision
**Comprehensive edge case testing including quotes, special characters, verb derivatives, and long queries**

### Edge Case Test Queries

#### 1. Standard Queries (Baseline)
**Purpose**: Verify normal operation with clean inputs

- "Research WebRTC security"
- "Analyze cloud gaming latency optimization"
- "What is quantum computing?"
- "Investigate machine learning trends"

#### 2. Queries with Quotes
**Purpose**: Test JSON escaping and quote handling

- `"Research \"quantum computing\" applications"`
- `"What is \"WebRTC\" and how does it work?"`
- `"Analyze 'edge computing' vs 'cloud computing'"`
- `"I want to learn about \"mini-apps\" in super-apps"`

**Critical**: These queries broke JSON logging in Phase 2 before jq-based logging was implemented. MUST pass validation.

#### 3. Special Characters
**Purpose**: Test bash string handling and JSON escaping

- `"Analyze cost & benefit"`
- `"Research C++ vs Rust performance"`
- `"What is $PATH in bash?"`
- `"Investigate @mentions and #hashtags"`
- `"Research APIs: REST, GraphQL, gRPC"`

#### 4. Long Queries (50+ words)
**Purpose**: Test query analysis with complex multi-clause inputs

```
"Research WebRTC security comprehensively across multiple dimensions including
cryptographic protocols like DTLS and SRTP, network security concerns such as
ICE and TURN server vulnerabilities, implementation security in major browsers
Chrome Firefox and Safari, authentication mechanisms, and common attack vectors
documented in academic literature and industry security reports from 2023-2025"
```

**Expected**: Router should detect multiple dimensions (4+) and route to Tier 4 (comprehensive)

#### 5. Verb Derivatives
**Purpose**: Test enhanced detection patterns (20+ verb forms)

- `"searching machine learning"` (present progressive)
- `"researching WebRTC protocols"` (present progressive)
- `"exploring quantum algorithms"` (present progressive)
- `"gathering data about cloud platforms"` (present progressive)
- `"studied blockchain security"` (past tense)
- `"analyzed market trends"` (past tense)
- `"discovers new techniques"` (present tense, third person)

**Critical**: Phase 2 enhancement added 20+ verb derivatives. MUST detect all forms correctly.

#### 6. Ambiguous/Inflated Keywords
**Purpose**: Test intent override optimization

- `"I need comprehensive, thorough, in-depth research on what RTC stands for"` (inflated keywords, simple intent)
- `"Extensive detailed analysis of the definition of WebRTC"` (inflated keywords, lookup intent)

**Expected**: Router should detect simple intent despite inflated keywords and route to Tier 1 (cost optimization)

#### 7. Non-Research Queries (Negative Tests)
**Purpose**: Verify router passes through non-research queries unchanged

- `"Fix the bug in login.js"` (implementation task)
- `"Commit the changes"` (git operation)
- `"Ultra take your time to review the plan"` (planning task)
- `"Create a new skill"` (development task)

**Expected**: Router returns query unchanged (no ROUTING DIRECTIVE appended)

### Testing Validation Requirements

#### Phase 1 Testing
- **Minimum**: 30+ test queries covering all 7 categories
- **Validation method**:
  ```bash
  for query in "${test_queries[@]}"; do
    echo "{\"text\": \"$query\"}" | .claude/hooks/user-prompt-submit/internet-search-router.sh | grep -q "ROUTING DIRECTIVE" && echo "✓" || echo "✗"
  done
  ```
- **JSON validation**: `tail -n 30 docs/hook-migration-tests/router-log.jsonl | jq empty` (must not error)
- **Success criteria**: All research queries detected, all non-research queries passed through

#### Phases 2-4 Testing
- **Standard query**: Verify basic routing to tier skill
- **Edge case with quotes**: Test JSON escaping in skill invocation
- **Multi-dimension query**: Test dimension counting (2-4 for Tier 3, 4+ for Tier 4)
- **Synthesis verification**: Check synthesis reports have proper structure and citations

### Rationale
User insight: **"Edge case testing: Test queries with quotes, special characters, verb derivatives before marking phase complete"** (Phase 2, 2025-11-16)

Phase 2 bug fix: String interpolation broke JSON parsing when queries contained quotes. jq-based logging with `--arg` parameters prevents this.

### Applies To
- Phase 1: Hook router development and validation
- Phases 2-4: Skill testing with edge case queries
- Phase 5: Integration testing across all tiers
- Phase 7: Final production validation

---

## Testing Priorities

### Incremental Validation
**Decision**: Add monitoring hooks at END of each phase (Phases 2, 3, 4), not waiting until Phase 5

**Rationale**: User insight: **"I want to copy the tasks related to logging, and hooks at this point as part of phase two"** (Phase 2, 2025-11-16)

**Implementation**:
- Phase 2 END: Register monitoring hooks (pre_tool_use.sh, post_tool_use.sh, subagent_stop.sh)
- Phase 3 END: Verify monitoring still working after Tier 4 addition
- Phase 4 END: Verify monitoring still working after Tier 5 addition
- Phase 5: Integration testing of entire system

**Benefit**: Early debugging - catch issues immediately rather than waiting for Phase 5

### User Confirmation
**Decision**: User reviews test results and verification report before each commit

**Process**:
1. Implementer runs all tests
2. Implementer prepares verification report with evidence
3. User reviews outputs, logs, test results
4. User approves or requests changes
5. Implementer commits only after approval

**Applies to**: All phases with testing checklists

---

## Evidence Standards

### Commit Message Requirements
**Decision**: Include test evidence (tool call counts, test results, before/after examples) in all commit messages

**Examples**:
- ✅ "Testing: 30/30 detection tests passed"
- ✅ "158 tool calls captured in monitoring logs"
- ✅ "Verified 8 verb derivatives work correctly"
- ❌ "Tests passed" (not specific enough)

### No Arbitrary Estimates
**Decision**: User feedback: **"Remove this shit dont add any thing else"** (Phase 1, 2025-11-16)

**Prohibited**:
- Time estimates ("15-30 minutes", "2-3 hours")
- Success probabilities ("90% confidence", "likely to succeed")
- Arbitrary test counts not derived from requirements

**Allowed**:
- Evidence-based minimums ("30+ detection tests" - derived from 20+ verb derivatives + edge cases)
- Actual measurements ("158 tool calls captured" - from real test run)
- Verifiable metrics ("3/3 test sessions passed" - enumerated from actual sessions)

---

## JSON Validation Requirements

### Mandate jq Usage
**Decision**: ALL JSON generation MUST use `jq -nc` with `--arg` parameters (NOT string interpolation)

**Example (CORRECT)**:
```bash
jq -nc \
  --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg query "$query" \
  --argjson tier "$tier" \
  '{timestamp: $timestamp, query: $query, tier: $tier}'
```

**Example (PROHIBITED)**:
```bash
# DO NOT USE - String interpolation breaks on quotes
echo "{\"timestamp\": \"$timestamp\", \"query\": \"$query\", \"tier\": $tier}"
```

### Validation Required
**Decision**: Every JSONL file MUST be validated with `jq empty` before marking phase complete

**Validation command**:
```bash
tail -n [count] [file.jsonl] | jq empty
```

**Success**: No output (all JSON valid)
**Failure**: Error message indicating line with invalid JSON

### Rationale
String interpolation broke JSON parsing when queries contained quotes (Phase 2 bug fix, 2025-11-16)

**Applies to**:
- Router logging (router-log.jsonl)
- Monitoring hooks (tool_calls.jsonl, agent_mapping.jsonl)
- Any JSON/JSONL output in hooks or skills

---

## Summary

### All 4 Decisions Confirmed

1. ✅ **Naming Conventions**: Original agent names (internet-light-orchestrator, etc.)
2. ✅ **Language Style**: Imperative tone (MUST/SHALL/ALWAYS)
3. ✅ **Log Locations**: Production (hooks_logs/) vs Testing (docs/hook-migration-tests/)
4. ✅ **Edge Case Testing**: 7 categories including quotes, special chars, verb derivatives, long queries

### Additional Standards

- ✅ **Testing Priorities**: Incremental validation (monitoring at end of Phases 2-4)
- ✅ **Evidence Standards**: No arbitrary estimates, only verifiable metrics
- ✅ **JSON Validation**: Mandatory jq usage, validation before phase completion

### Status
**Phase 0.5**: ✅ COMPLETE
**Next Phase**: Phase 1 - Hook Router Development

**No ambiguity remaining** in naming, style, locations, or testing requirements.

---

**Document Version**: 1.0
**Last Updated**: 2025-11-16
**Referenced By**: IMPLEMENTATION_PLAN.md (lines 30-73, Phase 0.5 section lines 257-297)
