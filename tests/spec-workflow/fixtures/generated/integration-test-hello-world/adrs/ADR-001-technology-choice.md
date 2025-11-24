# ADR-001: Technology Choice

## Status

Accepted

## Context

We need to select the technology stack for building a simple "Hello, World!" web page with an interactive button. The requirements specify:
- Display a heading
- Interactive button with alert
- Centered, styled content

Options considered include modern frameworks (React, Vue) and vanilla web technologies.

## Decision

We will use vanilla HTML, CSS, and JavaScript without any frameworks or build tools.

## Consequences

### Positive
- **Zero dependencies**: No npm packages to manage or update
- **Instant setup**: No build configuration required
- **Maximum performance**: Minimal file size, fastest possible load
- **Universal compatibility**: Works in any browser that supports HTML5
- **Easy to understand**: Any developer can read and modify
- **No security vulnerabilities**: No third-party code to audit

### Negative
- **No component reusability**: Cannot easily extend to larger applications
- **Manual DOM manipulation**: No reactive data binding
- **Limited scalability**: Would need refactoring for complex features

## Alternatives Considered

### React
- **Pros**: Component model, large ecosystem, industry standard
- **Cons**: ~40KB+ bundle size, build process required, overkill for simple page
- **Decision**: Rejected - too heavy for requirements

### Vue
- **Pros**: Lighter than React, easy learning curve
- **Cons**: Still requires build process, unnecessary complexity
- **Decision**: Rejected - still overkill

### Plain HTML with External CSS/JS Files
- **Pros**: Separation of concerns, caching benefits
- **Cons**: Multiple HTTP requests, more files to manage
- **Decision**: Partially considered - see ADR-002

## References

- [You Might Not Need JavaScript](https://youmightnotneedjs.com/)
- [The Cost of JavaScript Frameworks](https://timkadlec.com/remembers/2020-04-21-the-cost-of-javascript-frameworks/)
