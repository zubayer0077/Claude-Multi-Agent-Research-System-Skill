# Agent → Skill Conversion Map
## Light Orchestrator (Tier 3) - Smallest Orchestrator

**Created**: 2025-11-16
**Source Agent**: `.claude/agents/internet-light-orchestrator.md`
**Target Skill**: `.claude/skills/tier-3-light-research/SKILL.md`

---

## 1. AGENT STRUCTURE ANALYSIS

### Agent Components (internet-light-orchestrator.md)

```
┌─────────────────────────────────────┐
│ YAML Frontmatter (5 lines)          │
│ - name                               │
│ - description                        │
│ - tools: Task                        │
│ - model: haiku                       │
├─────────────────────────────────────┤
│ Role Definition (8 lines)            │
│ - Coordinator role                   │
│ - Prohibition rules                  │
├─────────────────────────────────────┤
│ Mandatory Spawning Requirements      │
│ - 3 critical rules                   │
│ - Workflow compliance                │
│ - researchPath handling              │
├─────────────────────────────────────┤
│ Agent Startup Logging (bash script)  │
│ - JSONL logging                      │
│ - Parent tracking                    │
├─────────────────────────────────────┤
│ Workflow (7 steps)                   │
│ - Analyze request                    │
│ - Extract researchPath               │
│ - Spawn researchers                  │
│ - Wait for completion                │
│ - Spawn report-writer                │
│ - Confirm completion                 │
├─────────────────────────────────────┤
│ Delegation Rules (9 rules)           │
│ - Never research directly            │
│ - Always spawn subagents             │
│ - researchPath passing               │
├─────────────────────────────────────┤
│ Parallel Spawning Guide              │
│ - Good vs bad examples               │
├─────────────────────────────────────┤
│ Task Tool Usage                      │
│ - Spawning syntax                    │
│ - Parameter passing                  │
├─────────────────────────────────────┤
│ Examples (3 examples)                │
│ - Good response                      │
│ - Bad responses                      │
│ - Perfect conciseness                │
├─────────────────────────────────────┤
│ Response Style                       │
│ - Conciseness requirements           │
│ - No emojis/greetings                │
├─────────────────────────────────────┤
│ Summary                              │
│ - High-level overview                │
└─────────────────────────────────────┘
```

### Key Agent Features

| Feature | Description | Purpose |
|---------|-------------|---------|
| **tools: Task** | Only tool available | Enforces delegation pattern |
| **model: haiku** | Cost-efficient model | 2-4 dimension queries |
| **Mandatory spawning** | MUST spawn 2-4 workers | Core coordination responsibility |
| **researchPath** | Session folder coordination | File-based multi-agent work |
| **Startup logging** | Bash script tracking | Parallel execution diagnosis |
| **Prohibition-based** | Lists what NOT to do | Prevents direct research |
| **Examples-driven** | 3 concrete examples | Shows expected behavior |
| **Response style** | Ultra-concise | 2-3 sentences max |

---

## 2. SKILL STRUCTURE REFERENCE

### Skill Best Practices (from existing skills)

**YAML Frontmatter Requirements**:
```yaml
---
name: skill-name
description: Clear, concise description with trigger keywords
---
```

**Skill Content Structure**:
1. **Quick Start** - Immediate actionable workflow
2. **Workflow** - Step-by-step process
3. **Examples** - Concrete use cases
4. **Reference** - Detailed rules/patterns

**Key Differences from Agents**:

| Aspect | Agent | Skill |
|--------|-------|-------|
| **Invocation** | Task tool (spawned) | Model-invoked (automatic) |
| **Context** | Subprocess | Main Claude process |
| **Tool Access** | Limited by YAML | Full tool access |
| **Lifecycle** | Ephemeral (task-based) | Persistent (session) |
| **Response** | Single-use output | Guidance for Main Claude |

---

## 3. CONVERSION MAPPING

### What Stays The Same

