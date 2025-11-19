# Session Log Viewer - Implementation Tasks

**Project**: Claude Multi-Agent Research System - Session Log Viewer
**Version**: 1.0
**Date**: 2025-11-19
**Status**: Implementation Plan Complete

---

## Executive Summary

This document provides a comprehensive breakdown of implementation tasks for the Session Log Viewer web application. The project is structured into **4 phases** aligned with the MVP-first approach, with **68 atomic tasks** totaling approximately **22-25 person-days** of effort for a single developer.

### Overview

| Metric | Value |
|--------|-------|
| **Total Tasks** | 68 tasks |
| **Estimated Effort** | 22-25 person-days (176-200 hours) |
| **Critical Path** | T1.1 → T1.2 → T1.3 → T1.8 → T2.1 → T3.1 |
| **Parallel Streams** | 3 streams (backend, frontend, testing) |
| **Implementation Phases** | 4 phases (MVP, Filtering, Analytics, Optimization) |

### Critical Path Tasks

The following tasks block the most downstream work and should be prioritized:

1. **T1.1**: Project setup and directory structure (blocks all)
2. **T1.2**: SQLite database schema creation (blocks backend)
3. **T1.3**: Log parser for transcript.txt (blocks indexing)
4. **T1.8**: FastAPI server with basic endpoints (blocks frontend integration)
5. **T2.1**: Implement FTS5 full-text search (blocks search features)
6. **T3.1**: Analytics data aggregation (blocks dashboard)

### Parallel Development Streams

The project can be developed in parallel across 3 streams:

| Stream | Focus | Can Start After | Example Tasks |
|--------|-------|-----------------|---------------|
| **Backend** | Python server, database, parsing | T1.1 | T1.2, T1.3, T1.4, T1.5, T2.1 |
| **Frontend** | HTML/CSS/JS UI components | T1.1 | T1.9, T1.10, T1.11, T1.12 |
| **Testing** | Unit tests, integration tests | T1.3 (parser), T1.8 (API) | T1.14, T2.7, T3.8 |

---

## Implementation Phases

### Phase 1: MVP - Core Functionality (Weeks 1-2)
**Goal**: Basic log viewing and keyword search
**Effort**: 10-12 person-days

**Deliverables**:
- Working Python FastAPI server
- SQLite database with session metadata
- Log file parsing (transcript.txt, tool_calls.jsonl)
- Session list view with pagination
- Session detail view with transcript display
- Basic keyword search (SQLite FTS5)
- Local HTTP server startup script

**Success Criteria**:
- User can browse all sessions
- User can search by keyword in < 2s
- User can view full transcript and tool calls
- Application loads in < 3s for 1,000 sessions

---

### Phase 2: Filtering & Search (Week 3)
**Goal**: Multi-dimensional filtering (tools, agents, skills)
**Effort**: 5-6 person-days

**Deliverables**:
- Filter by tool name (dropdown UI)
- Filter by agent name (dropdown UI)
- Filter by skill name (dropdown UI)
- Combined filters (AND logic)
- In-memory inverted index for fast filtering
- Filter panel sidebar in UI

**Success Criteria**:
- Filters apply in < 500ms
- User can combine multiple filters
- Filter dropdowns show usage counts
- Filter state persists in localStorage

---

### Phase 3: Analytics & Topics (Week 4)
**Goal**: Cross-session topic tracking and analytics dashboard
**Effort**: 5-6 person-days

**Deliverables**:
- Analytics dashboard with charts (Chart.js)
- Topic creation and tagging system
- Topic detail view with session list
- Topic suggestion algorithm (keyword similarity)
- Export functionality (CSV, Markdown, JSON)
- Statistics aggregation (tool usage, agent counts)

**Success Criteria**:
- User can create and manage topics
- Dashboard shows key statistics
- Export generates valid files
- Topic suggestions are relevant (>70% accuracy)

---

### Phase 4: Optimization & Polish (Week 5)
**Goal**: Performance tuning and production readiness
**Effort**: 2-3 person-days

**Deliverables**:
- Virtual scrolling for large session lists
- Incremental indexing (only parse new files)
- Performance profiling and optimization
- Error handling and logging improvements
- Documentation (README, API docs)
- End-to-end testing suite

**Success Criteria**:
- Handles 10,000+ sessions gracefully
- Memory usage < 500MB
- Initial load < 3s (cold start with indexing)
- All tests pass

---

## Phase 1: MVP - Core Functionality

### T1.1: Project Setup and Directory Structure
**Complexity**: Low
**Effort**: 2 hours
**Dependencies**: None
**Priority**: Critical

**Description**: Initialize project structure, create directory tree, set up Python virtual environment, and configure gitignore.

**Subtasks**:
- [ ] Create `web-viewer/` directory at project root
- [ ] Initialize Python virtual environment
- [ ] Create `requirements.txt` with dependencies (FastAPI, uvicorn, orjson, python-dateutil)
- [ ] Create directory structure: `static/`, `src/`, `data/`, `tests/`, `scripts/`
- [ ] Create subdirectories: `static/css/`, `static/js/`, `static/js/components/`, `static/lib/`
- [ ] Add `data/` and `__pycache__/` to `.gitignore`
- [ ] Create empty `README.md` stub

**Acceptance Criteria**:
- GIVEN project repository WHEN web-viewer/ is created THEN directory structure matches architecture document
- WHEN running `pip install -r requirements.txt` THEN all dependencies install without errors
- WHEN running `git status` THEN data/ directory is not tracked

**Technical Notes**:
- Use Python 3.8+ for compatibility
- Pin dependency versions in requirements.txt

---

### T1.2: SQLite Database Schema Creation
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: T1.1
**Priority**: Critical

**Description**: Implement SQLite database schema with tables for sessions, tool_calls, transcripts_fts, topics, and session_topics.

**Subtasks**:
- [ ] Create `src/database.py` module
- [ ] Implement `init_database()` function with CREATE TABLE statements
- [ ] Create `sessions` table with columns: session_id (PK), start_time, duration_seconds, tool_call_count, unique_tools, unique_agents, has_errors, transcript_path, tool_calls_path, file_mtime
- [ ] Create `tool_calls` table with columns: id (PK), session_id (FK), timestamp, agent, tool, input_json, output_json, success, duration_ms
- [ ] Create FTS5 virtual table `transcripts_fts` with columns: session_id UNINDEXED, content
- [ ] Create `topics` table with columns: topic_id (PK), name (UNIQUE), description, created_at
- [ ] Create `session_topics` junction table with columns: session_id (FK), topic_id (FK), tagged_at
- [ ] Create indexes on foreign keys and frequently queried columns (tool, agent, session_id)
- [ ] Enable WAL mode for better concurrency
- [ ] Add FOREIGN KEY constraints with CASCADE DELETE

**Acceptance Criteria**:
- GIVEN empty database WHEN `init_database()` is called THEN all tables and indexes are created
- WHEN inserting test data THEN foreign key constraints are enforced
- WHEN querying sessions by tool THEN index is used (verify with EXPLAIN QUERY PLAN)

**Technical Notes**:
- Use `sqlite3` module (built-in)
- SQLite 3.32+ required for FTS5 support
- Enable foreign keys: `PRAGMA foreign_keys = ON`

---

### T1.3: Log Parser - Parse transcript.txt
**Complexity**: High
**Effort**: 4 hours
**Dependencies**: T1.1
**Priority**: Critical

**Description**: Implement streaming parser for transcript.txt files to extract session metadata and full content.

**Subtasks**:
- [ ] Create `src/log_parser.py` module
- [ ] Implement `parse_transcript(file_path)` function
- [ ] Extract session ID using regex: `Session ID: (session_\d{8}_\d{6})`
- [ ] Extract start time using regex: `Started: ([\d-T:.]+)`
- [ ] Read full transcript content (skip header section)
- [ ] Handle file encoding (UTF-8 with fallback to Latin-1)
- [ ] Implement error handling for missing or corrupted files
- [ ] Return structured dict: `{'session_id', 'start_time', 'content', 'file_path', 'file_mtime'}`
- [ ] Add logging for parsing warnings/errors

**Acceptance Criteria**:
- GIVEN valid transcript.txt file WHEN `parse_transcript()` is called THEN correct session_id and start_time are extracted
- GIVEN corrupted file WHEN parsing THEN function returns None and logs warning (does not crash)
- GIVEN 1000-line transcript WHEN parsing THEN memory usage stays under 50MB

