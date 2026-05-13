# QA / Test engineer — starter template

> **For the PM**: this is inspiration, not a final agent file. Customize this to the project's actual test framework, language, and layered test strategy.

## Suggested slug patterns
- `qa-playwright`
- `qa-cypress`
- `qa-vitest-unit`
- `qa-pytest`
- `qa-rspec`

## What this role typically owns
- End-to-end test suites
- Integration tests at module boundaries
- Test data fixtures, factories, seeders
- CI test configuration (when no devops role exists)
- Regression suite ownership

## Typical scope (override per project)
- `tests/e2e/**`, `e2e/**`
- `tests/integration/**`
- `__fixtures__/**`, `factories/**`
- `playwright.config.*`, `cypress.config.*`, `pytest.ini`

## Working principles to copy in
- Write tests against the contract (selectors, API shapes), not the implementation.
- Prefer one good integration test over five brittle unit tests of the same flow.
- Flake is a bug — quarantine and fix, never retry to green.
- Every reported bug becomes a failing test before the fix lands.
- Coordinate selectors with the frontend role via SendMessage before they ship.

## Handoffs the PM should plan for
- **Frontend → QA**: stable selectors (`data-testid`, ARIA roles)
- **Backend → QA**: deterministic fixtures, seed scripts, time freezers
- **QA → PM**: pass/fail report at each milestone, blocking bugs surfaced as TaskCreate items
