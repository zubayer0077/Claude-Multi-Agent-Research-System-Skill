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

**Planning Gate** (85% threshold):
- Requirements completeness
- Architecture soundness
- Feasibility assessment
- Documentation quality
- Handoff readiness

**Maximum Iterations**: 3 for planning phase

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
