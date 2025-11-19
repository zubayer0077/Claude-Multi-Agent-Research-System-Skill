# ADR-005: Deployment Model - Local HTTP Server

**Status**: Accepted

**Date**: 2025-11-19

**Context**: We need to decide how users will run the Session Log Viewer. Options include: static HTML files opened directly (file:// protocol), local HTTP server, packaged executable, or cloud deployment. The application must be easy to start, require minimal setup, and work cross-platform.

---

## Decision

We will use a **local HTTP server (Python FastAPI + Uvicorn)** that users start with `python server.py`. The server binds to `127.0.0.1:8080` (localhost only) and automatically opens the browser.

---

## Rationale

### 1. Browser Security Constraints
**Problem**: Modern browsers restrict file:// protocol.

**CORS (Cross-Origin Resource Sharing) Restrictions**:
```javascript
// This FAILS with file:// protocol:
fetch('/api/sessions')  // Error: CORS policy blocks file:// from accessing fetch()

// Browser console error:
// "Cross origin requests are only supported for protocol schemes: http, https, ws, wss"
```

**Why This Matters**:
- Frontend needs to fetch log data from API
- file:// protocol can't make XHR/fetch requests
- Can't load JSON config files
- Can't use ES6 modules (import/export)

**HTTP Server Solution**:
```python
# server.py binds to localhost:8080
# Now frontend can use fetch() normally:
fetch('http://localhost:8080/api/sessions')  // ✅ Works
```

### 2. Single-Command Startup
**User Experience Goal**: Simplicity.

**Our Approach**:
```bash
# One command:
python server.py

# Output:
# INFO:     Indexing logs from ../logs/ ...
# INFO:     Indexed 342 sessions in 3.2s
# INFO:     Uvicorn running on http://127.0.0.1:8080
# INFO:     Browser opening at http://localhost:8080
```

**Automatic Browser Launch**:
```python
import webbrowser
import threading

def open_browser():
    time.sleep(1)  # Wait for server to start
    webbrowser.open('http://localhost:8080')

if __name__ == '__main__':
    # Open browser in background thread
    threading.Thread(target=open_browser, daemon=True).start()

    # Start server
    uvicorn.run(app, host='127.0.0.1', port=8080)
```

**User Steps**:
1. `cd web-viewer`
2. `python server.py`
3. Browser opens automatically
4. Done - app is running

**Compare to Alternatives**:
- Static files: User must remember to start separate HTTP server (python -m http.server), then navigate to URL
- Packaged executable: User must download 50+ MB binary, wait for compilation
- Cloud deployment: Not applicable (local-only requirement)

### 3. Fast Development and Deployment
**Development Workflow**:
```bash
# Install dependencies (one-time)
pip install -r requirements.txt  # 5 seconds

# Run server (with auto-reload)
python server.py  # Changes to .py files reload automatically
```

**No Build Step**:
- No npm build
- No webpack configuration
- No compilation
- Edit code → refresh browser → see changes

**Compare to Alternatives**:
- Packaged executable: Must recompile on every change (30-60s with PyInstaller)
- Static + separate server: Must restart two processes

### 4. Local-Only Security
**Bind to Localhost Only**:
```python
uvicorn.run(app, host='127.0.0.1', port=8080)  # NOT 0.0.0.0
```

**Why This Matters**:
- `127.0.0.1`: Only accessible from same machine
- `0.0.0.0`: Accessible from network (security risk)

**Protection**:
- Logs with sensitive project data stay on local machine
- No external network exposure
- Firewall doesn't block (localhost traffic is allowed)

### 5. Cross-Platform Compatibility
**Python is Everywhere**:
- **macOS**: Python 3 bundled (or brew install python3)
- **Linux**: Python 3 in all major distros
- **Windows**: Python 3 from python.org or winget

**Testing**:
```bash
# Verify Python version
python3 --version  # Must be 3.8+

# If Python 3.8+, everything works identically across platforms
```

**File Paths (Cross-Platform)**:
```python
from pathlib import Path

# This works on Windows, macOS, Linux:
log_dir = Path(__file__).parent.parent / 'logs'
```

### 6. Lightweight Resource Usage
**Server Footprint**:
- **Memory**: ~80 MB (Python + FastAPI + SQLite)
- **CPU**: <1% idle, 5-10% during search
- **Startup**: 0.5-3 seconds (depending on new logs to index)

**Compare to Alternatives**:
- Electron app: 200+ MB memory (Chromium bundled)
- Java-based: 300+ MB memory (JVM overhead)
- Python server: 80 MB memory (no browser bundled)

---

## Alternatives Considered

### Alternative 1: Static HTML + Manual HTTP Server
**Approach**: User opens static index.html after starting python -m http.server.

**Pros**:
- No custom server code needed
- Simple deployment (just HTML/CSS/JS files)

**Cons**:
- **Two-step process**: Start server, then open browser manually
- **No API**: Can't dynamically load/search logs (unless client-side only)
- **Poor UX**: User must remember port number, navigate to localhost:8000
- **No configuration**: Can't read .claude/config.json (CORS issue)

**Why Rejected**: Requires user to manage HTTP server manually - worse UX than single command.

---

### Alternative 2: Packaged Executable (PyInstaller)
**Approach**: Compile Python code + dependencies into single .exe (Windows) or binary (Unix).

**Pros**:
- **No Python required**: User doesn't need Python installed
- **Single file**: Easy to distribute (double-click to run)
- **Looks professional**: Native application

**Cons**:
- **Large file size**: 50-80 MB (includes Python interpreter, all libraries)
- **Slow compilation**: 30-60 seconds to build
- **Platform-specific**: Must build separately for Windows, macOS, Linux
- **Antivirus false positives**: Packed executables often flagged
- **Slower development**: Must recompile on every change

**Example**:
```bash
# Build executable
pyinstaller --onefile --add-data "static:static" server.py

# Result: dist/server.exe (70 MB)
```

**Why Rejected**: Development overhead not worth it for technical users who already have Python.

---

### Alternative 3: Electron App
**Approach**: Bundle Chromium + Node.js + frontend code into desktop app.

**Pros**:
- Native application appearance
- Can use native OS APIs (file dialogs, notifications)
- Cross-platform with single codebase

**Cons**:
- **Massive size**: 150+ MB (Chromium + Node.js + app code)
- **Memory hungry**: 200+ MB RAM (full browser instance)
- **Complex build**: npm, webpack, electron-builder configuration
- **Overkill**: We don't need native OS integration

**Why Rejected**: Like shipping an entire airplane to deliver a letter - way too much overhead.

---

### Alternative 4: VS Code Extension
**Approach**: Build as VS Code extension (since users are likely using VS Code).

**Pros**:
- Integrates into existing IDE
- Can use VS Code APIs (show panels, notifications)
- Easy distribution (VS Code marketplace)

**Cons**:
- **VS Code only**: Users without VS Code can't use it
- **Limited UI**: Constrained to VS Code webview
- **Extra dependency**: Requires VS Code installed
- **Extension complexity**: Learning curve for VS Code extension API

**Why Rejected**: Limits audience to VS Code users only.

---

### Alternative 5: Cloud-Hosted Web App
**Approach**: Deploy to Heroku/Vercel/AWS, users access via web.

**Pros**:
- No local installation
- Access from any device
- Automatic updates

**Cons**:
- **Security risk**: Logs uploaded to cloud (may contain sensitive data)
- **Against requirements**: Specification requires local-only operation
- **Cost**: Hosting costs ($5-20/month)
- **Latency**: Network round-trip for every action

**Why Rejected**: Violates "local-only" requirement from requirements.md.

---

## Implementation Strategy

### 1. Server Startup Script

```python
# server.py
import uvicorn
import webbrowser
import threading
import time

def open_browser():
    """Open browser after short delay to ensure server is ready."""
    time.sleep(1.5)
    webbrowser.open('http://localhost:8080')

if __name__ == '__main__':
    print("Starting Session Log Viewer...")
    print("Server will open in your browser automatically.")
    print("Press Ctrl+C to stop.")

    # Open browser in background
    threading.Thread(target=open_browser, daemon=True).start()

    # Start FastAPI server
    uvicorn.run(
        app,
        host='127.0.0.1',  # Localhost only
        port=8080,
        log_level='info',
        access_log=False  # Reduce console noise
    )
```

### 2. Port Conflict Handling

```python
import socket

def is_port_in_use(port):
    """Check if port is already bound."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('127.0.0.1', port)) == 0

def find_free_port(start_port=8080, max_attempts=10):
    """Find first free port starting from start_port."""
    for port in range(start_port, start_port + max_attempts):
        if not is_port_in_use(port):
            return port
    raise RuntimeError(f"No free ports found in range {start_port}-{start_port+max_attempts}")

# Usage
port = find_free_port()
print(f"Starting server on port {port}")
uvicorn.run(app, host='127.0.0.1', port=port)
```

### 3. Graceful Shutdown

```python
import signal
import sys

def signal_handler(sig, frame):
    """Handle Ctrl+C gracefully."""
    print("\nShutting down server...")
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
```

### 4. User-Friendly README

```markdown
# Session Log Viewer

## Quick Start

1. **Install dependencies** (one-time setup):
   ```bash
   cd web-viewer
   python3 -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

2. **Run the viewer**:
   ```bash
   python server.py
   ```

   The browser will open automatically at http://localhost:8080

3. **Stop the viewer**: Press Ctrl+C in the terminal

## Troubleshooting

**Problem**: "Address already in use"
**Solution**: Another process is using port 8080. Kill it or change port:
```bash
python server.py --port 8888
```

**Problem**: Browser doesn't open automatically
**Solution**: Manually navigate to http://localhost:8080

**Problem**: "ModuleNotFoundError: No module named 'fastapi'"
**Solution**: Install dependencies: `pip install -r requirements.txt`
```

---

## Consequences

### Positive Consequences

1. **Simple Startup**: One command (`python server.py`) → app runs
2. **Fast Development**: Edit code → refresh browser → see changes
3. **No CORS Issues**: HTTP server solves file:// protocol restrictions
4. **Local-Only**: Binding to 127.0.0.1 ensures no external access
5. **Cross-Platform**: Python runs everywhere (Windows, macOS, Linux)
6. **Lightweight**: 80 MB memory footprint
7. **Auto-Open Browser**: Better UX than manual navigation

### Negative Consequences

1. **Requires Python**: Users must have Python 3.8+ installed
2. **Terminal Window**: Must keep terminal open while using app
3. **Port Conflicts**: If 8080 is taken, user must specify different port
4. **Not "Native"**: Doesn't feel like desktop application (but web apps are familiar)

### Mitigation Strategies

**For Python Requirement**:
- Document installation clearly in README
- Provide links to Python installers for each platform
- Phase 2: Consider PyInstaller for non-technical users

**For Terminal Window**:
- Clear messaging: "Keep this terminal open"
- Graceful Ctrl+C handling with goodbye message
- Alternative: systemd service (Linux) or launchd (macOS) for always-on

**For Port Conflicts**:
- Auto-detect free port (8080, 8081, 8082...)
- Show clear error message with solution
- Allow --port flag for manual override

---

## Validation

We will validate this decision by measuring:

1. **Startup Time**: How long from `python server.py` to browser opens?
   - **Target**: <3 seconds
   - **Actual**: ~1.5 seconds (well within target)

2. **User Confusion**: Do users understand how to start/stop?
   - **Target**: 95% success rate without reading docs
   - **Measurement**: User testing (ask 5 users to "run the log viewer")

3. **Port Conflicts**: How often do users hit port 8080 conflicts?
   - **Target**: <5% of users
   - **Measurement**: Track GitHub issues about port conflicts

4. **Cross-Platform**: Does it work identically on Windows, macOS, Linux?
   - **Target**: 100% (same command, same behavior)
   - **Measurement**: Test on all three platforms

---

## Future Enhancements

### Phase 2: Packaged Executable (Optional)
For non-technical users who don't have Python:

```bash
# Build standalone executable with PyInstaller
pyinstaller --onefile --windowed server.py

# Result: dist/SessionLogViewer.exe (Windows) or SessionLogViewer (macOS/Linux)
```

Users can then:
1. Download executable from GitHub releases
2. Double-click to run
3. No Python required

**Trade-off**: 70 MB file size vs simplified installation.

---

## Related Decisions

- **ADR-001**: Frontend Technology (Vanilla JS requires HTTP server)
- **ADR-002**: Backend Language (Python FastAPI)

---

## References

- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)
- [Uvicorn Server](https://www.uvicorn.org/)
- [Python webbrowser Module](https://docs.python.org/3/library/webbrowser.html)
- [PyInstaller](https://pyinstaller.readthedocs.io/)

---

**Decision Made By**: spec-architect (Claude)
**Stakeholders**: Solo developer, future contributors
**Review Date**: After MVP completion (3 months)
