# Skill → Hook Conversion Map
## Internet-Search Skill → Hook Router (Phase 1)

**Created**: 2025-11-16
**Source**: `.claude/skills/internet-search/SKILL.md` (v2.0)
**Target**: `.claude/hooks/pre-prompt/internet-search-router.sh`

---

## 1. CURRENT ARCHITECTURE (BROKEN)

```
User Query
    ↓
Main Claude (detects research query)
    ↓
internet-search SKILL (activated automatically)
    ↓
Skill: Analyze query (Steps 2-5)
    ↓
Skill: Select agent (Step 3)
    ↓
Skill: Spawn agent via Task tool ← BLOCKS HERE (Agent → Agent spawning fails)
    ↓
Agent: Try to spawn workers ← NEVER EXECUTES
```

**Problem**: Agent → Agent spawning is blocked. Orchestrator agents can't spawn worker agents.

---

## 2. TARGET ARCHITECTURE (WORKING)

```
User Query
    ↓
PRE-PROMPT HOOK: internet-search-router.sh ← NEW
    ↓
Hook: Analyze query (bash logic)
    ↓
Hook: Determine tier (1-5)
    ↓
Hook: Inject directive into prompt
    ↓
Main Claude (receives amended prompt)
    ↓
Main Claude: Activate appropriate SKILL
    ↓
Skill: Spawn workers via Task tool ← WORKS (Skill → Agent spawning allowed)
```

**Solution**: Hook routes query, Main Claude activates skill, skill spawns agents directly (no Agent → Agent spawning).

---

## 3. SKILL STRUCTURE ANALYSIS

### Internet-Search Skill Components

```
┌─────────────────────────────────────────────┐
│ YAML Frontmatter                            │
│ - name: internet-search                     │
│ - description: (routing triggers)           │
├─────────────────────────────────────────────┤
│ Step 0: Create Research Session             │
│ - Session ID format                         │
│ - Topic slug algorithm                      │
│ - Directory structure                       │
│ - Metadata creation                         │
├─────────────────────────────────────────────┤
│ Step 1: Read Agent Registry                 │ ← Extract to bash variables
│ - 15 agents metadata                        │
│ - Tier classification                       │
├─────────────────────────────────────────────┤
│ Step 2: Query Analysis ⭐ CRITICAL           │ ← Convert to bash logic
│ - Intent classification (5 types)           │
│ - Complexity assessment (5 levels)          │
│ - Domain identification (7 domains)         │
├─────────────────────────────────────────────┤
│ Step 3: Agent Selection Logic ⭐ CRITICAL    │ ← Convert to routing decision
│ - Tier 1: Simple queries                    │
│ - Tier 2: Specialists                       │
│ - Tier 3: Light parallel (2-3 dimensions)   │
│ - Tier 4: Comprehensive (4+ dimensions)     │
│ - Tier 5: Novel domains                     │
├─────────────────────────────────────────────┤
│ Step 4: Confidence Scoring                  │ ← Optional in hook
│ - 0-100 scale                               │
│ - Fallback preparation                      │
├─────────────────────────────────────────────┤
│ Step 5: Cost Optimization ⭐ IMPORTANT       │ ← Dimension counting in bash
│ - Intent override principle                 │
│ - Dimension counting                        │
├─────────────────────────────────────────────┤
│ Step 6: Spawn Agents                        │ ← Replace with directive injection
│ - Task tool calls                           │
│ - researchPath passing                      │
├─────────────────────────────────────────────┤
│ Steps 7-13: Quality gates, synthesis, etc.  │ ← Stays in skills (not in hook)
└─────────────────────────────────────────────┘
```

---

## 4. WHAT MOVES TO HOOK

### ✅ Extract to Hook (Bash Script)

| Skill Component | Hook Equivalent | Why |
|-----------------|-----------------|-----|
| **Step 2: Query Analysis** | Bash regex/keyword matching | Determine intent, complexity, domain |
| **Step 3: Agent Selection** | Routing decision (tier 1-5) | Select which skill to activate |
| **Step 5: Dimension Counting** | Bash word counting | Count distinct research dimensions |
| **Agent Registry** | Embedded bash variables | No need to read JSON in hook |
| **Routing Logic** | If/elif/else chains | Map analysis → tier selection |
| **Directive Injection** | Append to prompt | Tell Main Claude which skill to use |

### ❌ Keep in Skills (Not in Hook)

