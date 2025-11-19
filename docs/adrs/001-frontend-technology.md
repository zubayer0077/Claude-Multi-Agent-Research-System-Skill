# ADR-001: Frontend Technology Choice - Vanilla JavaScript

**Status**: Accepted

**Date**: 2025-11-19

**Context**: We need to choose a frontend technology for the Session Log Viewer web interface. The application needs to render session lists, display detailed log views, and provide interactive filtering/search capabilities.

---

## Decision

We will use **Vanilla JavaScript (ES6+) with Web Components** instead of a modern framework like React, Vue, or Svelte.

---

## Rationale

### 1. Zero Build Complexity
**Benefit**: Users can open `index.html` directly after starting the Python server - no npm install, no build step, no configuration.

**Why This Matters**:
- Target users are developers who want quick log access, not web development setup
- Reduces friction: `python server.py` → browser opens → app works
- No dependency hell: no package.json with 300+ transitive dependencies
- No broken builds due to framework version conflicts

### 2. Smaller Payload
**Measurement**:
- Vanilla JS + Web Components: ~50KB
- React 18 + ReactDOM: ~130KB (minified + gzipped)
- Vue 3: ~100KB
- Svelte: ~5KB (but requires build step)

**Why This Matters**:
- Local application, but still benefits from fast load times
- Smaller payload means faster parsing/execution in browser
- Better performance on lower-end machines

### 3. Direct Control Over Rendering
**Challenge**: Need to render large lists (1000+ sessions) efficiently.

**Solution with Vanilla JS**:
```javascript
// Virtual scrolling implementation
class VirtualList {
  constructor(container, items, rowHeight) {
    this.visibleStart = 0;
    this.visibleEnd = Math.ceil(container.clientHeight / rowHeight);
  }

  render() {
    // Only render visible items + buffer
    const visible = this.items.slice(this.visibleStart, this.visibleEnd);
    // Direct DOM manipulation - no virtual DOM overhead
  }
}
```

**Why Frameworks Make This Harder**:
- React: Need `react-window` or `react-virtualized` libraries
- Vue: Need additional virtualization library
- Extra dependencies, extra learning curve

### 4. Future-Proof
**Risk with Frameworks**:
- React: Breaking changes between versions (class → hooks, suspense API changes)
- Vue: Major breaking changes Vue 2 → Vue 3
- Framework churn: What's popular today may be deprecated tomorrow

**Vanilla JS**:
- Web standards don't break
- Code written in 2025 will work in 2035
- No migration costs

### 5. Learning Curve for Contributors
**With Framework**:
- Need to know: React concepts (hooks, context, lifecycle), JSX syntax, tooling (webpack/vite)
- Barrier for contributors unfamiliar with chosen framework

**With Vanilla JS**:
- Just JavaScript + DOM APIs
- Any JavaScript developer can contribute
- Easier onboarding for future collaborators

---

## Alternatives Considered

### Alternative 1: React + TypeScript
**Pros**:
- Large ecosystem of components
- Team might already know React
- Great developer tooling (React DevTools)

**Cons**:
- Requires build step (Vite/webpack)
- 130KB+ bundle size
- npm install takes time and disk space
- Adds complexity for simple UI needs
- TypeScript compilation adds build time

**Why Rejected**: Overkill for a local-only log viewer with straightforward UI patterns.

---

### Alternative 2: Vue 3
**Pros**:
- Simpler than React
- Good documentation
- Built-in reactivity

**Cons**:
- Still requires build step
- 100KB bundle size
- Adds framework lock-in
- Template syntax is another learning curve

**Why Rejected**: Doesn't provide enough value over vanilla JS to justify build complexity.

---

### Alternative 3: Svelte
**Pros**:
- Smallest bundle size (~5KB)
- Compiles to vanilla JS
- Great performance

**Cons**:
- **Requires build step** (dealbreaker for our use case)
- Smaller ecosystem
- Less familiar to most developers
- Tooling not as mature

**Why Rejected**: Build step requirement conflicts with zero-config goal.

---

### Alternative 4: Alpine.js
**Pros**:
- No build step
- Small size (~15KB)
- Declarative templates
- jQuery-like simplicity

**Cons**:
- Another library to learn (even if simple)
- Less control for performance-critical rendering (virtual scrolling)
- Limited ecosystem

**Why Rejected**: Close contender, but vanilla JS with Web Components provides more control for our specific performance needs.

---

## Implementation Strategy

### 1. Use Modern Web Standards

**Web Components for Reusability**:
```javascript
class SessionList extends HTMLElement {
  connectedCallback() {
    this.render();
  }

  render() {
    this.innerHTML = `
      <div class="session-list">
        <!-- render sessions -->
      </div>
    `;
  }
}

customElements.define('session-list', SessionList);
```

**ES6 Modules for Organization**:
```javascript
// app.js
import { SessionList } from './components/session-list.js';
import { SearchBar } from './components/search-bar.js';
import { AppState } from './state.js';
```

