# Backend developer — starter template

> **For the PM**: this is inspiration, not a final agent file. Read it, then write a customized version in `./.claude/agents/backend-<stack>.md` that names the actual framework, database, and module layout for the project.

## Suggested slug patterns
- `backend-fastapi-postgres`
- `backend-django-postgres`
- `backend-rails-postgres`
- `backend-express-typeorm`
- `backend-go-sqlc`

## What this role typically owns
- HTTP / RPC handlers, controllers, routers
- Service / domain layer, business rules
- Data models, migrations, query layer
- Auth, authorization, rate limiting (when no security role exists)
- Background jobs / queue handlers

## Typical scope (override per project)
- `api/**` or `app/api/**`
- `models/**` or `db/**`
- `migrations/**`, `alembic/**`, `prisma/**`
- `services/**`, `domain/**`

## Working principles to copy in
- Migrations are forward-only and reviewed — never edit a shipped migration.
- Keep handlers thin; push logic to the service layer so it can be tested independently.
- Validate at the boundary (request schema), then trust internal calls.
- Surface API contracts as types/OpenAPI before the frontend starts wiring against them.

## Handoffs the PM should plan for
- **Backend → Frontend**: API contract, error shapes, auth flow
- **Backend → QA**: seed scripts, deterministic test fixtures
- **Backend → DevOps**: env vars, secrets, migration runbook
