# Edge Case Tests - Research Skill

**Test Date**: [PLACEHOLDER - Add date when tests are executed]
**Test Type**: Edge case and error handling validation
**Status**: [PLACEHOLDER - PASSED/FAILED]

> **Note**: This is manual test EVIDENCE, not an executable test script.
> Fill in this template after testing edge cases.

---

## Test Summary

**Overall Result**: [PLACEHOLDER]
**Edge Cases Tested**: X/X

---

## Edge Case 1: Single Subtopic Query

**Test Objective**: Verify skill handles simple queries that only need 1-2 researchers

**Test Input**:
```
[PLACEHOLDER - Simple query like "What is quantum computing?"]
```

**Expected Behavior**:
- Skill recognizes low complexity
- Spawns 1-2 researchers (not full parallel team)
- Still produces synthesis report

**Actual Behavior**:
- [ ] Complexity correctly assessed
- [ ] Appropriate number of researchers: [X]
- [ ] Report generated

**Status**: [PASSED/FAILED]

---

## Edge Case 2: Very Broad Query

**Test Objective**: Verify skill handles overly broad queries

**Test Input**:
```
[PLACEHOLDER - Broad query like "research everything about technology"]
```

**Expected Behavior**:
- Skill decomposes into manageable subtopics
- Limits to 4 researchers maximum
- Each subtopic is focused

**Actual Behavior**:
- [ ] Query decomposed successfully
- [ ] Subtopic count: [X] (expected: 2-4)
- [ ] Subtopics are focused, not vague

**Status**: [PASSED/FAILED]

---

## Edge Case 3: Limited Search Results

**Test Objective**: Verify skill handles queries with sparse web results

**Test Input**:
```
[PLACEHOLDER - Niche topic with limited sources]
```

**Expected Behavior**:
- Researchers report limited findings
- Report-writer acknowledges gaps
- No hallucinated content

**Actual Behavior**:
- [ ] Researchers handled sparse results gracefully
- [ ] Report notes limitations
- [ ] No fabricated sources

**Status**: [PASSED/FAILED]

---

## Edge Case 4: Non-Research Query Detection

**Test Objective**: Verify non-research queries are NOT routed to skill

**Test Input**:
```
Fix the bug in login.js
```

**Expected Behavior**:
- Hook does NOT trigger research skill
- Query passes through to normal processing

**Actual Behavior**:
- [ ] Skill NOT activated
- [ ] Query processed normally

**Status**: [PASSED/FAILED]

---

## Edge Case 5: Researcher Failure Recovery

**Test Objective**: Verify workflow continues if one researcher fails

**Test Input**:
```
[PLACEHOLDER - Query that triggers multiple researchers]
```

**Simulated Condition**: [Describe how failure was simulated, if applicable]

**Expected Behavior**:
- Other researchers complete successfully
- Report-writer synthesizes available notes
- Workflow does not crash

**Actual Behavior**:
- [ ] Partial results handled
- [ ] Report generated with available data
- [ ] Error logged appropriately

**Status**: [PASSED/FAILED/NOT TESTED]

---

## Edge Case 6: Synthesis Bypass Attempt

**Test Objective**: Verify orchestrator cannot bypass report-writer

**Expected Behavior**:
- Orchestrator lacks Write tool (allowed-tools constraint)
- Any attempt to write directly fails
- Must delegate to report-writer

**Actual Behavior**:
- [ ] allowed-tools constraint enforced
- [ ] Report-writer delegation required
- [ ] No synthesis bypass possible

**Status**: [PASSED/FAILED]

---

## Notes

[PLACEHOLDER - Add any observations about edge case handling]

---

**Tested By**: [Name]
**Date**: [YYYY-MM-DD]
