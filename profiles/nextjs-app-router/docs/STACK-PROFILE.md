# Stack Profile

Profile ID: nextjs-app-router

Use this overlay when the repository is a Next.js application using the App Router.

## Default Assumptions

- New routes live under `app/`, not `pages/`.
- Route handlers live under `app/api/`.
- Shared UI usually belongs in `components/`.
- Shared server-side helpers usually belong in `lib/`.

## Design Guardrails

- Respect server/client boundaries. Add `"use client"` only where interactivity actually requires it.
- Prefer keeping secrets, tokens, and direct data access in server-only code.
- For new async screens, include loading, empty, and error states when they are relevant.
- Keep route structure, metadata, and data loading consistent with existing App Router patterns.

## Verification Commands

Use the repo's package manager equivalent for these commands if it does not use `npm`.

```bash
npm test
npm run lint
npm run build
```

## File Placement Hints

- New pages and layouts: `app/`
- Route handlers: `app/api/`
- Reusable UI: `components/`
- Shared utilities and data access: `lib/`
- End-to-end or integration coverage: use the repo's existing test location, not a new pattern