**Technical Notes**:
- Use `with open()` for automatic file closing
- Use streaming line-by-line reading for large files
- Log warnings to stderr using Python logging module

---

### T1.4: Log Parser - Parse tool_calls.jsonl
**Complexity**: High
**Effort**: 4 hours
**Dependencies**: T1.1
**Priority**: Critical

**Description**: Implement JSONL parser for tool_calls.jsonl files to extract tool invocation records.

**Subtasks**:
- [ ] Add function `parse_tool_calls_jsonl(file_path)` to `src/log_parser.py`
- [ ] Read file line-by-line (streaming)
- [ ] Use `orjson.loads()` for fast JSON parsing
- [ ] Extract fields: ts, agent, tool, input, output, success, duration_ms
- [ ] Handle malformed JSON lines (skip with warning, continue parsing)
- [ ] Calculate session duration from first and last timestamp
- [ ] Compute aggregate stats: tool_call_count, unique_tools, unique_agents, has_errors
- [ ] Return list of tool call dicts + session metadata

**Acceptance Criteria**:
- GIVEN valid tool_calls.jsonl WHEN parsing THEN all tool call records are extracted
- GIVEN file with malformed line WHEN parsing THEN line is skipped and warning is logged
- WHEN parsing 10,000-line JSONL THEN processing completes in < 5 seconds

