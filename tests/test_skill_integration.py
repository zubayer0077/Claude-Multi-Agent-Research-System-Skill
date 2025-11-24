#!/usr/bin/env python3
"""
Integration Test for spec-workflow-orchestrator Skill

This script automates end-to-end testing by:
1. Calling the Anthropic API directly with agent prompts
2. Simulating the Write tool (saving outputs to files)
3. Chaining outputs: spec-analyst → spec-architect → spec-planner
4. Validating structure and content of outputs

Requirements:
- ANTHROPIC_API_KEY environment variable
- anthropic Python package (pip install anthropic)

Usage:
    python3 tests/test_skill_integration.py [--dry-run] [--model MODEL]

Options:
    --dry-run   Show prompts without calling API
    --model     Model to use (default: claude-sonnet-4-20250514)
    --quick     Use minimal prompts for faster testing
"""

import os
import sys
import json
import argparse
import re
from pathlib import Path
from datetime import datetime
from typing import Optional, Tuple

# Colors for output
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
CYAN = '\033[96m'
RESET = '\033[0m'
BOLD = '\033[1m'

# Test configuration
TEST_PROJECT_SLUG = "integration-test-hello-world"
TEST_PROJECT_DIR = Path("tests/fixtures/generated") / TEST_PROJECT_SLUG

# Minimal test prompt for quick validation
QUICK_TEST_PROMPT = """
Build a simple "Hello World" web page with:
- A heading that says "Hello, World!"
- A button that shows an alert when clicked
- Basic styling (centered content, nice font)

This is a minimal test project for validation purposes.
"""

# Full test prompt for comprehensive validation
FULL_TEST_PROMPT = """
Build a task management web application with:
- User can create, edit, and delete tasks
- Tasks have title, description, due date, and priority
- Tasks can be marked as complete
- Filter tasks by status (all, active, completed)
- Simple and clean user interface
- Local storage for persistence (no backend required)

Target: Solo developer, 1-2 week implementation timeline.
"""


def check_api_key() -> bool:
    """Check if Anthropic API key is available."""
    if not os.environ.get('ANTHROPIC_API_KEY'):
        print(f"{RED}ERROR: ANTHROPIC_API_KEY environment variable not set{RESET}")
        print(f"\nTo run this test:")
        print(f"  export ANTHROPIC_API_KEY='your-api-key'")
        print(f"  python3 tests/test_skill_integration.py")
        return False
    return True


def create_project_structure():
    """Create the test project directory structure."""
    planning_dir = TEST_PROJECT_DIR / "planning"
    adrs_dir = TEST_PROJECT_DIR / "adrs"

    planning_dir.mkdir(parents=True, exist_ok=True)
    adrs_dir.mkdir(parents=True, exist_ok=True)

    print(f"{BLUE}Created test project structure at: {TEST_PROJECT_DIR}{RESET}")
    return planning_dir, adrs_dir


def read_agent_definition(agent_name: str) -> str:
    """Read agent definition from .claude/agents/"""
    agent_path = Path(f".claude/agents/{agent_name}.md")
    if not agent_path.exists():
        raise FileNotFoundError(f"Agent definition not found: {agent_path}")
    return agent_path.read_text()


def build_analyst_prompt(user_request: str, output_path: Path) -> str:
    """Build the prompt for spec-analyst agent."""
    return f"""You are spec-analyst, a requirements analysis specialist.

## Your Task
Analyze the following user request and create a comprehensive requirements document.

## User Request
{user_request}

## Output Format
Create a requirements document with these sections:
1. Executive Summary
2. Functional Requirements (FR-001, FR-002, etc.)
3. Non-Functional Requirements (NFR-001, NFR-002, etc.) with quantitative metrics
4. User Stories with acceptance criteria
5. Stakeholders
6. Constraints and Assumptions
7. Success Metrics

## Output
Generate the complete requirements.md content. Be thorough but concise.
The output will be saved to: {output_path}

Begin your response with the markdown content directly (no code fences needed):
"""


