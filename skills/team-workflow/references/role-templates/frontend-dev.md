# Frontend developer — starter template

> **For the PM**: this is inspiration, not a final agent file. Read it, then write a customized version in `./.claude/agents/frontend-<framework>.md` that names the actual framework, component conventions, and file layout for the project you're working on.

## Suggested slug patterns
- `frontend-react-tailwind`
- `frontend-vue-pinia`
- `frontend-svelte-kit`
- `frontend-nextjs`

## What this role typically owns
- Components, pages, routing, client-side state
- Styling and design tokens
- Browser-facing assets, public folder, build pipeline (when no devops role exists)
- E2E selectors / data-testid contracts with the QA role

## Typical scope (override per project)
- `src/components/**`
- `src/pages/**` or `app/**` (for Next.js)
- `src/styles/**`, `tailwind.config.*`
- `public/**`

## Working principles to copy in
- Treat the design tokens / component library as a single source of truth — don't introduce one-off styles.
- Match existing prop / state / hooks conventions before introducing new patterns.
- When a feature crosses backend boundaries, agree on the request/response contract via SendMessage first.
- Component changes need at least one render test or Storybook update unless the project explicitly opts out.

## Handoffs the PM should plan for
- **Designer → Frontend**: spec, mockups, design tokens
- **Backend → Frontend**: API contract (OpenAPI / typed client / shared types package)
- **Frontend → QA**: stable selectors, accessibility hooks
