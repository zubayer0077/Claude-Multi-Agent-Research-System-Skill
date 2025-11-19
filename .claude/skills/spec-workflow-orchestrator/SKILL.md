---
name: spec-workflow-orchestrator
description: Orchestrate production-ready development projects through complete workflow with planning, implementation, and validation phases using 8 specialized agents
allowed-tools: Task, Read, Glob, TodoWrite, Write, Edit
version: 1.0.0
---

# Spec Workflow Orchestrator

## Purpose

Transform development requests into production-ready code through:
1. Comprehensive planning with requirement analysis and architecture design
2. Structured development with quality gates and iterative refinement
3. Rigorous validation with automated testing and documentation
4. Complete workflow orchestration across 3 phases with 8 specialized agents

## When to Use

Auto-invoke when user requests:
- **Development**: "Develop [application]", "Build [system]", "Create [feature]", "Implement [service]"
- **Production Quality**: "Production-ready [project]", "Enterprise-grade [application]", "High-quality implementation"
- **Complete Workflow**: "Complete workflow for [project]", "End-to-end development", "Spec-based development"
- **Quality-Gated**: "Quality-gated development", "With validation", "With testing and docs"

Do NOT invoke for:
- Simple code snippets or utilities
- Quick prototypes or experiments
- Single-file scripts
- Exploratory coding without requirements

## Orchestration Workflow

### Phase 1: Planning (spec-planner → spec-analyst → spec-architect)

**TODO: Phase 1 workflow steps to be added in Phase 3**

---

### Phase 2: Development (spec-orchestrator → spec-developer)

**TODO: Phase 2 workflow steps to be added in Phase 3**

---

### Phase 3: Validation (spec-tester → spec-validator → spec-reviewer)

**TODO: Phase 3 workflow steps to be added in Phase 3**

---

## Agent Roles

**Planning Phase**:
- **spec-planner**: Initial requirement gathering and scope definition
- **spec-analyst**: Detailed requirement analysis and user story creation
- **spec-architect**: Technical design and architecture decisions

**Development Phase**:
- **spec-orchestrator**: Coordinates development workflow and quality gates
- **spec-developer**: Implements code based on specifications

**Validation Phase**:
- **spec-tester**: Automated testing and quality assurance
- **spec-validator**: Validates against requirements and acceptance criteria
- **spec-reviewer**: Final code review and documentation check

## Quality Gates

**Planning Gate** (85% threshold):
- Requirements completeness
- Architecture soundness
- Feasibility assessment

**Development Gate** (85% threshold):
- Code quality and standards
- Implementation completeness
- Technical debt assessment

**Validation Gate** (95% threshold):
- Test coverage and passing
- Documentation completeness
- Production readiness

**Maximum Iterations**: 3 per phase

---

## File Organization

- `docs/planning/*.md`: Planning phase outputs (requirements, architecture)
- `docs/validation/*.md`: Validation reports (tests, reviews)
- `docs/adrs/*.md`: Architecture Decision Records
- `src/`: Implementation code

---

## Best Practices

**TODO: Best practices to be added in Phase 3**

---

## Examples

**TODO: Examples to be added in Phase 3**

---

**Note**: This is a skeleton created in Phase 1. Full workflow details will be implemented in Phase 3.