**Technical Notes**:
- Use `orjson` for 3x faster parsing vs stdlib json
- Validate required fields: ts, agent, tool, success
- Store input/output as JSON strings (don't parse deeply)

---

### T1.5: Log File Discovery and Indexing
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: T1.2, T1.3, T1.4
**Priority**: High

**Description**: Implement log file discovery from config.json and incremental indexing into SQLite database.

**Subtasks**:
- [ ] Create `src/config_loader.py` module
- [ ] Implement `load_config()` to read `.claude/config.json`
- [ ] Extract `paths.logs` field from config
- [ ] Resolve log directory path relative to project root
- [ ] Add function `discover_log_files(log_dir)` to find all session_*_transcript.txt files
- [ ] Implement `incremental_index(log_dir, db)` function
- [ ] Query existing sessions from database (session_id, file_mtime)
- [ ] Compare file mtimes to detect new/modified files
- [ ] Parse only new or modified sessions
- [ ] Batch insert to database (1000 records per transaction)
- [ ] Log indexing progress (e.g., "Indexed 342/500 sessions...")

**Acceptance Criteria**:
- GIVEN project with logs/ directory WHEN `load_config()` is called THEN correct log path is returned
- GIVEN 100 new log files WHEN `incremental_index()` runs THEN only new files are parsed
- WHEN indexing 1000 sessions THEN process completes in < 30 seconds

**Technical Notes**:
- Use `pathlib.Path` for cross-platform path handling
- Use `os.path.getmtime()` for file modification time
- Use `executemany()` for batch inserts

---

### T1.6: Build Inverted Index for Filters
**Complexity**: Medium
**Effort**: 2 hours
**Dependencies**: T1.5
**Priority**: High

**Description**: Build in-memory inverted index mapping tools/agents/skills to session IDs for fast filtering.

**Subtasks**:
- [ ] Create `src/search_engine.py` module
- [ ] Implement `build_inverted_index(db)` function
- [ ] Query database: `SELECT DISTINCT tool FROM tool_calls`
- [ ] Build dict: `{'tools': {tool_name: [session_ids]}, 'agents': {...}, 'skills': {...}}`
- [ ] Query all tool_calls grouped by tool and aggregate session_ids
- [ ] Implement skill detection heuristic (multi-agent-researcher, spec-workflow-orchestrator, none)
- [ ] Cache inverted index in memory (refresh on new indexing)

**Acceptance Criteria**:
- GIVEN database with 1000 sessions WHEN inverted index is built THEN index size < 10MB
- WHEN filtering by tool="WebSearch" THEN session IDs are returned in < 10ms
- WHEN combining filters (tool AND agent) THEN set intersection is correct

**Technical Notes**:
- Use Python sets for fast intersection/union operations
- Skill detection: check for specific agent patterns (researcher + report-writer, spec-analyst + spec-architect + spec-planner)

---

### T1.7: Implement SQLite FTS5 Full-Text Search
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: T1.5
**Priority**: High

**Description**: Implement keyword search using SQLite FTS5 with ranking and snippet generation.

**Subtasks**:
- [ ] Add function `search_transcripts(query, limit=50)` to `src/search_engine.py`
- [ ] Build SQL query: `SELECT session_id, snippet(transcripts_fts, 1, '<mark>', '</mark>', '...', 32) AS snippet, rank FROM transcripts_fts WHERE content MATCH ? ORDER BY rank LIMIT ?`
- [ ] Support FTS5 query syntax: `"exact phrase"`, `keyword1 OR keyword2`, `-excluded`
- [ ] Escape special characters in user queries
- [ ] Return list of results with session_id, snippet, relevance_score
- [ ] Join with sessions table to get full metadata

**Acceptance Criteria**:
- GIVEN query "MCP servers" WHEN searching THEN sessions containing phrase are returned
- WHEN query contains 2 keywords THEN results ranked by relevance (BM25)
- WHEN searching 10,000 sessions THEN response time < 500ms

**Technical Notes**:
- FTS5 uses BM25 ranking algorithm (built-in)
- Use `snippet()` function to generate highlighted excerpts
- Limit snippet length to 32 tokens for UI display

---

### T1.8: FastAPI Server - Basic Setup and Endpoints
**Complexity**: Medium
**Effort**: 4 hours
**Dependencies**: T1.2, T1.5, T1.6, T1.7
**Priority**: Critical

**Description**: Create FastAPI application with core API endpoints for sessions and search.

**Subtasks**:
- [ ] Create `server.py` as main entry point
- [ ] Initialize FastAPI app with CORS middleware (allow localhost:8080)
- [ ] Add startup event handler to initialize database and run incremental indexing
- [ ] Implement `GET /api/sessions` endpoint (paginated list)
- [ ] Implement `GET /api/sessions/{session_id}` endpoint (detail)
- [ ] Implement `GET /api/sessions/{session_id}/transcript` endpoint (full text)
- [ ] Implement `GET /api/sessions/{session_id}/tool-calls` endpoint (list)
- [ ] Implement `GET /api/search?q={query}` endpoint (keyword search)
- [ ] Implement `GET /api/filters/tools` endpoint (list unique tools with counts)
- [ ] Implement `GET /api/filters/agents` endpoint (list unique agents with counts)
- [ ] Implement `GET /api/status` health check endpoint
- [ ] Add error handling middleware (return JSON errors)
- [ ] Bind server to 127.0.0.1 (localhost only) on port 8080
- [ ] Add `if __name__ == '__main__'` block to run uvicorn

**Acceptance Criteria**:
- GIVEN server is running WHEN `GET /api/status` THEN response is `{"status": "healthy"}`
- WHEN `GET /api/sessions?page=1&limit=50` THEN paginated session list is returned
- WHEN `GET /api/search?q=MCP` THEN search results with snippets are returned
- WHEN accessing from external IP THEN connection is refused (localhost only)

**Technical Notes**:
- Use Pydantic models for request/response validation
- Use `@lru_cache` for caching filter dropdown data
- Log all requests with response time

---

### T1.9: Frontend - HTML Structure and Layout
**Complexity**: Low
**Effort**: 2 hours
**Dependencies**: T1.1
**Priority**: High

**Description**: Create base HTML structure with responsive layout for session list and detail views.

**Subtasks**:
- [ ] Create `static/index.html`
- [ ] Add semantic HTML5 structure: `<header>`, `<nav>`, `<main>`, `<aside>`, `<footer>`
- [ ] Define layout grid: left sidebar (filters), main content area, optional right sidebar
- [ ] Add meta tags: viewport, charset, description
- [ ] Link CSS and JS files
- [ ] Create placeholder divs for dynamic content: `#session-list`, `#session-detail`, `#filter-panel`, `#analytics-dashboard`
- [ ] Add loading spinner element

**Acceptance Criteria**:
- GIVEN index.html WHEN opened in browser THEN page layout renders correctly
- WHEN resizing browser window THEN layout is responsive (min-width: 1366px)
- WHEN inspecting HTML THEN semantic elements are used correctly

**Technical Notes**:
- Use CSS Grid for main layout
- Use Flexbox for component layouts
- Mobile-first CSS (though target is desktop)

---

### T1.10: Frontend - CSS Styling (Base Styles)
**Complexity**: Low
**Effort**: 3 hours
**Dependencies**: T1.9
**Priority**: Medium

**Description**: Implement global CSS styles, variables, typography, and layout patterns.

**Subtasks**:
- [ ] Create `static/css/main.css`
- [ ] Define CSS variables for colors, spacing, font sizes, shadows
- [ ] Set up typography (font-family: system fonts, font-size scale)
- [ ] Create utility classes: `.container`, `.card`, `.btn`, `.badge`, `.spinner`
- [ ] Style form elements: `input`, `select`, `button`, `textarea`
- [ ] Define color scheme: light mode (dark mode optional for Phase 4)
- [ ] Add responsive breakpoints using media queries
- [ ] Create loading spinner animation

**Acceptance Criteria**:
- GIVEN CSS file WHEN applied THEN consistent typography across all text
- WHEN using utility classes THEN components render with correct spacing and colors
- WHEN hovering over buttons THEN visual feedback is provided

**Technical Notes**:
- Use CSS custom properties (variables) for themeable design
- Use system font stack for fast rendering: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, ...`

---

### T1.11: Frontend - Session List Component
**Complexity**: Medium
**Effort**: 4 hours
**Dependencies**: T1.8, T1.9, T1.10
**Priority**: High

**Description**: Implement Web Component for displaying paginated session list with metadata.

**Subtasks**:
- [ ] Create `static/js/components/session-list.js`
- [ ] Define `<session-list>` custom element class extending HTMLElement
- [ ] Implement `render()` method to display sessions in table or card grid
- [ ] Add columns: Session ID, Date/Time, Duration, Tool Count, Tools (tags), Agents (tags)
- [ ] Implement pagination controls (Previous, Next, Page N of M)
- [ ] Add click event listener to navigate to session detail view
- [ ] Handle empty state (no sessions found)
- [ ] Handle loading state (show spinner)
- [ ] Implement hover tooltip showing first user message

**Acceptance Criteria**:
- GIVEN 100 sessions WHEN component renders THEN only 50 sessions per page are displayed
- WHEN clicking session row THEN `session-click` event is emitted with session_id
- WHEN hovering over session THEN tooltip shows first user message

**Technical Notes**:
- Use Shadow DOM for style encapsulation
- Use dataset attributes for storing session data
- Emit custom events for parent component communication

---

### T1.12: Frontend - Session Detail Component
**Complexity**: High
**Effort**: 5 hours
**Dependencies**: T1.8, T1.9, T1.10
**Priority**: High

**Description**: Implement session detail view with split-pane layout: transcript on left, tool calls timeline on right.

**Subtasks**:
- [ ] Create `static/js/components/session-detail.js`
- [ ] Define `<session-detail>` custom element
- [ ] Fetch session data from API: `/api/sessions/{id}`, `/api/sessions/{id}/transcript`, `/api/sessions/{id}/tool-calls`
- [ ] Implement split-pane layout (60/40 width ratio)
- [ ] Left pane: Display full transcript with timestamps
- [ ] Right pane: Display tool call timeline (vertical list)
- [ ] Add syntax highlighting for JSON (input/output)
- [ ] Implement collapsible tool call details (click to expand JSON)
- [ ] Add copy-to-clipboard buttons for transcript and JSON
- [ ] Color-code tool calls by success status (green=success, red=failure)
- [ ] Add back button to return to session list

**Acceptance Criteria**:
- GIVEN session_id WHEN detail view loads THEN full transcript and tool calls are displayed
- WHEN clicking tool call THEN input/output JSON is expanded
- WHEN clicking copy button THEN content is copied to clipboard

**Technical Notes**:
- Use `highlight.js` or simple regex for JSON syntax highlighting
- Use `navigator.clipboard.writeText()` for clipboard API
- Implement lazy loading of transcript (fetch on-demand)

---

### T1.13: Frontend - API Client Module
**Complexity**: Low
**Effort**: 2 hours
**Dependencies**: T1.8
**Priority**: High

**Description**: Create JavaScript API client wrapper for all backend endpoints with error handling.

**Subtasks**:
- [ ] Create `static/js/api.js` module
- [ ] Define base API URL: `const API_BASE = '/api'`
- [ ] Implement `fetchJSON(url, options)` helper with error handling
- [ ] Implement `getSessions(page, limit, filters)` function
- [ ] Implement `getSessionDetail(sessionId)` function
- [ ] Implement `getSessionTranscript(sessionId)` function
- [ ] Implement `getSessionToolCalls(sessionId)` function
- [ ] Implement `searchSessions(query)` function
- [ ] Implement `getFilterOptions(type)` function (tools, agents, skills)
- [ ] Add error logging to console
- [ ] Add retry logic for failed requests (3 attempts with exponential backoff)

**Acceptance Criteria**:
- GIVEN API endpoint WHEN `fetchJSON()` is called THEN response is parsed as JSON
- WHEN API returns 404 THEN error is logged and Promise rejects
- WHEN network fails THEN retry mechanism attempts 3 times before rejecting

**Technical Notes**:
- Use `fetch()` API (native browser support)
- Return Promises for async operations
- Add timeout handling (10 seconds)

---

### T1.14: Unit Tests - Log Parser
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: T1.3, T1.4
**Priority**: Medium

**Description**: Write unit tests for log parsing functions using pytest.

**Subtasks**:
- [ ] Create `tests/test_parser.py`
- [ ] Set up pytest configuration in `tests/conftest.py`
- [ ] Create fixtures: sample transcript.txt, sample tool_calls.jsonl
- [ ] Test `parse_transcript()` with valid file
- [ ] Test `parse_transcript()` with missing file (expect None)
- [ ] Test `parse_transcript()` with corrupted file (expect warning)
- [ ] Test `parse_tool_calls_jsonl()` with valid file
- [ ] Test `parse_tool_calls_jsonl()` with malformed JSON line (expect skip)
- [ ] Test session metadata calculation (duration, tool counts)
- [ ] Achieve 80%+ code coverage for log_parser.py

**Acceptance Criteria**:
- WHEN running `pytest tests/test_parser.py` THEN all tests pass
- GIVEN valid log files WHEN tests run THEN parsing logic is verified correct
- WHEN running with coverage THEN log_parser.py has >80% coverage

**Technical Notes**:
- Use pytest fixtures for test data
- Use `tmp_path` fixture for creating temporary test files
- Mock file I/O for error condition tests

---

### T1.15: Integration Tests - API Endpoints
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: T1.8
**Priority**: Medium

**Description**: Write integration tests for API endpoints using FastAPI TestClient.

**Subtasks**:
- [ ] Create `tests/test_api.py`
- [ ] Set up TestClient with FastAPI app
- [ ] Create test database fixture (in-memory SQLite)
- [ ] Seed test database with sample sessions
- [ ] Test `GET /api/sessions` (expect paginated list)
- [ ] Test `GET /api/sessions/{id}` (expect session detail)
- [ ] Test `GET /api/sessions/{id}` with invalid ID (expect 404)
- [ ] Test `GET /api/search?q=keyword` (expect search results)
- [ ] Test `GET /api/filters/tools` (expect list of tools)
- [ ] Test `GET /api/status` (expect healthy status)
- [ ] Verify response schemas match Pydantic models

**Acceptance Criteria**:
- WHEN running API tests THEN all endpoints return expected responses
- WHEN querying with pagination THEN correct number of results returned
- WHEN querying non-existent session THEN 404 error is returned

**Technical Notes**:
- Use `from fastapi.testclient import TestClient`
- Use in-memory SQLite database (`:memory:`) for isolation
- Reset database between tests

---

### T1.16: README and Setup Instructions
**Complexity**: Low
**Effort**: 2 hours
**Dependencies**: T1.1, T1.8
**Priority**: Medium

**Description**: Write comprehensive README with setup instructions, usage guide, and troubleshooting.

**Subtasks**:
- [ ] Document system requirements (Python 3.8+, modern browser)
- [ ] Write installation steps (clone repo, create venv, install dependencies)
- [ ] Document how to start server (`python server.py`)
- [ ] Add screenshots of main UI views (session list, detail view)
- [ ] Document configuration options (environment variables)
- [ ] Add troubleshooting section (common errors, solutions)
- [ ] Document project structure and architecture overview
- [ ] Add development setup instructions (running tests, linting)

**Acceptance Criteria**:
- GIVEN README WHEN following setup steps THEN user can start application without errors
- WHEN troubleshooting THEN common issues are documented with solutions

**Technical Notes**:
- Use Markdown format
- Add Table of Contents for easy navigation
- Include code blocks with syntax highlighting

---

## Phase 2: Filtering & Search

### T2.1: Implement Filter Query Logic
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: T1.6, T1.8
**Priority**: High

**Description**: Add API endpoint for filtering sessions by tools, agents, skills with AND logic.

**Subtasks**:
- [ ] Update `GET /api/sessions` endpoint to accept filter parameters: `tools[]`, `agents[]`, `skills[]`
- [ ] Implement filter logic using inverted index (set intersection)
- [ ] Combine filter results with pagination
- [ ] Support multiple filter values (e.g., `tools=WebSearch,Read` → sessions with WebSearch OR Read)
- [ ] Support combining filter types (e.g., `tools=WebSearch&agents=researcher` → sessions with WebSearch AND spawned researcher)
- [ ] Return filtered session count in response metadata

**Acceptance Criteria**:
- WHEN `GET /api/sessions?tools=WebSearch` THEN only sessions using WebSearch are returned
- WHEN `GET /api/sessions?tools=WebSearch&agents=researcher` THEN sessions matching both criteria are returned
- WHEN filtering 10,000 sessions THEN response time < 200ms

**Technical Notes**:
- Use set intersection: `sessions_with_websearch & sessions_with_researcher`
- Convert result session IDs to SQL: `WHERE session_id IN (...)`

---

### T2.2: Frontend - Filter Panel Component
**Complexity**: Medium
**Effort**: 4 hours
**Dependencies**: T2.1, T1.9, T1.10
**Priority**: High

**Description**: Implement filter panel sidebar with multi-select dropdowns for tools, agents, skills.

**Subtasks**:
- [ ] Create `static/js/components/filter-panel.js`
- [ ] Define `<filter-panel>` custom element
- [ ] Fetch filter options from API: `/api/filters/tools`, `/api/filters/agents`, `/api/filters/skills`
- [ ] Render multi-select checkboxes for each filter category
- [ ] Display usage counts next to each option (e.g., "WebSearch (234)")
- [ ] Implement search-within-filter (type to filter long lists)
- [ ] Add "Clear All Filters" button
- [ ] Emit `filter-change` event when filter selection changes
- [ ] Persist filter state in localStorage

**Acceptance Criteria**:
- GIVEN filter panel WHEN user selects "WebSearch" THEN `filter-change` event is emitted
- WHEN filter options are loaded THEN usage counts are displayed correctly
- WHEN "Clear All" is clicked THEN all filters are reset and event is emitted

**Technical Notes**:
- Use checkboxes for multi-select (better UX than multi-select dropdown)
- Use Flexbox for filter category layout
- Debounce filter-change events (300ms) to avoid excessive API calls

---

### T2.3: Frontend - Search Bar Component
**Complexity**: Low
**Effort**: 2 hours
**Dependencies**: T1.8, T1.9, T1.10
**Priority**: High

**Description**: Implement global search bar with debouncing and keyboard shortcuts.

**Subtasks**:
- [ ] Create `static/js/components/search-bar.js`
- [ ] Define `<search-bar>` custom element
- [ ] Add input field with placeholder "Search sessions..."
- [ ] Implement debounced input handler (300ms delay)
- [ ] Add keyboard shortcut: Cmd+K (Mac) or Ctrl+K (Windows/Linux) to focus search
- [ ] Add clear button (X icon) to reset search
- [ ] Emit `search-submit` event when user presses Enter or after debounce
- [ ] Persist last search query in localStorage

**Acceptance Criteria**:
- WHEN user types in search box THEN search is triggered after 300ms pause
- WHEN user presses Cmd+K THEN search bar gains focus
- WHEN clear button is clicked THEN search input is cleared and `search-clear` event is emitted

**Technical Notes**:
- Use `setTimeout()` and `clearTimeout()` for debouncing
- Use `keydown` event listener for keyboard shortcuts
- Check `event.metaKey` (Mac) or `event.ctrlKey` (Windows/Linux)

---

### T2.4: Frontend - State Management (EventBus)
**Complexity**: Low
**Effort**: 2 hours
**Dependencies**: T1.9
**Priority**: High

**Description**: Implement EventBus pattern for component communication and AppState singleton for global state.

**Subtasks**:
- [ ] Create `static/js/state.js` module
- [ ] Implement `EventBus` class with `on()`, `emit()`, `off()` methods
- [ ] Implement `AppState` singleton class
- [ ] Add state properties: `sessions`, `filters`, `currentSession`, `searchQuery`, `topics`
- [ ] Implement `loadFromStorage()` to restore state from localStorage
- [ ] Implement `saveToStorage()` to persist state
- [ ] Add state update methods that emit events: `setFilters()`, `setSearchQuery()`, `setCurrentSession()`
- [ ] Export global instances: `eventBus`, `appState`

**Acceptance Criteria**:
- GIVEN EventBus WHEN `emit('event', data)` is called THEN all listeners are notified
- WHEN `appState.setFilters(newFilters)` THEN state is updated and `filters-changed` event is emitted
- WHEN page is refreshed THEN state is restored from localStorage

**Technical Notes**:
- Use Map for event listeners (event name → array of callbacks)
- Use JSON.stringify/parse for localStorage serialization
- Implement debounced save to avoid excessive localStorage writes

---

### T2.5: Frontend - Router (Hash-Based Navigation)
**Complexity**: Low
**Effort**: 2 hours
**Dependencies**: T1.9
**Priority**: Medium

**Description**: Implement simple hash-based router for navigating between views (session list, detail, topics, analytics).

**Subtasks**:
- [ ] Create `static/js/router.js` module
- [ ] Implement `handleRoute()` function to parse `window.location.hash`
- [ ] Define routes: `#/` (session list), `#/session/{id}` (detail), `#/topics` (topic manager), `#/analytics` (dashboard)
- [ ] Add `hashchange` event listener to trigger route handling
- [ ] Implement `navigate(path)` helper to programmatically change routes
- [ ] Show/hide views based on current route
- [ ] Update browser title based on current route

**Acceptance Criteria**:
- WHEN URL is `#/session/session_20251117_224304` THEN session detail view is shown
- WHEN user clicks back button THEN previous view is restored
- WHEN navigating between routes THEN correct view is displayed

**Technical Notes**:
- Use `window.location.hash` for current route
- Use `document.title` for page title updates
- Add view transition animations (optional, Phase 4)

---

### T2.6: Frontend - Integration (Connect Components)
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: T2.1, T2.2, T2.3, T2.4, T2.5
**Priority**: High

**Description**: Wire up all frontend components with EventBus, connect to API client, implement data flow.

**Subtasks**:
- [ ] Update `static/js/app.js` to initialize all components
- [ ] Register custom elements: `customElements.define('session-list', SessionList)`
- [ ] Set up EventBus listeners for filter changes, search queries, navigation
- [ ] Connect filter panel to API: when filters change, fetch updated session list
- [ ] Connect search bar to API: when query changes, fetch search results
- [ ] Connect session list to router: when session clicked, navigate to detail view
- [ ] Implement loading states (show spinner during API calls)
- [ ] Implement error states (show error message on API failure)

**Acceptance Criteria**:
- WHEN user selects filter THEN session list updates automatically
- WHEN user searches THEN results are displayed with highlighted snippets
- WHEN API call fails THEN error message is displayed to user

**Technical Notes**:
- Use async/await for API calls
- Use try-catch for error handling
- Show loading spinner during fetch operations

---

### T2.7: Unit Tests - Search Engine
**Complexity**: Medium
**Effort**: 2 hours
**Dependencies**: T1.7, T2.1
**Priority**: Medium

**Description**: Write unit tests for search engine functions (FTS5 queries, filter logic).

**Subtasks**:
- [ ] Create `tests/test_search.py`
- [ ] Test `search_transcripts(query)` with various queries (keyword, phrase, boolean)
- [ ] Test `build_inverted_index()` with sample data
- [ ] Test filter logic (single filter, combined filters)
- [ ] Test ranking (verify BM25 scores are correct)
- [ ] Test edge cases (empty query, no results, special characters)

**Acceptance Criteria**:
- WHEN running search tests THEN FTS5 queries return correct results
- WHEN testing filter logic THEN set intersections are correct
- WHEN testing edge cases THEN no crashes occur

**Technical Notes**:
- Use in-memory SQLite for test database
- Seed database with known test data
- Verify result ordering (ranked by relevance)

---

## Phase 3: Analytics & Topics

### T3.1: Analytics Data Aggregation
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: T1.2, T1.5
**Priority**: High

**Description**: Implement SQL queries to aggregate statistics for analytics dashboard.

**Subtasks**:
- [ ] Add `src/analytics.py` module
- [ ] Implement `get_overview_stats()` function: total sessions, date range, total tool calls, unique tools/agents
- [ ] Implement `get_tool_usage_distribution()` function: tool name and count, sorted by frequency
- [ ] Implement `get_agent_usage_distribution()` function: agent name and count
- [ ] Implement `get_sessions_timeline()` function: sessions per day/week/month
- [ ] Implement `get_skill_activation_stats()` function: skill usage over time
- [ ] Optimize queries with indexes and aggregations
- [ ] Cache results for 5 minutes (use `@lru_cache` with TTL)

**Acceptance Criteria**:
- WHEN `get_overview_stats()` is called THEN correct totals are returned
- WHEN querying 10,000 sessions THEN aggregation completes in < 1 second
- WHEN data hasn't changed THEN cached results are returned instantly

**Technical Notes**:
- Use SQL `GROUP BY` and `COUNT()` for aggregations
- Use `DATE()` function for grouping by date
- Use `WITH` clause (CTE) for complex queries

---

### T3.2: API Endpoints - Analytics
**Complexity**: Low
**Effort**: 2 hours
**Dependencies**: T3.1, T1.8
**Priority**: High

**Description**: Add API endpoints for analytics dashboard data.

**Subtasks**:
- [ ] Implement `GET /api/analytics/overview` endpoint
- [ ] Implement `GET /api/analytics/tool-usage` endpoint
- [ ] Implement `GET /api/analytics/agent-usage` endpoint
- [ ] Implement `GET /api/analytics/timeline?period={day|week|month}` endpoint
- [ ] Add response caching (5 minute TTL)
- [ ] Add error handling

**Acceptance Criteria**:
- WHEN `GET /api/analytics/overview` THEN summary statistics are returned
- WHEN `GET /api/analytics/tool-usage` THEN tool distribution data is returned in format suitable for Chart.js
- WHEN endpoint is called multiple times THEN cached response is served (verify with timing logs)

**Technical Notes**:
- Return data in Chart.js-compatible format: `{ labels: [...], datasets: [...] }`
- Use FastAPI response caching or manual caching with TTL

---

### T3.3: Frontend - Analytics Dashboard Component
**Complexity**: High
**Effort**: 5 hours
**Dependencies**: T3.2, T1.9, T1.10
**Priority**: High

**Description**: Implement analytics dashboard with charts using Chart.js.

**Subtasks**:
- [ ] Download Chart.js library to `static/lib/chart.min.js`
- [ ] Create `static/js/components/analytics-dashboard.js`
- [ ] Define `<analytics-dashboard>` custom element
- [ ] Fetch analytics data from API endpoints
- [ ] Render overview statistics (total sessions, tool calls, date range) in cards
- [ ] Create bar chart for tool usage distribution
- [ ] Create pie chart for agent usage distribution
- [ ] Create line chart for sessions timeline
- [ ] Add date range selector for timeline (last 7 days, 30 days, all time)
- [ ] Add chart export button (download as PNG)

**Acceptance Criteria**:
- GIVEN analytics dashboard WHEN loaded THEN all charts render correctly
- WHEN hovering over chart THEN tooltip shows data values
- WHEN clicking export THEN chart is downloaded as PNG

**Technical Notes**:
- Use Chart.js (https://www.chartjs.org/)
- Use `<canvas>` elements for charts
- Use `chart.toBase64Image()` for export functionality

---

### T3.4: Topic Management - Backend Schema and API
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: T1.2, T1.8
**Priority**: High

**Description**: Implement topic management API endpoints for creating, updating, and tagging sessions.

**Subtasks**:
- [ ] Implement `GET /api/topics` endpoint (list all topics)
- [ ] Implement `POST /api/topics` endpoint (create new topic)
- [ ] Implement `PUT /api/topics/{id}` endpoint (update topic name/description)
- [ ] Implement `DELETE /api/topics/{id}` endpoint (delete topic)
- [ ] Implement `POST /api/topics/{topic_id}/sessions/{session_id}` endpoint (tag session)
- [ ] Implement `DELETE /api/topics/{topic_id}/sessions/{session_id}` endpoint (untag session)
- [ ] Implement `GET /api/topics/{id}/sessions` endpoint (list sessions in topic)
- [ ] Add validation: topic name must be unique, session must exist
- [ ] Use database transactions for consistency

**Acceptance Criteria**:
- WHEN `POST /api/topics` with name="MCP Research" THEN topic is created
- WHEN tagging session with topic THEN session_topics junction table is updated
- WHEN deleting topic THEN all associated session_topics entries are cascade deleted
- WHEN creating duplicate topic name THEN 400 error is returned

**Technical Notes**:
- Use Pydantic models for request validation
- Use SQLite foreign keys with CASCADE DELETE
- Return topic with session count in list endpoint

---

### T3.5: Topic Suggestion Algorithm (Keyword Similarity)
**Complexity**: High
**Effort**: 4 hours
**Dependencies**: T3.4
**Priority**: Medium

**Description**: Implement algorithm to suggest related sessions when tagging a topic based on keyword similarity.

**Subtasks**:
- [ ] Add function `suggest_related_sessions(session_id, limit=10)` to `src/search_engine.py`
- [ ] Extract keywords from session transcript (use simple TF-IDF or word frequency)
- [ ] Query FTS5 index for sessions with similar keywords
- [ ] Calculate similarity score (cosine similarity or simple keyword overlap)
- [ ] Return top N most similar sessions
- [ ] Implement `GET /api/topics/{topic_id}/suggest?session_id={id}` endpoint

**Acceptance Criteria**:
- GIVEN session about "MCP servers" WHEN suggesting related sessions THEN other MCP-related sessions are ranked high
- WHEN suggesting for new session THEN top 10 suggestions are returned in < 1 second

**Technical Notes**:
- Use simple keyword extraction: remove stopwords, count word frequency
- For Phase 1, use FTS5 MATCH query with extracted keywords
- For Phase 2+, consider using scikit-learn TfidfVectorizer

---

### T3.6: Frontend - Topic Manager Component
**Complexity**: High
**Effort**: 5 hours
**Dependencies**: T3.4, T3.5, T1.9, T1.10
**Priority**: High

**Description**: Implement topic management UI with creation, tagging, and suggestion features.

**Subtasks**:
- [ ] Create `static/js/components/topic-manager.js`
- [ ] Define `<topic-manager>` custom element
- [ ] Render topic list as cards (3-column grid)
- [ ] Add "Create New Topic" button with modal form
- [ ] Implement topic creation form (name, description)
- [ ] Implement session tagging interface (dropdown of topics, multi-select)
- [ ] Show suggested sessions when tagging (fetch from API)
- [ ] Implement topic detail view (list of tagged sessions)
- [ ] Add edit and delete buttons for topics
- [ ] Add confirmation dialog for topic deletion

**Acceptance Criteria**:
- WHEN user creates topic THEN it appears in topic list
- WHEN tagging session THEN suggested related sessions are displayed
- WHEN viewing topic detail THEN all tagged sessions are listed
- WHEN deleting topic THEN confirmation dialog is shown

**Technical Notes**:
- Use modal dialog for topic creation/edit forms
- Use drag-and-drop for tagging (optional, can use dropdown)
- Use color-coded topic tags for visual distinction

---

### T3.7: Export Functionality - CSV, Markdown, JSON
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: T1.8, T3.4
**Priority**: Medium

**Description**: Implement export endpoints for sessions and topics in multiple formats.

**Subtasks**:
- [ ] Create `src/export.py` module
- [ ] Implement `export_sessions_csv(sessions)` function
- [ ] Implement `export_session_markdown(session_id)` function
- [ ] Implement `export_topic_json(topic_id)` function
- [ ] Add `GET /api/export/sessions.csv?filters={...}` endpoint
- [ ] Add `GET /api/export/session/{id}.md` endpoint
- [ ] Add `GET /api/export/topic/{id}.json` endpoint
- [ ] Set correct Content-Type headers: `text/csv`, `text/markdown`, `application/json`
- [ ] Set Content-Disposition header for file download: `attachment; filename="..."`

**Acceptance Criteria**:
- WHEN `GET /api/export/sessions.csv` THEN CSV file is downloaded with correct columns
- WHEN `GET /api/export/session/{id}.md` THEN Markdown file with formatted transcript is downloaded
- WHEN opening exported CSV in Excel THEN data is properly formatted

**Technical Notes**:
- Use Python `csv` module for CSV generation
- Use f-strings for Markdown formatting
- Include session metadata in exports (date, tools, agents)

---

### T3.8: End-to-End Tests - User Workflows
**Complexity**: High
**Effort**: 4 hours
**Dependencies**: T2.6, T3.6
**Priority**: Medium

**Description**: Write end-to-end tests for critical user workflows using browser automation.

**Subtasks**:
- [ ] Set up Playwright or Selenium for browser automation
- [ ] Create `tests/test_e2e.py`
- [ ] Test workflow: Browse sessions → View session detail
- [ ] Test workflow: Search by keyword → View result
- [ ] Test workflow: Apply filter → View filtered results
- [ ] Test workflow: Create topic → Tag session → View topic detail
- [ ] Test workflow: Export session as Markdown → Verify file content
- [ ] Take screenshots on test failure for debugging

**Acceptance Criteria**:
- WHEN running E2E tests THEN all critical workflows complete successfully
- WHEN test fails THEN screenshot is saved for debugging
- WHEN running full test suite THEN all tests pass in < 5 minutes

**Technical Notes**:
- Use Playwright for fast, reliable browser automation
- Use headless mode for CI/CD integration
- Use test database seeded with known data

---

## Phase 4: Optimization & Polish

### T4.1: Implement Virtual Scrolling for Session List
**Complexity**: High
**Effort**: 4 hours
**Dependencies**: T1.11
**Priority**: Medium

**Description**: Replace simple pagination with virtual scrolling to handle 1000+ results smoothly.

**Subtasks**:
- [ ] Update `session-list` component to use virtual scrolling
- [ ] Calculate visible viewport (number of visible rows)
- [ ] Render only visible rows + 20 buffer rows (10 above, 10 below)
- [ ] Update scroll event listener to dynamically load rows as user scrolls
- [ ] Maintain scroll position when data updates
- [ ] Add "Load More" button at bottom for infinite scroll pattern

**Acceptance Criteria**:
- GIVEN 1000 search results WHEN scrolling THEN UI remains responsive (60fps)
- WHEN scrolling quickly THEN no blank rows are visible (proper buffering)
- WHEN data updates THEN scroll position is maintained

**Technical Notes**:
- Use `IntersectionObserver` API for detecting scroll position
- Use `transform: translateY()` for row positioning (better performance than absolute positioning)
- Measure row height dynamically (rows may vary slightly)

---

### T4.2: Optimize Incremental Indexing
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: T1.5
**Priority**: High

**Description**: Improve incremental indexing performance with parallelization and better caching.

**Subtasks**:
- [ ] Use `multiprocessing.Pool` to parse log files in parallel (4 workers)
- [ ] Batch database inserts (1000 records per transaction)
- [ ] Add progress indicator (e.g., "Indexing 342/500 sessions...")
- [ ] Cache parsed file mtimes in database to avoid filesystem checks
- [ ] Skip re-parsing files that haven't changed (compare mtime)
- [ ] Log indexing performance metrics (files/second, total time)

**Acceptance Criteria**:
- GIVEN 1000 new log files WHEN indexing THEN processing completes in < 20 seconds
- WHEN re-running indexing with no new files THEN completes in < 2 seconds (mtime check only)
- WHEN indexing THEN progress is displayed in console

**Technical Notes**:
- Use `multiprocessing.Pool.map()` for parallel processing
- Use `executemany()` for batch inserts
- Be careful with SQLite threading (use separate connections per worker)

---

### T4.3: Add Caching Layer (Server-Side)
**Complexity**: Medium
**Effort**: 2 hours
**Dependencies**: T1.8, T3.2
**Priority**: Medium

**Description**: Implement server-side caching for frequently accessed data (filter options, analytics).

**Subtasks**:
- [ ] Add `@lru_cache` decorator to filter dropdown functions
- [ ] Add TTL-based caching for analytics endpoints (5 minute expiry)
- [ ] Add cache invalidation when new logs are indexed
- [ ] Add cache statistics logging (hit rate, miss rate)
- [ ] Add `Cache-Control` headers to API responses

**Acceptance Criteria**:
- WHEN filter dropdown is requested multiple times THEN cached response is served (verify with logs)
- WHEN new logs are indexed THEN filter cache is invalidated
- WHEN analytics endpoint is called within 5 minutes THEN cached data is returned

**Technical Notes**:
- Use `functools.lru_cache` for in-memory caching
- Use time-based cache invalidation (store cache time, check age)
- Add `Cache-Control: max-age=300` header for client-side caching

---

### T4.4: Error Handling and User Feedback
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: T1.8, T2.6
**Priority**: High

**Description**: Improve error handling across backend and frontend with clear user feedback.

**Subtasks**:
- [ ] Add global error handler middleware to FastAPI app
- [ ] Return structured error responses: `{"error": "message", "details": "..."}`
- [ ] Add error logging to file: `web-viewer/logs/errors.log`
- [ ] Update API client to display user-friendly error messages
- [ ] Add toast notification component for transient messages
- [ ] Show error state in UI (red banner, error icon)
- [ ] Add retry button for failed API calls
- [ ] Log errors to browser console with stack traces

**Acceptance Criteria**:
- WHEN API returns error THEN user sees clear error message (not raw JSON)
- WHEN network fails THEN user sees "Network error, please retry" message
- WHEN error occurs THEN error is logged to server log file

**Technical Notes**:
- Use FastAPI exception handlers: `@app.exception_handler(Exception)`
- Use custom error classes for different error types (ValidationError, NotFoundError)
- Use toast library or build simple notification component

---

### T4.5: Performance Profiling and Optimization
**Complexity**: Medium
**Effort**: 3 hours
**Dependencies**: All previous tasks
**Priority**: Medium

**Description**: Profile application performance and optimize bottlenecks.

**Subtasks**:
- [ ] Add performance logging to API endpoints (request duration)
- [ ] Use `cProfile` to profile Python code (identify slow functions)
- [ ] Use browser DevTools to profile frontend rendering (identify reflows)
- [ ] Optimize slow SQL queries (add missing indexes)
- [ ] Reduce JavaScript bundle size (remove unused code)
- [ ] Optimize image assets (compress, use WebP)
- [ ] Add performance metrics to health check endpoint

**Acceptance Criteria**:
- WHEN profiling backend THEN no function takes >1 second for typical request
- WHEN profiling frontend THEN main thread is not blocked >100ms
- WHEN loading session list THEN First Contentful Paint < 1.5s

**Technical Notes**:
- Use `time.perf_counter()` for timing measurements
- Use SQLite `EXPLAIN QUERY PLAN` to verify index usage
- Use Chrome Lighthouse for frontend performance audit

---

### T4.6: Documentation - API Documentation
**Complexity**: Low
**Effort**: 2 hours
**Dependencies**: T1.8
**Priority**: Medium

**Description**: Generate and publish API documentation using FastAPI's built-in OpenAPI support.

**Subtasks**:
- [ ] Add docstrings to all API endpoint functions
- [ ] Add Pydantic model descriptions and examples
- [ ] Customize OpenAPI schema title and description
- [ ] Add API versioning to URL path: `/api/v1/...`
- [ ] Test auto-generated docs at `/docs` (Swagger UI)
- [ ] Add example requests and responses to docs

**Acceptance Criteria**:
- WHEN visiting `http://localhost:8080/docs` THEN API documentation is displayed
- WHEN viewing endpoint THEN request/response schemas are documented
- WHEN testing in Swagger UI THEN all endpoints are functional

**Technical Notes**:
- FastAPI generates OpenAPI docs automatically
- Use Pydantic `Field(description="...")` for field docs
- Use `@app.get(..., summary="...", description="...")` for endpoint docs

---

### T4.7: Security Hardening
**Complexity**: Medium
**Effort**: 2 hours
**Dependencies**: T1.8
**Priority**: High

**Description**: Implement security best practices for local web application.

**Subtasks**:
- [ ] Bind server to 127.0.0.1 only (not 0.0.0.0)
- [ ] Add CORS headers restricting origin to localhost:8080
- [ ] Implement input validation for all API parameters (use Pydantic)
- [ ] Sanitize search queries (escape SQL special characters)
- [ ] Implement HTML escaping in frontend (prevent XSS)
- [ ] Add rate limiting to search endpoint (10 requests/minute)
- [ ] Validate session_id format (match regex: `session_\d{8}_\d{6}`)
- [ ] Add Content Security Policy headers

**Acceptance Criteria**:
- WHEN accessing from external IP THEN connection is refused
- WHEN injecting SQL in search query THEN query is safely escaped
- WHEN rendering user content THEN HTML tags are escaped

**Technical Notes**:
- Use FastAPI `Query()` validator for parameter validation
- Use `html.escape()` for HTML sanitization
- Use parameterized SQL queries (SQLite protection)
- Use `slowapi` library for rate limiting

---

### T4.8: Accessibility Improvements
**Complexity**: Medium
**Effort**: 2 hours
**Dependencies**: T1.9, T1.10
**Priority**: Low

**Description**: Improve accessibility for keyboard navigation and screen readers.

**Subtasks**:
- [ ] Add ARIA labels to interactive elements
- [ ] Add focus styles for keyboard navigation
- [ ] Ensure proper heading hierarchy (h1 → h2 → h3)
- [ ] Add skip-to-content link
- [ ] Test with keyboard only (Tab navigation)
- [ ] Test with screen reader (VoiceOver on macOS)
- [ ] Ensure color contrast meets WCAG AA standards
- [ ] Add alt text to all images/icons

**Acceptance Criteria**:
- WHEN navigating with Tab key THEN all interactive elements are reachable
- WHEN using screen reader THEN all content is announced correctly
- WHEN checking color contrast THEN all text meets WCAG AA ratio (4.5:1 for normal text)

**Technical Notes**:
- Use semantic HTML (`<nav>`, `<main>`, `<button>`)
- Use `aria-label` for icon buttons
- Use `role` attribute where appropriate
- Test with Chrome DevTools Lighthouse accessibility audit

---

### T4.9: Deployment Script and Startup Automation
**Complexity**: Low
**Effort**: 2 hours
**Dependencies**: T1.8
**Priority**: Medium

**Description**: Create startup script that launches server and opens browser automatically.

**Subtasks**:
- [ ] Create `scripts/start.sh` (Unix/macOS)
- [ ] Create `scripts/start.bat` (Windows)
- [ ] Check if virtual environment exists, create if not
- [ ] Install dependencies if requirements.txt changed
- [ ] Start FastAPI server in background
- [ ] Wait for server to be ready (poll health check endpoint)
- [ ] Open browser to `http://localhost:8080`
- [ ] Add Ctrl+C handler to gracefully stop server

**Acceptance Criteria**:
- WHEN running `./scripts/start.sh` THEN server starts and browser opens automatically
- WHEN pressing Ctrl+C THEN server stops gracefully
- WHEN dependencies are missing THEN script installs them automatically

**Technical Notes**:
- Use `python -m webbrowser` to open browser
- Use `curl` or `wget` to poll health check endpoint
- Use `trap` (Unix) or `@echo off` (Windows) for signal handling

---

### T4.10: Final Testing and Bug Fixes
**Complexity**: High
**Effort**: 4 hours
**Dependencies**: All previous tasks
**Priority**: Critical

**Description**: Comprehensive testing of all features, fix identified bugs, ensure production readiness.

**Subtasks**:
- [ ] Run full test suite (unit, integration, E2E)
- [ ] Manual testing of all user workflows
- [ ] Test with 10,000+ session dataset
- [ ] Test on different browsers (Chrome, Firefox, Safari, Edge)
- [ ] Test on different OS (macOS, Linux, Windows)
- [ ] Fix any identified bugs
- [ ] Verify performance targets are met (< 3s load, < 2s search)
- [ ] Update README with any new findings or requirements

**Acceptance Criteria**:
- WHEN running all tests THEN 100% pass rate
- WHEN testing with 10,000 sessions THEN all performance targets are met
- WHEN testing on all browsers THEN UI renders correctly and functionality works
- WHEN following README setup THEN application starts without errors

**Technical Notes**:
- Use automated testing where possible
- Document any known issues or limitations
- Prioritize critical bugs (crashes, data loss) over cosmetic issues

---

## Risk Assessment

### Technical Risks

| Risk ID | Risk Description | Severity | Probability | Impact | Mitigation Strategy |
|---------|-----------------|----------|-------------|--------|---------------------|
| **R1** | SQLite FTS5 performance degrades with 10,000+ sessions | High | Medium | Search becomes slow (>5s) | Early load testing, consider trigram tokenizer or external search engine (Elasticsearch) for >50K sessions |
| **R2** | Browser memory limits exceeded with large datasets | High | Medium | UI crashes or becomes unresponsive | Implement virtual scrolling, lazy loading, profile memory usage early |
| **R3** | Log parsing errors with malformed files | Medium | Medium | Indexing fails, some sessions missing | Robust error handling, skip corrupted files, log warnings |
| **R4** | CORS issues with file:// protocol | Medium | High | Static deployment doesn't work | Document local HTTP server requirement, provide startup scripts |
| **R5** | Topic suggestion algorithm produces poor results | Medium | Medium | Users don't find it useful | Start with simple keyword overlap, gather feedback, iterate in Phase 2+ |
| **R6** | Incremental indexing misses updated files | Low | Low | Stale data in UI | Verify mtime comparison logic, add manual re-index button |
| **R7** | Web Components browser compatibility | Low | Low | UI doesn't work on older browsers | Test on target browsers early, use polyfills if needed |
| **R8** | Python version incompatibility | Low | Medium | Application doesn't run | Clearly document Python 3.8+ requirement, test on multiple versions |

### Process Risks

| Risk ID | Risk Description | Severity | Probability | Mitigation Strategy |
|---------|-----------------|----------|-------------|---------------------|
| **P1** | Scope creep (adding features not in MVP) | Medium | High | Strict adherence to phase plan, defer enhancements to Phase 2+ |
| **P2** | Underestimated task complexity | Medium | Medium | Add 20% buffer to estimates, track actual time spent |
| **P3** | Testing bottleneck (E2E tests slow development) | Low | Medium | Run E2E tests nightly, prioritize unit/integration tests for fast feedback |
| **P4** | Documentation falls behind implementation | Low | High | Update docs incrementally, allocate dedicated time for documentation |

---

## Testing Strategy

### Unit Test Coverage Targets

| Component | Target Coverage | Test Focus |
|-----------|----------------|------------|
| **Log Parser** | 80%+ | Valid files, corrupted files, edge cases (empty, malformed JSON) |
| **Search Engine** | 80%+ | FTS5 queries, filter logic, inverted index, ranking |
| **Database Module** | 70%+ | CRUD operations, transactions, schema migrations |
| **Export Functions** | 70%+ | CSV/Markdown/JSON formatting, special characters |

### Integration Test Scenarios

| Scenario | Description | Expected Outcome |
|----------|-------------|------------------|
| **API Session List** | GET /api/sessions with pagination | Returns correct page of results |
| **API Session Detail** | GET /api/sessions/{id} | Returns full session metadata |
| **API Keyword Search** | GET /api/search?q=MCP | Returns ranked search results with snippets |
| **API Filter Combination** | GET /api/sessions?tools=WebSearch&agents=researcher | Returns sessions matching both filters |
| **API Topic Management** | POST /api/topics, tag sessions, GET /api/topics/{id}/sessions | Topic CRUD operations work correctly |
| **Database Indexing** | Index 1000 sample log files | All sessions inserted, FTS index populated |

### End-to-End Test Requirements

| User Workflow | Test Steps | Success Criteria |
|---------------|------------|------------------|
| **Browse and View** | 1. Open app<br>2. Click session<br>3. View transcript | Session detail loads with full transcript |
| **Search** | 1. Enter keyword "MCP"<br>2. View results<br>3. Click result | Search returns relevant sessions, detail view opens |
| **Filter** | 1. Select tool filter "WebSearch"<br>2. View filtered list<br>3. Verify all sessions use WebSearch | Only filtered sessions shown |
| **Create Topic** | 1. Click "New Topic"<br>2. Enter name<br>3. Tag sessions<br>4. View topic detail | Topic created, sessions tagged, topic list updates |
| **Export** | 1. Filter sessions<br>2. Click export CSV<br>3. Open file | CSV downloads with correct data |

### Performance Benchmarks

| Benchmark | Target | Measurement Method |
|-----------|--------|-------------------|
| **Initial Load** | < 3s | Chrome DevTools Performance tab, measure to First Contentful Paint |
| **Keyword Search** | < 2s | Measure API response time for search endpoint with 1000 sessions |
| **Filter Application** | < 500ms | Measure API response time for filtered session list |
| **Session Detail Load** | < 1s | Measure time from click to full transcript render |
| **Indexing Performance** | < 30s for 1000 sessions | Log indexing duration, verify with test dataset |
| **Memory Usage** | < 500MB | Chrome DevTools Memory profiler with 1000 sessions loaded |

---

## Dependency Matrix

| Task ID | Task Name | Depends On | Blocks | Can Parallelize With |
|---------|-----------|------------|--------|---------------------|
| T1.1 | Project Setup | None | All | None |
| T1.2 | Database Schema | T1.1 | T1.5, T3.4 | T1.3, T1.4, T1.9 |
| T1.3 | Parse transcript.txt | T1.1 | T1.5 | T1.2, T1.4, T1.9 |
| T1.4 | Parse tool_calls.jsonl | T1.1 | T1.5 | T1.2, T1.3, T1.9 |
| T1.5 | Log Discovery & Indexing | T1.2, T1.3, T1.4 | T1.6, T1.7, T1.8 | None |
| T1.6 | Inverted Index | T1.5 | T1.8, T2.1 | T1.7, T1.9 |
| T1.7 | FTS5 Search | T1.5 | T1.8, T2.1 | T1.6, T1.9 |
| T1.8 | FastAPI Server | T1.2, T1.5, T1.6, T1.7 | T1.11, T1.13, T2.1 | T1.9, T1.10 |
| T1.9 | HTML Structure | T1.1 | T1.10, T1.11, T1.12 | T1.2-T1.8 |
| T1.10 | CSS Styling | T1.9 | T1.11, T1.12, T2.2 | T1.8 |
| T1.11 | Session List Component | T1.8, T1.9, T1.10 | T2.6 | T1.12, T1.13 |
| T1.12 | Session Detail Component | T1.8, T1.9, T1.10 | T2.6 | T1.11, T1.13 |
| T1.13 | API Client | T1.8 | T1.11, T1.12, T2.6 | T1.9, T1.10 |
| T1.14 | Unit Tests (Parser) | T1.3, T1.4 | None | T1.15 |
| T1.15 | Integration Tests (API) | T1.8 | None | T1.14 |
| T2.1 | Filter Query Logic | T1.6, T1.8 | T2.2, T2.6 | T2.3 |
| T2.2 | Filter Panel Component | T2.1, T1.9, T1.10 | T2.6 | T2.3, T2.4 |
| T2.3 | Search Bar Component | T1.8, T1.9, T1.10 | T2.6 | T2.1, T2.2, T2.4 |
| T2.4 | State Management | T1.9 | T2.6 | T2.1, T2.2, T2.3 |
| T2.5 | Router | T1.9 | T2.6 | T2.1-T2.4 |
| T2.6 | Frontend Integration | T2.1-T2.5 | T3.8 | None |
| T3.1 | Analytics Aggregation | T1.2, T1.5 | T3.2, T3.3 | T3.4 |
| T3.2 | Analytics API | T3.1, T1.8 | T3.3 | T3.4 |
| T3.3 | Analytics Dashboard | T3.2, T1.9, T1.10 | T3.8 | T3.6 |
| T3.4 | Topic API | T1.2, T1.8 | T3.5, T3.6 | T3.1, T3.2 |
| T3.5 | Topic Suggestion | T3.4 | T3.6 | T3.7 |
| T3.6 | Topic Manager Component | T3.4, T3.5, T1.9, T1.10 | T3.8 | T3.3, T3.7 |
| T3.7 | Export Functionality | T1.8, T3.4 | None | T3.1-T3.6 |
| T3.8 | E2E Tests | T2.6, T3.6 | None | None |
| T4.1 | Virtual Scrolling | T1.11 | None | T4.2-T4.9 |
| T4.2 | Optimize Indexing | T1.5 | None | T4.1, T4.3-T4.9 |
| T4.3 | Caching Layer | T1.8, T3.2 | None | T4.1, T4.2, T4.4-T4.9 |
| T4.4 | Error Handling | T1.8, T2.6 | None | T4.1-T4.3, T4.5-T4.9 |
| T4.5 | Performance Profiling | All previous | None | T4.6-T4.8 |
| T4.6 | API Documentation | T1.8 | None | T4.1-T4.5, T4.7-T4.9 |
| T4.7 | Security Hardening | T1.8 | None | T4.1-T4.6, T4.8, T4.9 |
| T4.8 | Accessibility | T1.9, T1.10 | None | T4.1-T4.7, T4.9 |
| T4.9 | Deployment Script | T1.8 | None | T4.1-T4.8 |
| T4.10 | Final Testing | All previous | None | None |

---

## Critical Path Timeline

The critical path represents the longest sequence of dependent tasks that determine the minimum project duration:

```
T1.1 (2h) → T1.2 (3h) → T1.3 (4h) → T1.5 (3h) → T1.6 (2h) → T1.8 (4h) → T2.1 (3h) → T2.6 (3h) → T3.1 (3h) → T3.2 (2h) → T3.3 (5h) → T4.10 (4h)

Total Critical Path: 38 hours (approximately 5 person-days)
```

However, with parallelization across backend, frontend, and testing streams, the actual calendar time can be reduced significantly:

**Optimized Timeline with 3 Parallel Streams**:
- Week 1 (Phase 1 MVP): Backend stream (T1.1-T1.8), Frontend stream (T1.9-T1.13), Testing stream (T1.14-T1.15)
- Week 2 (Phase 1 completion): Frontend integration (T1.16, T2.6)
- Week 3 (Phase 2): Backend (T2.1, T2.7), Frontend (T2.2-T2.5)
- Week 4 (Phase 3): Backend (T3.1, T3.2, T3.4, T3.5), Frontend (T3.3, T3.6, T3.7), Testing (T3.8)
- Week 5 (Phase 4): Optimization and polish (T4.1-T4.10 in parallel)

---

## Success Criteria

### Phase Completion Criteria

**Phase 1 MVP Complete When**:
- [ ] User can browse all sessions in web UI
- [ ] User can view full session transcript and tool calls
- [ ] User can search by keyword in < 2 seconds
- [ ] Application handles 1,000 sessions gracefully
- [ ] All unit and integration tests pass

**Phase 2 Filtering Complete When**:
- [ ] User can filter by tool, agent, skill
- [ ] Filters apply in < 500ms
- [ ] User can combine multiple filters
- [ ] Filter state persists in localStorage

**Phase 3 Analytics Complete When**:
- [ ] Analytics dashboard displays key statistics
- [ ] User can create and manage topics
- [ ] Topic suggestions are relevant (>70% accuracy)
- [ ] User can export sessions to CSV/Markdown/JSON

**Phase 4 Optimization Complete When**:
- [ ] Application handles 10,000+ sessions gracefully
- [ ] Memory usage < 500MB
- [ ] Initial load < 3 seconds
- [ ] All E2E tests pass
- [ ] Documentation is complete

---

## Document Metadata

**Version**: 1.0
**Date**: 2025-11-19
**Author**: spec-planner (Claude)
**Status**: Implementation Ready

**Total Estimated Effort**: 22-25 person-days (176-200 hours)
**Recommended Team Size**: 1-2 developers
**Recommended Timeline**: 5 weeks (with 3 parallel streams)

---

**End of Implementation Tasks Document**

*This document serves as the detailed task breakdown for implementing the Session Log Viewer. All tasks are atomic (1-8 hours), have clear acceptance criteria, and are organized to enable parallel development streams for maximum efficiency.*