✅ **Keep**:
- Description (same routing/trigger keywords)
- Model selection (haiku for cost efficiency)
- Core workflow logic (analyze → spawn → coordinate)
- Parallel spawning pattern
- researchPath coordination
- Delegation rules
- Examples and anti-patterns
- Response style requirements

### What Changes

🔄 **Transform**:

| Agent Feature | Skill Equivalent | Rationale |
|---------------|------------------|-----------|
| `tools: Task` | Implicit (Main Claude has Task) | Skills don't restrict tools |
| Agent startup logging | Remove or convert to TodoWrite | Skills don't run in subprocess |
| "You are a lead researcher" | "Guide Main Claude to coordinate..." | Skills advise, not execute |
| "SPAWN subagents" | "Use Task tool to spawn..." | Main Claude executes |
| Subprocess parameters (SPAWNED_BY) | Session metadata | Different execution context |

❌ **Remove**:
- Agent-specific startup logging bash scripts
- Subprocess environment variables
- "You MUST" language (skills are advisory)

➕ **Add**:
- Quick Start section (skill standard)
- Activation triggers in description
- TodoWrite integration for progress tracking
- More explicit Main Claude guidance

---

## 4. DETAILED CONVERSION RULES

### Rule 1: YAML Frontmatter

**Agent**:
```yaml
---
name: internet-light-orchestrator
description: Internet research orchestrator (Tier 3 Light Parallel)...
tools: Task
model: haiku
---
```

**Skill**:
```yaml
---
name: tier-3-light-research
description: Orchestrate lightweight parallel internet research (2-4 dimensions). Spawns light-research-researcher workers for each subtopic dimension, coordinates findings, synthesizes final reports. Use for standard research queries, cloud gaming optimization, quantum computing overview, etc. Triggers: "research", "investigate", "analyze" with 2-3 distinct angles.
---
```

