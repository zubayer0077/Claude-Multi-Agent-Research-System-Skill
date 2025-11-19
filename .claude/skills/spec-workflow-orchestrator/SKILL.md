---
name: spec-workflow-orchestrator
description: Orchestrate comprehensive planning phase from ideation to development-ready specifications using 4 specialized agents
allowed-tools: Task, Read, Glob, TodoWrite, Write, Edit
version: 1.0.0
---

# Spec Workflow Orchestrator

## Purpose

Transform ideas into development-ready specifications through:
1. Comprehensive planning with requirement analysis and architecture design
2. Quality-gated iterative refinement of specifications
3. Complete handoff documentation for development teams
4. Orchestration across planning phase with 4 specialized agents

## When to Use

Auto-invoke when user requests:
- **Planning**: "Plan [application]", "Design [system]", "Spec out [feature]", "Create requirements for [service]"
- **Architecture**: "Architecture for [project]", "Technical design for [application]", "Design specifications"
- **Requirements**: "Requirements for [project]", "Analyze requirements", "User stories for [feature]"
- **Pre-Development**: "Ready for development", "Spec-based planning", "Development specifications"

Do NOT invoke for:
- Actual code implementation (this skill stops at planning)
- Quick prototypes or experiments
- Single-file scripts
- Tasks that need immediate coding

## Orchestration Workflow

### Planning Phase (spec-analyst → spec-architect → spec-planner)

The orchestrator manages sequential execution of three specialized agents with quality gate validation.

---

**Step 1: Query Analysis**

Parse user's planning request and validate suitability:
- Identify project scope, constraints, and stakeholders
- Confirm request is suitable for planning workflow (not immediate coding)
- Determine if sufficient information provided (or elicit more details)
- Output: Planning scope definition ready for spec-analyst

---

**Step 2: Spawn spec-analyst Agent**

Use Task tool to spawn requirements analysis agent:

```
Agent: spec-analyst (from .claude/skills/spec-workflow-orchestrator/agents/spec-analyst.md)

Prompt: "Analyze requirements for [PROJECT_NAME]. Generate comprehensive requirements.md with:
- Executive Summary (project goals and scope)
- Functional Requirements (prioritized with IDs: FR1, FR2, etc.)
- Non-Functional Requirements (performance, security, scalability with metrics)
- User Stories with Acceptance Criteria (measurable criteria for each story)
- Stakeholder Analysis (identify all stakeholder groups and their needs)
- Assumptions and Constraints (technical, business, timeline)
- Success Metrics (how to measure project success)

Save to: docs/planning/requirements.md"

Wait for completion → Read output: docs/planning/requirements.md
```

**Expected Output**: Comprehensive requirements document (typically 800-1,500 lines)

---

**Step 3: Spawn spec-architect Agent**

Use Task tool to spawn architecture design agent:

```
Agent: spec-architect (from .claude/skills/spec-workflow-orchestrator/agents/spec-architect.md)

Prompt: "Design system architecture for [PROJECT_NAME] based on requirements at docs/planning/requirements.md.

Generate:
1. architecture.md with:
   - Executive Summary
   - Technology Stack (with justification for each choice)
   - System Components (with interaction diagrams)
   - API Specifications (endpoints, contracts, data models)
   - Security Considerations (authentication, authorization, data protection)
   - Performance & Scalability (caching, load balancing, horizontal scaling)
   - Deployment Architecture

2. docs/adrs/*.md with Architecture Decision Records for key decisions:
   - ADR format: Status, Context, Decision, Rationale, Consequences, Alternatives
   - Create separate ADR for: technology stack, database choice, real-time architecture, etc.

Save to: docs/planning/architecture.md, docs/adrs/*.md"

Wait for completion → Read outputs: docs/planning/architecture.md, docs/adrs/*.md
```

**Expected Output**: Architecture document (600-1,000 lines) + 3-5 ADRs (150-250 lines each)

---

**Step 4: Spawn spec-planner Agent**

Use Task tool to spawn implementation planning agent:

