# ADR-002: Inline vs External Resources

## Status

Accepted

## Context

For this minimal web page, we need to decide whether to:
1. Keep CSS and JavaScript inline within the HTML file
2. Separate them into external files (styles.css, script.js)

This decision affects file organization, caching, and deployment complexity.

## Decision

We will use inline CSS and JavaScript within a single `index.html` file.

## Consequences

### Positive
- **Single file deployment**: Only one file to upload/manage
- **No additional HTTP requests**: Everything loads in one request
- **Atomic updates**: Entire site updates at once
- **Simpler hosting**: Any static file server works
- **No CORS issues**: No cross-origin resource loading

### Negative
- **No caching of assets**: CSS/JS reload with each page visit
- **Harder to maintain at scale**: Would become unwieldy for larger projects
- **No code sharing**: Cannot reuse styles/scripts across pages

## Alternatives Considered

### External Files (styles.css + script.js)
```
project/
├── index.html
├── styles.css
└── script.js
```
- **Pros**: Better separation of concerns, browser caching
- **Cons**: Three files to manage, three HTTP requests
- **Decision**: Rejected - caching benefits negligible for <2KB total

### CSS-in-JS
- **Pros**: Modern approach, scoped styles
- **Cons**: Requires JavaScript framework, build process
- **Decision**: Rejected - unnecessary complexity

## Notes

If this project grows to multiple pages, this decision should be revisited. The threshold for switching to external files would be:
- More than 50 lines of CSS
- More than 20 lines of JavaScript
- Multiple HTML pages sharing styles

## References

- [Critical CSS and Webpack](https://web.dev/extract-critical-css/)
- [Inline vs External CSS](https://csswizardry.com/2018/11/css-and-network-performance/)