**Changes**:
- Remove `tools` (skills don't restrict)
- Remove `model` (Main Claude decides)
- Expand description with trigger keywords
- Add concrete example queries

---

### Rule 2: Role Definition → Workflow Guidance

**Agent**:
```markdown
You are a lead research coordinator who orchestrates...

## 🚨 MANDATORY SUBAGENT SPAWNING REQUIREMENTS
**CRITICAL PROHIBITION-BASED RULES - YOU MUST FOLLOW...**
```

**Skill**:
```markdown
# Lightweight Parallel Research Orchestration

Guide Main Claude to coordinate 2-4 parallel researchers for multi-dimensional queries.

## Quick Start

When user asks research question with 2-3 distinct angles:
1. Break query into 2-4 subtopics (one per dimension)
2. Use TodoWrite to track spawning progress
3. Spawn light-research-researcher for each subtopic using Task tool
4. After all complete, spawn light-research-report-writer for synthesis
```

**Changes**:
- From imperative ("You MUST") to advisory ("Guide Main Claude")
- From agent persona to process guidance
- Add TodoWrite integration
- Focus on when/how to activate

---

### Rule 3: Startup Logging → TodoWrite Integration

**Agent**:
```bash
# Log agent startup
AGENT_NAME="internet-light-orchestrator"
AGENT_ID="$(echo "$AGENT_NAME" | tr '[:lower:]' '[:upper:]')-$(date +%s)"
echo "{\"event\":\"agent_start\"...}" >> hooks_logs/agent_start_log.jsonl
```

**Skill**:
```markdown
## Progress Tracking

Use TodoWrite to track orchestration progress:

```json
[
  {"content": "Analyze query dimensions", "status": "in_progress", "activeForm": "Analyzing..."},
  {"content": "Spawn 3 light-research-researcher agents", "status": "pending", "activeForm": "Spawning researchers"},
  {"content": "Spawn light-research-report-writer", "status": "pending", "activeForm": "Synthesizing report"}
]
```
```

**Changes**:
- Replace bash logging with TodoWrite
- Built-in Claude Code feature
- User-visible progress
- No subprocess concerns

---

### Rule 4: Workflow Steps (Mostly Same)

**Agent Workflow**:
```
STEP 1: ANALYZE USER REQUEST
STEP 2: EXTRACT researchPath FROM PROMPT
STEP 3: SPAWN RESEARCHER SUBAGENTS (IN PARALLEL)
STEP 4: WAIT FOR RESEARCH COMPLETION
STEP 5: SPAWN REPORT-WRITER SUBAGENT
STEP 6: CONFIRM COMPLETION
```

**Skill Workflow**:
```
Step 1: Analyze Request
- Identify 2-4 distinct subtopics/dimensions
- Example: "quantum computing" → hardware, algorithms, companies, challenges

Step 2: Create Session
- Already done by hook router (researchPath provided)
- Extract researchPath from user context

Step 3: Setup Progress Tracking
- Use TodoWrite with subtopics as tasks
- Mark first task as in_progress

Step 4: Spawn Researchers (Parallel)
- Use Task tool to spawn light-research-researcher
- One per subtopic (2-4 total)
- Pass researchPath to each

Step 5: Spawn Synthesizer
- After all researchers complete
- Spawn light-research-report-writer
- Pass researchPath

Step 6: Complete
- Mark TodoWrite tasks as completed
- Report final location to user
```

**Changes**:
- Add TodoWrite integration
- Clarify that session is pre-created
- More explicit Task tool usage
- Remove subprocess-specific details

---

### Rule 5: Examples (Adapt Language)

**Agent Example**:
```
User: "Research the latest developments in electric vehicles"

Lead Agent Response:
"Breaking this into 4 research areas: battery technology, market trends,
major manufacturers, and charging infrastructure. Research path:
docs/research-sessions/14112025_145230_electric_vehicles/.
Spawning researchers now."

[Spawns 4 light-research-researcher subagents...]
```

**Skill Example**:
```
User: "Research the latest developments in electric vehicles"

Main Claude should:
1. Identify 4 subtopics: batteries, market, manufacturers, infrastructure
2. TodoWrite: Create 4 researcher tasks + 1 synthesis task
3. Task tool: Spawn 4 light-research-researcher agents in parallel
4. Task tool: After completion, spawn light-research-report-writer
5. Respond: "Research complete. Report: docs/research-sessions/.../synthesis.md"

Actual Task tool calls:
- subagent_type: "light-research-researcher"
- description: "Battery technology research"
- prompt: "Research EV battery developments. Save to {researchPath}/batteries_researcher.md"
(Repeat for 3 more subtopics)
```

**Changes**:
- From first-person ("I spawn") to third-person ("Main Claude should")
- Show TodoWrite usage
- Show explicit Task tool syntax
- Emphasize parallel spawning

---

## 5. CONVERSION CHECKLIST

### Pre-Conversion

- [x] Read full agent markdown
- [x] Identify agent features and rules
- [x] Analyze workflow structure
- [x] Note examples and anti-patterns
- [x] Review existing skill patterns

### During Conversion

Core Structure:
- [ ] Convert YAML frontmatter (remove tools/model, expand description)
- [ ] Add Quick Start section
- [ ] Transform role definition to workflow guidance
- [ ] Replace startup logging with TodoWrite
- [ ] Adapt workflow steps for Main Claude
- [ ] Convert examples to skill format
- [ ] Keep delegation rules (rephrase for advisory)
- [ ] Keep parallel spawning guidance
- [ ] Keep response style requirements

Content Adaptation:
- [ ] Change imperative to advisory language
- [ ] Remove "You MUST" → "Main Claude should"
- [ ] Remove subprocess-specific code
- [ ] Add TodoWrite integration examples
- [ ] Add Task tool syntax examples
- [ ] Keep all domain logic intact

### Post-Conversion

- [ ] Verify YAML frontmatter is valid
- [ ] Ensure no agent-specific language remains
- [ ] Check TodoWrite integration is clear
- [ ] Verify Task tool examples are correct
- [ ] Test activation with sample queries
- [ ] Create test plan for validation

---

## 6. KEY PRINCIPLES

### Principle 1: Skills Are Advisors, Not Executors

**Wrong** (Agent thinking):
> "I will spawn 4 researcher subagents using the Task tool."

**Right** (Skill thinking):
> "Guide Main Claude to spawn 4 researcher subagents using the Task tool."

### Principle 2: Skills Have Full Tool Access

**Wrong** (Restricting tools):
```yaml
tools: Task
```

**Right** (No restriction):
```yaml
# Tools automatically available: Task, TodoWrite, Read, Write, etc.
# Skills guide Main Claude on which to use
```

### Principle 3: Skills Integrate Built-in Features

**Wrong** (Custom logging):
```bash
echo "{\"event\":\"start\"}" >> custom_log.jsonl
```

**Right** (Use TodoWrite):
```json
[{"content": "Start orchestration", "status": "in_progress", "activeForm": "Starting..."}]
```

### Principle 4: Skills Provide Context-Sensitive Guidance

**Wrong** (Always active):
> "Whenever user asks anything, do this..."

**Right** (Trigger-based):
> "When query has 2-3 distinct research dimensions (e.g., 'quantum computing hardware and applications'), activate this workflow."

### Principle 5: Keep Domain Logic Intact

**Preserve**:
- Research dimension identification
- Parallel spawning patterns
- Subtopic breakdown strategies
- researchPath coordination
- Worker → Synthesizer workflow
- Quality requirements

**Adapt**:
- How Main Claude receives guidance
- How progress is tracked (TodoWrite)
- How tools are invoked (explicit examples)

---

## 7. EXPECTED SKILL SIZE

Based on conversion analysis:

**Agent Size**: 246 lines
**Estimated Skill Size**: 180-220 lines

**Size Breakdown**:
- YAML frontmatter: ~5 lines (same)
- Quick Start: ~15 lines (new)
- Workflow: ~50 lines (adapted from agent's 7 steps)
- TodoWrite Integration: ~20 lines (new, replaces logging)
- Task Tool Usage: ~30 lines (adapted from agent)
- Examples: ~40 lines (adapted from agent's 3 examples)
- Delegation Rules: ~25 lines (adapted from agent)
- Response Style: ~10 lines (same as agent)

**Removed**: ~60 lines
- Startup logging bash script: ~10 lines
- Subprocess-specific parameters: ~15 lines
- Agent-specific role definitions: ~20 lines
- Redundant prohibition language: ~15 lines

**Added**: ~30 lines
- Quick Start section: ~15 lines
- TodoWrite examples: ~15 lines

**Net**: Slightly smaller, more focused

---

## 8. VALIDATION CRITERIA

### Functional Validation

✅ **Skill must**:
- Activate on 2-3 dimension research queries
- Guide Main Claude to identify subtopics correctly
- Provide clear Task tool spawning syntax
- Integrate TodoWrite for progress tracking
- Preserve parallel spawning pattern
- Maintain researchPath coordination
- Result in same worker spawning as agent would

❌ **Skill must NOT**:
- Use imperative language ("You MUST")
- Restrict tool access (no `tools:` field)
- Include subprocess-specific code
- Assume agent execution context
- Execute tasks directly (advisory only)

### Content Validation

- [ ] YAML frontmatter valid
- [ ] Description includes trigger keywords
- [ ] Quick Start is actionable
- [ ] Workflow steps are clear
- [ ] Examples show Main Claude perspective
- [ ] TodoWrite integration present
- [ ] Task tool syntax correct
- [ ] No agent-specific language
- [ ] Domain logic preserved
- [ ] Parallel spawning guidance clear

---

## 9. NEXT STEPS

1. **Create Skill** using this conversion map
2. **Test Activation** with sample queries
3. **Verify Spawning** behavior matches agent
4. **Iterate** based on test results
5. **Document** any deviations from map
6. **Replicate** for Tier 4 and Tier 5

---

**Status**: Conversion map complete
**Ready for**: Skill creation (Phase 2 of migration)