```
Agent: spec-planner (from .claude/skills/spec-workflow-orchestrator/agents/spec-planner.md)

Prompt: "Create implementation plan for [PROJECT_NAME] based on:
- Requirements: docs/planning/requirements.md
- Architecture: docs/planning/architecture.md

Generate tasks.md with:
1. Overview (total tasks, estimated effort, critical path, parallel streams)
2. Task Breakdown by Phase:
   - Each task with: ID, complexity, effort estimate, dependencies, description
   - Acceptance criteria for each task (concrete, measurable)
   - Tasks should be atomic and implementable (1-8 hours each)
3. Risk Assessment:
   - Technical risks with severity, probability, impact
   - Mitigation strategies for each risk
4. Testing Strategy:
   - Unit test coverage targets
   - Integration test scenarios
   - End-to-end test requirements

Save to: docs/planning/tasks.md"

Wait for completion → Read output: docs/planning/tasks.md
```

**Expected Output**: Task breakdown document (500-800 lines with 15-30 tasks)

---

**Step 5: Quality Gate Validation**

Orchestrator validates planning completeness using checklist (see Quality Gates section):

**Validation Process**:
1. Read all planning artifacts (requirements.md, architecture.md, tasks.md, adrs/*.md)
2. Score against 6-category checklist (100 points total)
3. Calculate total score: Sum of all category points / 100
4. Compare to threshold: ≥ 85% to pass

**Decision**:
- If score ≥ 85%: Proceed to Step 7 (Deliverable Handoff)
- If score < 85%: Proceed to Step 6 (Iteration Loop)

---

**Step 6: Iteration Loop (Max 3 Iterations)**

When quality gate fails, provide targeted feedback and re-spawn relevant agent:

**Feedback Generation Process**:
1. Identify which checklist categories failed (< expected points)
2. Determine root cause (requirements gap, architecture issue, tasks unclear)
3. Generate specific, actionable feedback listing gaps
4. Re-spawn agent with previous output + feedback + gap list

**Example Feedback for spec-analyst**:
```
"Requirements analysis incomplete. Score: 68/100

Gaps identified:
- Non-functional requirements missing performance metrics (0/5 points)
  → Add specific metrics: API response time, throughput, concurrent users
- User stories lack measurable acceptance criteria (2/5 points)
  → Provide concrete, testable criteria for each story
- Stakeholder analysis incomplete (2/5 points)
  → Identify admin users, end users, external integrations

Please regenerate requirements.md addressing these specific gaps."
```

**Re-spawn agent** with feedback → Wait for revised output → Return to Step 5 (Quality Gate)

**Iteration Limit Enforcement**:
- Track iteration count per agent (max 3 total iterations)
- If iterations = 3 and score still < 85%: Escalate to user with current artifacts
- User decides: accept current quality OR provide manual guidance

---

**Step 7: Deliverable Handoff**

Generate planning summary and return artifacts to user:

**Planning Summary Includes**:
- Project scope and objectives (from requirements.md)
- Key architectural decisions (from ADRs)
- Implementation roadmap (from tasks.md with effort estimates)
- Technical risks and mitigation strategies (from tasks.md)
- Quality gate score (e.g., "92/100 - Planning phase complete")
- Next steps for development team

**Deliverables Returned**:
- 📄 docs/planning/requirements.md
- 📄 docs/planning/architecture.md
- 📄 docs/planning/tasks.md
- 📄 docs/adrs/*.md (3-5 Architecture Decision Records)

**Status**: "✅ Planning phase complete. Development-ready specifications available."

**Handoff**: Development team can begin implementation using planning artifacts as source of truth

---

## Agent Roles

**Planning Phase (4 agents)**:
- **spec-orchestrator**: Coordinates planning workflow and quality gates
- **spec-planner**: Initial requirement gathering and scope definition
- **spec-analyst**: Detailed requirement analysis and user story creation
- **spec-architect**: Technical design and architecture decisions

## Quality Gates

### Planning Gate (85% Threshold)

**Purpose**: Validate planning completeness before handoff to development team

**Validation Checklist** (100 points total):

#### 1. Requirements Completeness (25 points)
- ✅ All functional requirements documented with IDs (10 pts)
- ✅ Non-functional requirements specified with metrics (5 pts)
- ✅ User stories with measurable acceptance criteria (5 pts)
- ✅ Stakeholder needs addressed and documented (5 pts)

#### 2. Architecture Soundness (25 points)
- ✅ System design addresses all requirements (10 pts)
- ✅ Technology stack justified with rationale (5 pts)
- ✅ Scalability and performance considerations documented (5 pts)
- ✅ Security and compliance requirements addressed (5 pts)

#### 3. Task Breakdown Quality (20 points)
- ✅ Tasks are atomic and implementable (1-8 hours each) (10 pts)
- ✅ Dependencies clearly identified with task IDs (5 pts)
- ✅ Effort estimates provided with complexity ratings (5 pts)

#### 4. Architecture Decision Records (10 points)
- ✅ Key decisions documented in ADRs (5 pts)
- ✅ Trade-offs and alternatives considered explicitly (5 pts)

#### 5. Risk Management (10 points)
- ✅ Technical risks identified with severity/probability (5 pts)
- ✅ Mitigation strategies documented for each risk (5 pts)

#### 6. Handoff Readiness (10 points)
- ✅ Documentation clear and comprehensive (5 pts)
- ✅ Next steps explicitly defined for dev team (5 pts)

---

**Scoring Method**:
1. Sum all checklist points from 6 categories
2. Score = Total Points / 100
3. Threshold: ≥ 85% to pass quality gate

**Maximum Iterations**: 3 attempts per planning session

---

### Feedback Loop Process

**When Quality Gate Fails (Score < 85%)**:

#### Step 1: Failure Analysis

Categorize gaps by severity:
- **Critical** (0-50% score): Fundamental gaps requiring complete rework
- **Major** (51-74% score): Significant improvements needed
- **Minor** (75-84% score): Small refinements to reach threshold

#### Step 2: Root Cause Identification

Map failures to responsible agent:
- Requirements incomplete or unclear? → Re-spawn **spec-analyst**
- Architecture infeasible or under-specified? → Re-spawn **spec-architect**
- Tasks too vague or poorly estimated? → Re-spawn **spec-planner**
- Multiple issues? → Address in priority order (requirements first)

#### Step 3: Generate Specific Feedback

Create targeted feedback for agent re-spawning with:
- Current score and gap breakdown
- Specific items missing (reference checklist categories)
- Actionable improvements needed
- Concrete examples of what's expected

**Example Feedback Templates**:

**For spec-analyst (Requirements Gap)**:
```
"Requirements analysis incomplete. Score: 68/100

Gaps identified:
- Non-functional requirements missing performance metrics (0/5 points)
  → Add specific metrics: API response time < 200ms p95, throughput > 1000 req/s,
     concurrent users > 500
- User stories lack measurable acceptance criteria (2/5 points)
  → Provide concrete, testable criteria for each story
  → Example: 'AC1: User can create task within 2 seconds' (not 'AC1: Task creation works')
- Stakeholder analysis incomplete (2/5 points)
  → Identify: admin users, end users, API consumers, external integrations
  → Document needs and priorities for each stakeholder group

Please regenerate requirements.md addressing these specific gaps."
```

**For spec-architect (Architecture Gap)**:
```
"Architecture design incomplete. Score: 72/100

Gaps identified:
- Scalability not addressed (0/5 points)
  → Design for 10x growth: horizontal scaling strategy, database sharding plan
  → Address: load balancing, caching layers, CDN for static assets
- Security considerations incomplete (1/5 points)
  → Add: authentication mechanism (JWT/OAuth), authorization model (RBAC),
     data encryption (at rest and in transit), input validation strategy
- ADRs missing key decisions (2/5 points)
  → Create ADR for: database choice (SQL vs. NoSQL), real-time architecture
     (WebSockets vs. polling), deployment platform (cloud provider choice)
  → Format: Status, Context, Decision, Rationale, Consequences, Alternatives

Please regenerate architecture.md and adrs/ addressing these gaps."
```

**For spec-planner (Task Breakdown Gap)**:
```
"Task breakdown incomplete. Score: 76/100

Gaps identified:
- Tasks too large and not atomic (4/10 points)
  → Break down: 'Build authentication system' is too broad
  → Should be: 'T2.1: Create user registration API endpoint (4h)',
     'T2.2: Implement JWT token generation (3h)', etc.
- Dependencies not clearly identified (2/5 points)
  → Use task IDs: 'Dependencies: T1.3, T2.1' (not 'depends on auth')
  → Ensure topological order (no circular dependencies)
- Risk mitigation incomplete (3/5 points)
  → For each risk, provide concrete mitigation strategy
  → Example: 'Risk: WebSocket scaling' → 'Mitigation: Implement Redis adapter
     early in Phase 2, test with 1000 concurrent connections'

Please regenerate tasks.md addressing these gaps."
```

#### Step 4: Re-spawn Agent with Feedback

Execute re-spawning process:
1. Use Task tool to spawn same agent again
2. Provide prompt with:
   - Previous output file path (to build upon, not start from scratch)
   - Specific feedback with gap list
   - Target improvements needed to reach 85% threshold
3. Wait for revised output
4. Read revised artifact

**Example Re-spawn for spec-analyst**:
```
Agent: spec-analyst

Prompt: "Improve requirements.md based on feedback.

Previous version: docs/planning/requirements.md

Feedback:
[Insert feedback from Step 3]

Please revise requirements.md to address all identified gaps. Focus on:
1. Adding quantitative non-functional requirements
2. Providing measurable acceptance criteria for all user stories
3. Completing stakeholder analysis with needs documentation

Target: 85% quality gate score"
```

#### Step 5: Re-validate

Return to Step 5 of Orchestration Workflow (Quality Gate Validation):
1. Re-run quality gate checklist on revised artifacts
2. Calculate new score
3. Compare to previous score (expect improvement)
4. **Decision**:
   - If new score ≥ 85%: Proceed to next agent or Step 7 (Deliverable Handoff)
   - If new score < 85% AND iterations < 3: Repeat Step 6 (Feedback Loop)
   - If iterations = 3: Escalate to user with current artifacts

---

### Iteration Limit Enforcement

**Maximum 3 iterations per planning session** to prevent infinite loops:

- **Iteration 1**: Initial attempt (typically 60-75% score)
  - Agents work from user's initial request
  - Common gaps: vague requirements, missing NFRs, incomplete architecture

- **Iteration 2**: Refinement with feedback (typically 75-85% score)
  - Agents improve based on specific gap feedback
  - Focus on addressing major gaps from Iteration 1
  - Most planning sessions reach 85% threshold here

- **Iteration 3**: Final optimization (target 85%+ score)
  - Last chance to reach threshold
  - Address remaining minor gaps
  - If still < 85%: Escalation needed

**After 3 iterations, if score < 85%**:
1. Return current artifacts to user with status report:
   ```
   "Planning quality gate not reached after 3 iterations.

   Current score: 82/100

   Remaining gaps:
   - [List specific gaps still present]

   Artifacts available:
   - requirements.md (mostly complete, minor gaps)
   - architecture.md (complete)
   - tasks.md (needs minor refinement)

   Options:
   A) Accept current quality level and proceed to development
   B) Provide manual guidance to close remaining gaps
   C) Restart planning with clearer initial requirements"
   ```

2. User decides next action (orchestrator waits for user input)
3. Document lessons learned for process improvement:
   - What gaps were hardest to close?
   - What initial information would have helped?
   - Update agent prompts or checklist based on findings

---

## File Organization

- `docs/planning/*.md`: Planning phase outputs (requirements, architecture)
- `docs/adrs/*.md`: Architecture Decision Records
- Handoff ready for development team to implement

---

## Best Practices

**TODO: Best practices to be added in Phase 3**

---

## Examples

**TODO: Examples to be added in Phase 3**

---

**Note**: This skill focuses on planning phase only. It produces development-ready specifications but does not implement code, tests, or validation.
