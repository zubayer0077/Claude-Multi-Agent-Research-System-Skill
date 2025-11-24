# Manual Integration Tests - Research Skill

This directory contains **test evidence documentation** for Layer 3 testing (quality evaluation) of the `multi-agent-researcher` skill.

---

## Why Manual Tests?

AI agent systems are **non-deterministic**:
- Same input produces different valid outputs each run
- Quality evaluation requires subjective judgment
- Content assessment cannot be coded as assertions

**The quality gate in SKILL.md IS the automated test** - it runs every workflow execution.
These documents capture the **evidence** of those evaluations.

---

## Directory Contents

| File | Description | Status |
|------|-------------|--------|
| `skill-execution-tests.md` | Skill activation, agent spawning, synthesis delegation | Placeholder |
| `edge-case-tests.md` | Error handling, timeout, empty results | Placeholder |
| `integration-test-report.md` | Real-world research query validation | Placeholder |

---

## What These Documents Should Capture

1. **Exact Input Used** - The research query that triggered the workflow
2. **Subtopics Generated** - How the query was decomposed
3. **Agents Spawned** - Which researchers were spawned in parallel
4. **Research Notes Created** - Individual researcher outputs
5. **Synthesis Quality** - Report-writer output evaluation
6. **Pass/Fail Decision** - Final quality assessment

---

## How To Run Manual Tests

### Skill Execution Test

```bash
# 1. Invoke the skill
/skill multi-agent-researcher

# 2. Provide test query
research quantum computing fundamentals

# 3. Observe workflow phases:
#    - Decomposition (2-4 subtopics)
#    - Parallel researcher spawning
#    - Research note generation
#    - Report-writer synthesis
# 4. Verify files in files/research_notes/ and files/reports/
# 5. Document results in skill-execution-tests.md
```

### Edge Case: Empty Results

```bash
# 1. Use obscure query that may yield limited results
research [extremely niche topic with limited sources]

# 2. Observe error handling
# 3. Document behavior in edge-case-tests.md
```

### Integration Test

```bash
# 1. Use complex multi-faceted query
research the evolution of container orchestration comparing
Kubernetes, Docker Swarm, and emerging alternatives

# 2. Verify:
#    - Multiple researchers spawned
#    - Cross-referenced synthesis
#    - Source attribution
# 3. Document in integration-test-report.md
```

---

## When To Re-Run Manual Tests

1. **After SKILL.md changes** - Modified workflow or quality gates
2. **After agent prompt modifications** - Changes to researcher.md or report-writer.md
3. **After hook changes** - Modified post-tool-use tracking
4. **Quarterly verification** - Ensure consistent behavior

---

## Relationship to Automated Tests

```
tests/
├── common/                           # Shared infrastructure tests
│   └── e2e_hook_test.py             # Hook keyword detection (148 tests)
├── research-skill/
│   ├── test-scripts/                # Executable test scripts
│   │   └── phase1-test-queries.sh   # 32 router queries
│   ├── phase-results/               # Historical phase test results
│   └── manual/                      # Layer 3: Human evaluation (this directory)
│       ├── README.md
│       ├── skill-execution-tests.md
│       ├── edge-case-tests.md
│       └── integration-test-report.md
```

**Automated tests** verify deterministic behavior (hook triggers, file paths).
**Manual tests** verify quality that requires judgment (research depth, synthesis quality).

---

## Key Insight

> The quality gate embedded in the multi-agent-researcher SKILL.md runs **every execution**.
> These documents are **evidence** that the workflow produces quality research.
> They are NOT missing automation - they document tests that CANNOT be automated.

---

**Last Updated**: 2024-11-24