def build_architect_prompt(user_request: str, requirements_content: str, output_path: Path, adrs_path: Path) -> str:
    """Build the prompt for spec-architect agent."""
    return f"""You are spec-architect, a system design specialist.

## Your Task
Design the system architecture based on the requirements document.

## Original User Request
{user_request}

## Requirements Document
{requirements_content}

## Output Format
Create an architecture document with:
1. Executive Summary
2. Technology Stack (with justification)
3. System Components
4. Component Interactions
5. Data Model / Schema
6. API Specifications (if applicable)
7. Security Considerations
8. Performance Considerations
9. Deployment Strategy

Also create 3-5 Architecture Decision Records (ADRs) for key decisions.

## ADR Format
Each ADR should have:
- ## Status (Accepted)
- ## Context (what problem)
- ## Decision (what we chose)
- ## Consequences (positive and negative)
- ## Alternatives Considered

## Output Instructions
1. First, output the architecture.md content
2. Then, output each ADR with a clear separator: "---ADR-XXX---"

Example structure:
[architecture.md content here]

---ADR-001-technology-choice---
# ADR-001: Technology Choice
## Status
Accepted
...

---ADR-002-data-storage---
# ADR-002: Data Storage
...

Begin your response with the markdown content directly:
"""


def build_planner_prompt(user_request: str, requirements_content: str, architecture_content: str, output_path: Path) -> str:
    """Build the prompt for spec-planner agent."""
    return f"""You are spec-planner, an implementation planning specialist.

## Your Task
Create a detailed task breakdown based on requirements and architecture.

## Original User Request
{user_request}

## Requirements Summary
{requirements_content[:3000]}...

## Architecture Summary
{architecture_content[:3000]}...

## Output Format
Create a tasks document with:
1. Executive Summary
2. Implementation Phases (Phase 1, Phase 2, etc.)
3. Task Breakdown with:
   - Task ID (TASK-001, etc.)
   - Description
   - Complexity (S/M/L)
   - Effort Estimate (hours)
   - Dependencies
   - Acceptance Criteria
4. Risk Assessment
5. Testing Strategy
6. Timeline Overview

## Output
Generate the complete tasks.md content.

Begin your response with the markdown content directly:
"""


def call_claude_api(prompt: str, model: str = "claude-sonnet-4-20250514", max_tokens: int = 8000) -> str:
    """Call the Anthropic API with the given prompt."""
    try:
        import anthropic
    except ImportError:
        print(f"{RED}ERROR: anthropic package not installed{RESET}")
        print(f"Install with: pip install anthropic")
        sys.exit(1)

    client = anthropic.Anthropic()

    print(f"{CYAN}  Calling Claude API ({model})...{RESET}")

    response = client.messages.create(
        model=model,
        max_tokens=max_tokens,
        messages=[{"role": "user", "content": prompt}]
    )

    return response.content[0].text


def parse_architect_output(content: str) -> Tuple[str, list]:
    """Parse architect output into architecture.md and ADRs."""
    # Split by ADR markers
    parts = re.split(r'---ADR-(\d+)-([a-z-]+)---', content)

    architecture_content = parts[0].strip()
    adrs = []

    # Parse ADRs (parts come in groups of 3: content, number, name)
    i = 1
    while i < len(parts) - 2:
        adr_num = parts[i]
        adr_name = parts[i + 1]
        adr_content = parts[i + 2].strip() if i + 2 < len(parts) else ""

        if adr_content:
            adrs.append({
                'number': adr_num,
                'name': adr_name,
                'content': adr_content
            })
        i += 3

    # If no ADRs parsed with markers, try to find them in content
    if not adrs and '# ADR-' in content:
        # Fallback: split by ADR headers
        adr_matches = re.findall(r'(# ADR-(\d+)[:\s-]+([^\n]+)\n(.*?)(?=# ADR-|\Z))', content, re.DOTALL)
        for match in adr_matches:
            full, num, name, body = match
            adrs.append({
                'number': num,
                'name': name.lower().replace(' ', '-'),
                'content': f"# ADR-{num}: {name}\n{body.strip()}"
            })

    return architecture_content, adrs


