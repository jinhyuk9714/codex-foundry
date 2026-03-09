# Stack Profile

Profile ID: node-api

Use this overlay when the repository is a JavaScript or TypeScript HTTP API.

## Default Assumptions

- The codebase exposes routes, handlers, controllers, or service modules for HTTP behavior.
- Input validation, auth, and error mapping should stay explicit.
- The repo may use Express, Fastify, Nest-like modules, or a custom server layout; follow the existing pattern instead of introducing a new framework style.

## Design Guardrails

- Be explicit about request validation, response shapes, and status codes.
- Keep business logic out of the thinnest transport layer when the repo already has a service layer.
- Reuse existing middleware, auth, and error-handling conventions before adding new ones.
- Prefer additive route changes over broad refactors of unrelated endpoints.

## Verification Commands

Use the repo's package manager equivalent for these commands if it does not use `npm`.

```bash
npm test
npm run lint
npm run build
```

## File Placement Hints

- Routes or controllers: stay in the repo's existing HTTP entry layer
- Business logic: service or domain modules already used by the repo
- Schemas and validation: next to existing request/response schema patterns
- Contract or integration tests: wherever the repo already checks endpoint behavior