| Skill Component | Stays Where | Why |
|-----------------|-------------|-----|
| **Step 0: Session Creation** | Skill handles this | Skills have file I/O tools |
| **Step 6: Agent Spawning** | Skill handles this | Skills can use Task tool |
| **Steps 7-13** | Skill handles this | Quality gates, synthesis, iteration |
| **researchPath Management** | Skill handles this | File coordination |
| **Agent Communication** | Skill handles this | Complex orchestration |

---

## 5. HOOK SCRIPT STRUCTURE

### Hook Template

```bash
#!/bin/bash
# .claude/hooks/pre-prompt/internet-search-router.sh
# Pre-prompt hook that analyzes research queries and routes to appropriate tier

# Input: $1 = user query (from hook system)
# Output: Amended prompt with routing directive

QUERY="$1"

# ========================================
# 1. DETECT RESEARCH QUERY
# ========================================
# Check if query is research-related
if ! is_research_query "$QUERY"; then
    # Not research query - pass through unchanged
    echo "$QUERY"
    exit 0
fi

# ========================================
# 2. QUERY ANALYSIS
# ========================================
INTENT=$(analyze_intent "$QUERY")           # information_gathering, analysis, etc.
COMPLEXITY=$(analyze_complexity "$QUERY")   # simple, focused, moderate, comprehensive, novel
DOMAIN=$(analyze_domain "$QUERY")           # web, academic, market, trends, etc.
DIMENSIONS=$(count_dimensions "$QUERY")     # 1, 2, 3, 4+

# ========================================
# 3. TIER ROUTING
# ========================================
TIER=$(route_to_tier "$INTENT" "$COMPLEXITY" "$DOMAIN" "$DIMENSIONS")

# ========================================
# 4. DIRECTIVE INJECTION
# ========================================
case $TIER in
    1)
        # Simple query - direct agent spawning
        DIRECTIVE="Use web-researcher agent for this simple lookup."
        ;;
    2)
        # Specialist query - specific agent
        AGENT=$(select_specialist "$DOMAIN")
        DIRECTIVE="Use $AGENT agent for this focused research."
        ;;
    3)
        # Light parallel - orchestrator skill
        DIRECTIVE="Use tier-3-light-research skill to coordinate parallel research across $DIMENSIONS dimensions."
        ;;
    4)
        # Comprehensive - deep orchestrator skill
        DIRECTIVE="Use tier-4-deep-research skill for comprehensive 7-phase research across $DIMENSIONS dimensions."
        ;;
    5)
        # Novel domain - adaptive orchestrator skill
        DIRECTIVE="Use tier-5-novel-research skill for adaptive research in this emerging domain."
        ;;
esac

# ========================================
# 5. OUTPUT AMENDED PROMPT
# ========================================
cat <<EOF
$QUERY

---
[ROUTING DIRECTIVE]
$DIRECTIVE
Research Path: docs/research-sessions/$(date +%d%m%Y_%H%M%S)_$(generate_topic_slug "$QUERY")/
Tier: $TIER
Intent: $INTENT
Complexity: $COMPLEXITY
Domain: $DOMAIN
Dimensions: $DIMENSIONS
EOF
```

---

## 6. CONVERSION MAPPING

### Step 2: Query Analysis (Skill → Hook)

**Skill Version** (Main Claude logic):
```markdown
### Step 2: Query Analysis

Analyze the user's query to extract:

**Intent Classification:**
- `information_gathering`: General web searches, definitions, current events
- `analysis`: Deep investigation, synthesis, pattern identification
- `verification`: Fact-checking, source validation
- `forecasting`: Future trends, predictions, scenario planning
- `synthesis`: Combining multiple research findings

**Complexity Assessment:**
- `simple`: Single-dimension, straightforward lookup (1 clear question)
- `focused`: Single-domain expertise required (academic, market, trends, competitive)
- `moderate`: Standard research with 2-3 dimensions, parallel exploration needed
- `comprehensive`: Multi-dimensional, 4+ aspects, requires full orchestration
- `novel`: Emerging domain, no established research patterns

**Domain Identification:**
- `web`: General internet information
- `academic`: Peer-reviewed papers, scholarly sources
- `market`: Market sizing, segmentation, consumer insights
- `competitive`: Competitor analysis, SWOT, positioning
- `trends`: Future forecasting, weak signals, scenario planning
- `multi`: Multiple domains required
```