def validate_output(file_path: Path, required_patterns: list) -> Tuple[bool, list]:
    """Validate that a file contains required patterns."""
    if not file_path.exists():
        return False, [f"File not found: {file_path}"]

    content = file_path.read_text().lower()
    missing = []

    for pattern in required_patterns:
        if pattern.lower() not in content:
            missing.append(pattern)

    return len(missing) == 0, missing


def run_integration_test(dry_run: bool = False, model: str = "claude-sonnet-4-20250514", quick: bool = False):
    """Run the full integration test."""
    print(f"\n{BOLD}{BLUE}{'='*60}{RESET}")
    print(f"{BOLD}{BLUE}  Skill Integration Test{RESET}")
    print(f"{BOLD}{BLUE}{'='*60}{RESET}\n")

    if not dry_run and not check_api_key():
        return False

    # Select test prompt
    test_prompt = QUICK_TEST_PROMPT if quick else FULL_TEST_PROMPT
    print(f"{BLUE}Test Mode:{RESET} {'Quick (minimal)' if quick else 'Full (comprehensive)'}")
    print(f"{BLUE}Model:{RESET} {model}")
    print(f"{BLUE}Dry Run:{RESET} {dry_run}")
    print()

    # Create project structure
    planning_dir, adrs_dir = create_project_structure()

    results = {
        'analyst': {'status': 'pending', 'file': None},
        'architect': {'status': 'pending', 'file': None, 'adrs': []},
        'planner': {'status': 'pending', 'file': None},
    }

    # ========================================
    # Phase 1: spec-analyst
    # ========================================
    print(f"\n{BOLD}Phase 1: spec-analyst{RESET}")
    print("-" * 40)

    requirements_path = planning_dir / "requirements.md"
    analyst_prompt = build_analyst_prompt(test_prompt, requirements_path)

    if dry_run:
        print(f"{YELLOW}[DRY RUN] Would call API with analyst prompt ({len(analyst_prompt)} chars){RESET}")
        # Create minimal fixture for dry run
        requirements_content = "# Requirements\n## Functional Requirements\n### FR-001\nTest requirement"
    else:
        print(f"  Generating requirements...")
        requirements_content = call_claude_api(analyst_prompt, model)

    requirements_path.write_text(requirements_content)
    print(f"  {GREEN}✓{RESET} Saved: {requirements_path}")
    results['analyst']['status'] = 'complete'
    results['analyst']['file'] = requirements_path

    # ========================================
    # Phase 2: spec-architect
    # ========================================
    print(f"\n{BOLD}Phase 2: spec-architect{RESET}")
    print("-" * 40)

    architecture_path = planning_dir / "architecture.md"
    architect_prompt = build_architect_prompt(test_prompt, requirements_content, architecture_path, adrs_dir)

    if dry_run:
        print(f"{YELLOW}[DRY RUN] Would call API with architect prompt ({len(architect_prompt)} chars){RESET}")
        architecture_content = "# Architecture\n## Technology Stack\nTest stack\n## Components\nTest components"
        adrs = [{'number': '001', 'name': 'test', 'content': '# ADR-001\n## Status\nAccepted\n## Context\nTest\n## Decision\nTest'}]
    else:
        print(f"  Generating architecture and ADRs...")
        architect_output = call_claude_api(architect_prompt, model, max_tokens=12000)
        architecture_content, adrs = parse_architect_output(architect_output)

    architecture_path.write_text(architecture_content)
    print(f"  {GREEN}✓{RESET} Saved: {architecture_path}")

    # Save ADRs
    for adr in adrs:
        adr_filename = f"ADR-{adr['number'].zfill(3)}-{adr['name']}.md"
        adr_path = adrs_dir / adr_filename
        adr_path.write_text(adr['content'])
        print(f"  {GREEN}✓{RESET} Saved: {adr_path}")
        results['architect']['adrs'].append(adr_path)

    results['architect']['status'] = 'complete'
    results['architect']['file'] = architecture_path

    # ========================================
    # Phase 3: spec-planner
    # ========================================
    print(f"\n{BOLD}Phase 3: spec-planner{RESET}")
    print("-" * 40)

    tasks_path = planning_dir / "tasks.md"
    planner_prompt = build_planner_prompt(test_prompt, requirements_content, architecture_content, tasks_path)

    if dry_run:
        print(f"{YELLOW}[DRY RUN] Would call API with planner prompt ({len(planner_prompt)} chars){RESET}")
        tasks_content = "# Tasks\n## Phase 1\n### TASK-001\nTest task\n## Risk Assessment\nTest risks"
    else:
        print(f"  Generating task breakdown...")
        tasks_content = call_claude_api(planner_prompt, model)

    tasks_path.write_text(tasks_content)
    print(f"  {GREEN}✓{RESET} Saved: {tasks_path}")
    results['planner']['status'] = 'complete'
    results['planner']['file'] = tasks_path

    # ========================================
    # Validation
    # ========================================
    print(f"\n{BOLD}Validation{RESET}")
    print("-" * 40)

    validation_results = []

    # Validate requirements
    req_valid, req_missing = validate_output(requirements_path, [
        "functional requirements", "non-functional", "user stor"
    ])
    validation_results.append(('requirements.md', req_valid, req_missing))

    # Validate architecture
    arch_valid, arch_missing = validate_output(architecture_path, [
        "technology", "component", "security"
    ])
    validation_results.append(('architecture.md', arch_valid, arch_missing))

    # Validate tasks
    tasks_valid, tasks_missing = validate_output(tasks_path, [
        "phase", "task", "risk"
    ])
    validation_results.append(('tasks.md', tasks_valid, tasks_missing))

    # Validate ADR count
    adr_count = len(list(adrs_dir.glob("ADR-*.md")))
    adr_valid = 3 <= adr_count <= 7
    validation_results.append(('ADR count', adr_valid, [] if adr_valid else [f"Found {adr_count}, expected 3-7"]))

    # Print validation results
    all_valid = True
    for name, valid, missing in validation_results:
        if valid:
            print(f"  {GREEN}✓{RESET} {name}")
        else:
            print(f"  {RED}✗{RESET} {name}: Missing {missing}")
            all_valid = False

    # ========================================
    # Summary
    # ========================================
    print(f"\n{BOLD}{'='*60}{RESET}")
    print(f"{BOLD}  SUMMARY{RESET}")
    print(f"{'='*60}\n")

    print(f"  Project: {TEST_PROJECT_DIR}")
    print(f"  Files created:")
    print(f"    - planning/requirements.md")
    print(f"    - planning/architecture.md")
    print(f"    - planning/tasks.md")
    print(f"    - {adr_count} ADRs")
    print()

    if all_valid:
        print(f"  {GREEN}{BOLD}✓ ALL VALIDATIONS PASSED{RESET}")
        print()
        print(f"  You can now run structural validation:")
        print(f"    ./tests/test_deliverable_structure.sh {TEST_PROJECT_SLUG}")
        print(f"    python3 tests/test_adr_format.py {TEST_PROJECT_SLUG}")
    else:
        print(f"  {RED}{BOLD}✗ SOME VALIDATIONS FAILED{RESET}")

    return all_valid


def main():
    parser = argparse.ArgumentParser(description='Integration test for spec-workflow-orchestrator')
    parser.add_argument('--dry-run', action='store_true', help='Show prompts without calling API')
    parser.add_argument('--model', default='claude-sonnet-4-20250514', help='Model to use')
    parser.add_argument('--quick', action='store_true', help='Use minimal prompts for faster testing')

    args = parser.parse_args()

    success = run_integration_test(
        dry_run=args.dry_run,
        model=args.model,
        quick=args.quick
    )

    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
