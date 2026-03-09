# Stack Profile

Profile ID: python-service

Use this overlay when the repository is a Python HTTP service. The default mental model is a FastAPI-style service, not a CLI-first tool.

## Default Assumptions

- HTTP endpoints, schemas, and services should stay explicit.
- Request and response models should follow the repo's existing Python framework conventions.
- The service may use `pytest`, `ruff`, and type checking, but keep the commands aligned with what the repo already has.

## Design Guardrails

- Prefer clear request and response models over loose dictionaries.
- Keep transport concerns thin if the repo already separates routers, schemas, and services.
- Reuse the existing async or sync style instead of mixing both arbitrarily.
- Do not steer the implementation toward CLI tooling; keep the profile service-oriented.

## Verification Commands

Use the repo's execution wrapper if it uses `uv`, `poetry`, or another tool.

```bash
pytest
ruff check .
python -m mypy .
```

## File Placement Hints

- HTTP routes or routers: wherever the repo currently defines endpoint modules
- Schemas or models: next to the repo's existing request/response schema pattern
- Service logic: service modules or equivalent business-logic layer
- Tests: follow the repo's existing `tests/` layout for API or service coverage