**Hook Version** (Bash script):
```bash
analyze_intent() {
    local query="$1"

    # Check for verification keywords
    if echo "$query" | grep -iE "verify|fact.?check|is.?true|correct|accurate" >/dev/null; then
        echo "verification"
        return
    fi

    # Check for forecasting keywords
    if echo "$query" | grep -iE "forecast|predict|future|trend|will.?happen|next.*years?" >/dev/null; then
        echo "forecasting"
        return
    fi

    # Check for synthesis keywords
    if echo "$query" | grep -iE "synthesize|combine|compare.*contrast|summarize.*from" >/dev/null; then
        echo "synthesis"
        return
    fi

    # Check for analysis keywords
    if echo "$query" | grep -iE "analyze|investigate|deep.*dive|comprehensive|examine" >/dev/null; then
        echo "analysis"
        return
    fi

    # Default: information gathering
    echo "information_gathering"
}

analyze_complexity() {
    local query="$1"
    local dimensions=$(count_dimensions "$query")

    # Novel domain detection
    if echo "$query" | grep -iE "emerging|new|novel|unprecedented|cutting.?edge" >/dev/null; then
        echo "novel"
        return
    fi

    # Dimension-based complexity
    if [ "$dimensions" -ge 4 ]; then
        echo "comprehensive"
    elif [ "$dimensions" -eq 2 ] || [ "$dimensions" -eq 3 ]; then
        echo "moderate"
    else
        # Check if single domain specialist needed
        if is_specialist_query "$query"; then
            echo "focused"
        else
            echo "simple"
        fi
    fi
}

analyze_domain() {
    local query="$1"

    # Academic keywords
    if echo "$query" | grep -iE "paper|research|study|academic|peer.?review|literature" >/dev/null; then
        echo "academic"
        return
    fi

    # Market keywords
    if echo "$query" | grep -iE "market|TAM|SAM|SOM|market.?size|segment|consumer" >/dev/null; then
        echo "market"
        return
    fi

    # Competitive keywords
    if echo "$query" | grep -iE "competitor|competitive|SWOT|position|landscape" >/dev/null; then
        echo "competitive"
        return
    fi

    # Trends keywords
    if echo "$query" | grep -iE "trend|forecast|future|predict|emerging|pattern" >/dev/null; then
        echo "trends"
        return
    fi

    # Default: web
    echo "web"
}

count_dimensions() {
    local query="$1"
    local count=1

    # Count explicit dimensions (separated by "and", commas, bullet points)
    # "Research quantum computing hardware and algorithms" = 2 dimensions
    # "Analyze market, competitors, and trends" = 3 dimensions

    # Count "and" separators
    count=$((count + $(echo "$query" | grep -o " and " | wc -l)))

    # Count comma separators
    count=$((count + $(echo "$query" | grep -o "," | wc -l)))

    # Cap at reasonable max
    if [ "$count" -gt 10 ]; then
        count=10
    fi

    echo "$count"
}
```

---

### Step 3: Agent Selection (Skill → Hook)

**Skill Version**:
```markdown
**Tier 1 - Simple Queries:**
Selection criteria: Intent is `information_gathering` AND complexity is `simple` AND domain is `web`

**Tier 2 - Specialists:**
Selection criteria: Complexity is `focused` AND domain matches specialist expertise

**Tier 3 - Light Parallel:**
Selection criteria: Complexity is `moderate` AND 2-3 dimensions detected

**Tier 4 - Comprehensive:**
Selection criteria: Complexity is `comprehensive` AND 4+ dimensions

**Tier 5 - Novel Domains:**
Selection criteria: Complexity is `novel` OR domain is emerging/unknown
```

**Hook Version** (Bash routing):
```bash
route_to_tier() {
    local intent="$1"
    local complexity="$2"
    local domain="$3"
    local dimensions="$4"

    # Tier 5: Novel domains
    if [ "$complexity" = "novel" ]; then
        echo "5"
        return
    fi

    # Tier 4: Comprehensive (4+ dimensions)
    if [ "$complexity" = "comprehensive" ] || [ "$dimensions" -ge 4 ]; then
        echo "4"
        return
    fi

    # Tier 3: Moderate (2-3 dimensions)
    if [ "$complexity" = "moderate" ] || [ "$dimensions" -eq 2 ] || [ "$dimensions" -eq 3 ]; then
        echo "3"
        return
    fi

    # Tier 2: Focused specialist
    if [ "$complexity" = "focused" ]; then
        echo "2"
        return
    fi

    # Tier 1: Simple
    echo "1"
}

select_specialist() {
    local domain="$1"

    case "$domain" in
        academic)
            echo "academic-researcher"
            ;;
        market)
            echo "market-researcher"
            ;;
        competitive)
            echo "competitive-analyst"
            ;;
        trends)
            echo "trend-analyst"
            ;;
        *)
            echo "web-researcher"
            ;;
    esac
}
```

---

