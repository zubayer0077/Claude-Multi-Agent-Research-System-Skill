# Skill Execution Tests - Research Skill

**Test Date**: [PLACEHOLDER - Add date when test is executed]
**Test Type**: End-to-end skill workflow execution
**Status**: [PLACEHOLDER - PASSED/FAILED]

> **Note**: This is manual test EVIDENCE, not an executable test script.
> Fill in this template after executing the multi-agent-researcher skill.

---

## Test Summary

**Overall Result**: [PLACEHOLDER]
**Tests Executed**: X/X passed
**Researchers Spawned**: [Number]
**Research Notes Generated**: [Number]
**Final Report Generated**: Yes/No

---

## Test 1: Skill Activation

**Test Objective**: Verify multi-agent-researcher skill activates on research-related prompts

**Test Input**:
```
[PLACEHOLDER - Add the exact research query used]
```

**Expected Result**: Skill activates with trigger keywords detected

**Actual Result**:
- [ ] Skill activated successfully
- [ ] Trigger keywords detected: [list keywords]
- [ ] skill-rules.json triggers working

**Status**: [PASSED/FAILED]

---

## Test 2: Query Decomposition

**Test Objective**: Verify orchestrator decomposes query into 2-4 subtopics

**Expected Results**:
- Query analyzed for complexity
- 2-4 focused subtopics identified
- Subtopics are mutually exclusive and collectively exhaustive

**Actual Results**:
- Subtopics generated:
  1. [PLACEHOLDER]
  2. [PLACEHOLDER]
  3. [PLACEHOLDER]
  4. [PLACEHOLDER - if applicable]

**Status**: [PASSED/FAILED]

---

## Test 3: Parallel Researcher Spawning

**Test Objective**: Verify researchers spawn in parallel via Task tool

**Expected Results**:
- Task tool spawns researchers with subagent_type='researcher'
- All researchers spawn simultaneously (not sequentially)
- Each researcher receives focused subtopic

**Actual Results**:
- [ ] Researchers spawned in parallel
- [ ] Number of researchers: [X]
- [ ] Task tool calls logged correctly

**Status**: [PASSED/FAILED]

---

## Test 4: Research Note Generation

**Test Objective**: Verify each researcher creates research note file

**Expected Results**:
- Files created in `files/research_notes/`
- File naming: `{subtopic-slug}_{timestamp}.md`
- Each file contains sources, findings, key insights

**Actual Results**:
- Files created:
  1. [ ] `files/research_notes/[filename1].md`
  2. [ ] `files/research_notes/[filename2].md`
  3. [ ] `files/research_notes/[filename3].md`

**Status**: [PASSED/FAILED]

---

## Test 5: Synthesis Delegation

**Test Objective**: Verify orchestrator delegates synthesis to report-writer (cannot write directly)

**Expected Results**:
- Orchestrator spawns report-writer agent
- Orchestrator does NOT write to `files/reports/` directly
- Report-writer reads all research notes and synthesizes

**Actual Results**:
- [ ] Report-writer spawned via Task tool
- [ ] Orchestrator did not attempt direct write (allowed-tools constraint)
- [ ] Report-writer created synthesis report

**Status**: [PASSED/FAILED]

---

## Test 6: Final Report Quality

**Test Objective**: Verify synthesis report meets quality standards

**Expected Results**:
- Report created in `files/reports/`
- Cross-references findings from all researchers
- Includes source attribution
- Coherent narrative synthesis

**Actual Results**:
- Report path: `files/reports/[filename].md`
- Report length: [X] lines
- Quality assessment:
  - [ ] Cross-references multiple sources
  - [ ] Coherent structure
  - [ ] Actionable insights

**Status**: [PASSED/FAILED]

---

## Artifacts Generated

**Research Notes**:
```
files/research_notes/
├── [filename1].md
├── [filename2].md
└── [filename3].md
```

**Final Report**:
```
files/reports/[report-filename].md
```

---

## Notes

[PLACEHOLDER - Add any observations, issues, or recommendations]

---

**Tested By**: [Name]
**Date**: [YYYY-MM-DD]
