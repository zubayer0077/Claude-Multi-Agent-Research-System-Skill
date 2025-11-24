# ADR-004: No Build Process

## Status

Accepted

## Context

Modern web development typically involves build tools like:
- **Bundlers**: Webpack, Rollup, Vite, Parcel
- **Transpilers**: Babel, TypeScript
- **CSS Processors**: PostCSS, Sass, Less
- **Linters/Formatters**: ESLint, Prettier

We need to decide whether to introduce any of these tools for this project.

## Decision

We will not use any build tools. The source files are the production files.

## Consequences

### Positive
- **Zero configuration**: No webpack.config.js, no tsconfig.json
- **Instant iteration**: Edit file, refresh browser
- **No node_modules**: No 500MB dependency folder
- **No build failures**: Nothing to break
- **Beginner friendly**: Accessible to anyone learning web dev
- **Long-term stability**: No deprecated dependencies

### Negative
- **No TypeScript**: No static type checking
- **No modern JS features**: Limited to browser-native ES6+
- **No CSS nesting**: Native CSS only (though CSS nesting is now supported)
- **No tree shaking**: (Not needed - no dependencies)
- **No source maps**: (Not needed - source is production)

## Alternatives Considered

### Vite
- **Pros**: Fast, modern, minimal config
- **Cons**: Still requires Node.js, package.json, build step
- **Decision**: Rejected - adds unnecessary complexity

### Parcel
- **Pros**: Zero-config bundler
- **Cons**: Still a build step, node_modules
- **Decision**: Rejected - "zero config" still means configuration

### TypeScript without Bundler
- **Pros**: Type safety, better IDE support
- **Cons**: Requires compilation step, tsconfig.json
- **Decision**: Rejected - not worth it for 10 lines of JS

## When to Reconsider

Add build tooling if any of these become true:
- [ ] Need to support older browsers (IE11)
- [ ] TypeScript becomes necessary for team productivity
- [ ] CSS needs preprocessing (variables, nesting beyond native)
- [ ] Multiple JavaScript files need bundling
- [ ] Performance optimization (minification) becomes critical

## Philosophy

> "The best build tool is no build tool."

This project embraces the philosophy that for simple projects, the overhead of modern tooling exceeds its benefits. The web platform has evolved to support most needs natively.

## References

- [Buildless](https://buildless.site/) - Philosophy guide
- [Modern Web Development on the JAMstack](https://www.netlify.com/jamstack/) - Static-first approach
- [The Cost of JavaScript in 2019](https://v8.dev/blog/cost-of-javascript-2019) - Bundle size matters