### Step 5: Cost Optimization (Skill → Hook)

**Skill Version**:
```markdown
**Intent Override Principle**: True query intent overrides keyword inflation.

Example:
Query: "I need comprehensive, thorough, in-depth research on what RTC stands for"
Keywords suggest: comprehensive (Tier 3)
Actual intent: Simple definition lookup (Tier 1)
Decision: Route to web-researcher (Tier 1)

**Dimension Counting**: Count distinct research dimensions.
Query: "Research electric vehicles in terms of batteries and charging"
Dimensions: 2 (batteries, charging)
Decision: Tier 3
```

**Hook Version**:
```bash
optimize_routing() {
    local query="$1"
    local tier="$2"

    # Intent override: Check if inflated keywords with simple intent
    if echo "$query" | grep -iE "comprehensive|thorough|in.?depth|extensive" >/dev/null; then
        # Check if actually asking simple question
        if echo "$query" | grep -iE "what is|define|meaning of|stands for" >/dev/null; then
            # Override to Tier 1 (simple lookup)
            echo "1"
            return
        fi
    fi

    # Otherwise use original tier
    echo "$tier"
}
```

---

### Directive Injection (New in Hook)

**Not in Skill** - This is new functionality.

**Hook Creates Directive**:
```bash
generate_directive() {
    local tier="$1"
    local dimensions="$2"
    local domain="$3"

    case "$tier" in
        1)
            echo "This is a simple lookup. Use web-researcher agent directly."
            ;;
        2)
            agent=$(select_specialist "$domain")
            echo "This requires domain expertise. Use $agent agent."
            ;;
        3)
            echo "This is a $dimensions-dimension research query. Use tier-3-light-research skill to coordinate parallel researchers."
            ;;
        4)
            echo "This is a comprehensive multi-dimensional query. Use tier-4-deep-research skill for 7-phase RBMAS research."
            ;;
        5)
            echo "This is a novel/emerging domain query. Use tier-5-novel-research skill for adaptive TODAS research."
            ;;
    esac
}
```

---

## 7. HOOK OUTPUT FORMAT

### Hook Appends Directive to Prompt

**User Query** (input):
```
Research cloud gaming latency optimization techniques
```

**Hook Output** (amended prompt):
```
Research cloud gaming latency optimization techniques

---
[ROUTING DIRECTIVE]
This is a 3-dimension research query. Use tier-3-light-research skill to coordinate parallel researchers.

Research Path: docs/research-sessions/16112025_192800_cloud_gaming_latency_optimization/
Tier: 3
Intent: analysis
Complexity: moderate
Domain: web
Dimensions: 3
```