**CSS Custom Properties for Theming**:
```css
:root {
  --primary-color: #3b82f6;
  --bg-color: #ffffff;
  --text-color: #1f2937;
}
```

### 2. State Management Pattern

**EventBus for Component Communication**:
```javascript
class EventBus {
  constructor() {
    this.events = {};
  }

  on(event, callback) {
    this.events[event] = this.events[event] || [];
    this.events[event].push(callback);
  }

  emit(event, data) {
    if (this.events[event]) {
      this.events[event].forEach(callback => callback(data));
    }
  }
}

const eventBus = new EventBus();

// Usage
eventBus.on('filters-changed', (filters) => {
  // Update session list
});

eventBus.emit('filters-changed', { tools: ['WebSearch'] });
```

**localStorage for Persistence**:
```javascript
class AppState {
  constructor() {
    this.load();
  }

  load() {
    const saved = localStorage.getItem('app-state');
    if (saved) {
      Object.assign(this, JSON.parse(saved));
    }
  }

  save() {
    localStorage.setItem('app-state', JSON.stringify(this));
  }
}
```

### 3. Performance Optimizations

**Debouncing for Search**:
```javascript
function debounce(func, wait) {
  let timeout;
  return function(...args) {
    clearTimeout(timeout);
    timeout = setTimeout(() => func.apply(this, args), wait);
  };
}

searchInput.addEventListener('input', debounce((e) => {
  performSearch(e.target.value);
}, 300));
```

**Virtual Scrolling for Large Lists**:
```javascript
class VirtualScroller {
  constructor(container, items, rowHeight) {
    this.container = container;
    this.items = items;
    this.rowHeight = rowHeight;
    this.visibleCount = Math.ceil(container.clientHeight / rowHeight);

    container.addEventListener('scroll', () => this.onScroll());
    this.render();
  }

  onScroll() {
    const scrollTop = this.container.scrollTop;
    this.visibleStart = Math.floor(scrollTop / this.rowHeight);
    this.visibleEnd = this.visibleStart + this.visibleCount + 10; // +10 buffer
    this.render();
  }

  render() {
    const visible = this.items.slice(this.visibleStart, this.visibleEnd);
    this.container.innerHTML = visible.map(item => this.renderRow(item)).join('');
  }
}
```

---

## Consequences

### Positive Consequences

1. **Instant Startup**: No npm install, no build step - just run server and go
2. **Simpler Codebase**: ~2,000 lines of readable JavaScript vs ~4,000+ lines with framework boilerplate
3. **Easier Debugging**: Direct DOM manipulation means easier browser DevTools debugging
4. **Better Performance**: No virtual DOM reconciliation overhead
5. **Future-Proof**: No framework migrations, no deprecation warnings
6. **Smaller Surface Area**: Fewer things to go wrong (no build config, no framework bugs)

### Negative Consequences

1. **More Manual Work**: Need to manually manage DOM updates (vs automatic with React/Vue)
2. **No Framework Ecosystem**: Can't use pre-built component libraries (but our UI is custom anyway)
3. **More Boilerplate**: Need to write own event handling, state management patterns
4. **Potential for Spaghetti Code**: Requires discipline to keep code organized (mitigated by Web Components)

### Mitigation Strategies

**For Manual DOM Management**:
- Use Web Components for encapsulation
- Establish clear patterns (EventBus, state object)
- Keep components small and focused

**For Code Organization**:
- ES6 modules for separation of concerns
- Clear directory structure (`components/`, `utils/`, `state.js`)
- Document patterns in code comments

---

## Validation

We will validate this decision by measuring:

1. **Development Speed**: Can we build MVP in 2-3 weeks?
   - **Target**: Yes, vanilla JS is fast for simple UIs

2. **Performance**: Does the app load and respond quickly?
   - **Target**: <3s initial load, <500ms filter updates
   - **Measurement**: Lighthouse performance audit

3. **Maintainability**: Can we add new features easily?
   - **Target**: New component in <1 hour
   - **Measurement**: Track time to implement Phase 2 features

4. **User Satisfaction**: Do users find the UI responsive?
   - **Target**: No complaints about slowness
   - **Measurement**: User feedback after 1 month

---

## Related Decisions

- **ADR-002**: Backend Language (Python vs Node.js)
- **ADR-005**: Deployment Model (Local HTTP Server vs Static Files)

---

## References

- [Web Components MDN](https://developer.mozilla.org/en-US/docs/Web/Web_Components)
- [You Don't Need JavaScript Framework](https://youmightnotneedjs.com/)
- [The Cost of JavaScript Frameworks](https://timkadlec.com/remembers/2020-04-21-the-cost-of-javascript-frameworks/)

---

**Decision Made By**: spec-architect (Claude)
**Stakeholders**: Solo developer, future contributors
**Review Date**: After MVP completion (3 months)
