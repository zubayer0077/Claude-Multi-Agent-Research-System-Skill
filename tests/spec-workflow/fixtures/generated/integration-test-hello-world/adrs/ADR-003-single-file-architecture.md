# ADR-003: Single File Architecture

## Status

Accepted

## Context

Following ADR-001 (vanilla tech) and ADR-002 (inline resources), we need to formalize the decision to use a single-file architecture where the entire application lives in one `index.html` file.

This is an unusual architecture choice that warrants explicit documentation.

## Decision

The entire application will be contained in a single `index.html` file including:
- HTML structure
- CSS styles (in `<style>` tag)
- JavaScript code (in `<script>` tag)

## Consequences

### Positive
- **Maximum simplicity**: One file = one deployment unit
- **Easy to share**: Can email or paste the entire app
- **No build step**: What you write is what runs
- **Portable**: Works offline, can be saved and reopened
- **Self-documenting**: Everything visible in one place

### Negative
- **Size limits**: Becomes unwieldy beyond ~500 lines
- **No modularity**: Cannot import/export code
- **IDE limitations**: Less tooling support for mixed content
- **Testing complexity**: Harder to unit test inline code

## Alternatives Considered

### Multi-File with Module Bundler
```
src/
├── index.html
├── styles/
│   └── main.css
└── scripts/
    └── main.js
```
- **Pros**: Standard project structure, scalable
- **Cons**: Requires bundler (Webpack, Vite), complex setup
- **Decision**: Rejected - massive overkill

### Web Components
- **Pros**: Native component model, no framework
- **Cons**: Still requires JavaScript knowledge, more code
- **Decision**: Rejected - overcomplicated for requirements

## Implementation Notes

### File Structure
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello World</title>
    <style>
        /* All CSS here */
    </style>
</head>
<body>
    <!-- All HTML here -->
    <script>
        // All JavaScript here
    </script>
</body>
</html>
```

### Expansion Path

If requirements grow, migrate to multi-file structure:
1. Extract `<style>` content to `styles.css`
2. Extract `<script>` content to `script.js`
3. Add `<link>` and `<script src>` references

## References

- [Single-File Components in Vue](https://vuejs.org/guide/scaling-up/sfc.html) - Similar philosophy
- [HTML First](https://html-first.com/) - Philosophy alignment