**Main Claude Receives**:
- Original query
- Routing directive (which skill to use)
- Session path (pre-generated)
- Analysis metadata (for skill's use)

**Main Claude Then**:
1. Reads directive: "Use tier-3-light-research skill"
2. Activates tier-3-light-research skill
3. Skill spawns light-research-researcher agents
4. Workers execute research
5. Results synthesized

---

## 8. WHAT STAYS IN SKILLS

### Session Management (Skill, Not Hook)

**Why**: Skills have file I/O tools (Bash, Write, Glob), hooks are lightweight.

```markdown
Skills handle:
- Creating session directory (mkdir -p)
- Writing .meta.json
- Managing research files
- Coordinating worker outputs
- Synthesis and reporting
```

**Hook only**:
- Generates session ID (in directive)
- Passes to skill via prompt amendment

### Agent Spawning (Skill, Not Hook)

**Why**: Skills can use Task tool, hooks cannot.

```markdown
Skills handle:
- Task tool calls
- Spawning workers (light-research-researcher, etc.)
- Passing researchPath to workers
- Coordinating parallel execution
- Spawning synthesizer
```

**Hook only**:
- Decides WHICH skill should do the spawning
- Injects directive to activate skill

### Quality Gates & Synthesis (Skills, Not Hook)

**Why**: Complex multi-step workflows require Main Claude context.

```markdown
Skills handle:
- Quality gate validation
- Auto-retry logic
- Iteration support
- Final synthesis
- Result reporting
```

**Hook**: Not involved (pre-prompt only)

---

## 9. HOOK INTEGRATION WITH CLAUDE CODE

### Hook Configuration

**Location**: `.claude/hooks/pre-prompt/internet-search-router.sh`

**Hook Registration** (may need settings update):
```json
{
  "hooks": {
    "PrePrompt": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/pre-prompt/internet-search-router.sh"
          }
        ]
      }
    ]
  }
}
```

### Hook Execution Flow

```
1. User types query: "Research quantum computing"
2. Claude Code triggers PrePrompt hook
3. Hook script runs:
   - Analyzes query (bash functions)
   - Determines tier (3 - moderate complexity, 2 dimensions)
   - Generates directive
   - Appends to prompt
4. Main Claude receives amended prompt
5. Main Claude activates tier-3-light-research skill
6. Skill spawns workers via Task tool
7. Research completes
```

---

## 10. CONVERSION CHECKLIST

### Pre-Conversion

- [x] Read internet-search skill fully
- [x] Identify query analysis logic (Steps 2-5)
- [x] Identify routing logic (Step 3)
- [x] Understand skill activation pattern
- [ ] Review Claude Code hook documentation

### During Conversion

Core Logic:
- [ ] Extract intent classification → Bash function
- [ ] Extract complexity assessment → Bash function
- [ ] Extract domain identification → Bash function
- [ ] Extract dimension counting → Bash function
- [ ] Convert agent selection logic → Tier routing
- [ ] Create directive injection logic

Hook Structure:
- [ ] Write hook shebang and header
- [ ] Implement is_research_query() filter
- [ ] Implement analysis functions (4 functions)
- [ ] Implement routing function
- [ ] Implement specialist selection
- [ ] Implement directive generation
- [ ] Implement prompt amendment output

### Post-Conversion

Testing:
- [ ] Test with Tier 1 query (simple lookup)
- [ ] Test with Tier 2 query (specialist)
- [ ] Test with Tier 3 query (2-3 dimensions)
- [ ] Test with Tier 4 query (4+ dimensions)
- [ ] Test with Tier 5 query (novel domain)
- [ ] Verify directive formatting
- [ ] Verify Main Claude activates correct skill
- [ ] Verify session path generation

---

## 11. KEY DIFFERENCES: SKILL VS HOOK

| Aspect | Skill (Current) | Hook (Target) |
|--------|-----------------|---------------|
| **Execution** | Main Claude activates | Claude Code triggers (pre-prompt) |
| **Language** | Markdown instructions | Bash script |
| **Tools** | Task, Read, Write, etc. | Standard bash (grep, echo, etc.) |
| **Purpose** | Orchestrate research | Route queries |
| **Output** | Research results | Amended prompt with directive |
| **Complexity** | Full workflow (Steps 0-13) | Simple analysis + routing |
| **Agent Spawning** | Yes (via Task tool) | No (delegates to skill) |
| **Session Management** | Yes (creates files) | No (generates path only) |
| **When Runs** | After query received | Before query reaches Main Claude |

---

## 12. EXPECTED HOOK SIZE

**Estimated**: 200-300 lines of bash

**Breakdown**:
- Header/comments: ~20 lines
- Helper functions: ~150 lines
  - is_research_query(): ~15 lines
  - analyze_intent(): ~30 lines
  - analyze_complexity(): ~25 lines
  - analyze_domain(): ~30 lines
  - count_dimensions(): ~15 lines
  - route_to_tier(): ~20 lines
  - select_specialist(): ~15 lines
- Main logic: ~50 lines
- Directive generation: ~30 lines
- Output formatting: ~20 lines

**Reference**: Similar bash routing scripts range 150-400 lines.

---

## 13. VALIDATION CRITERIA

### Functional Validation

✅ **Hook must**:
- Detect research queries accurately
- Classify intent correctly (5 types)
- Assess complexity correctly (5 levels)
- Identify domain correctly (7 domains)
- Count dimensions accurately
- Route to correct tier (1-5)
- Generate valid directive
- Preserve original query
- Output valid amended prompt

❌ **Hook must NOT**:
- Spawn agents (delegates to skill)
- Create session folders (skill does this)
- Perform actual research
- Use Claude Code tools (bash only)
- Block non-research queries

### Output Validation

Hook output must include:
- [ ] Original user query (unchanged)
- [ ] Routing directive (which skill to use)
- [ ] Session path (pre-generated)
- [ ] Metadata (tier, intent, complexity, domain, dimensions)
- [ ] Proper formatting (readable by Main Claude)

---

## 14. NEXT STEPS

1. **Implement Hook Script** using this conversion map
2. **Test Standalone** (bash script execution)
3. **Integrate with Claude Code** (hook registration)
4. **Test End-to-End** (query → hook → Main Claude → skill)
5. **Verify Routing** (correct tier selection)
6. **Document Deviations** (any changes from map)

---

**Status**: Conversion map complete
**Ready for**: Hook router implementation (Phase 1 of migration)
**Dependency**: This hook must work before Phase 2 skills can be tested
