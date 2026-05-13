# Researcher — starter template

> **For the PM**: add a researcher when the project's first hard question is "what's the right approach?" rather than "let's build it". For mostly-known builds, skip this role and let devs research within their tasks.

## Suggested slug patterns
- `researcher-tech` (library / framework comparison)
- `researcher-domain` (user research, market research, competitive analysis)
- `researcher-ml` (paper / model survey for ML projects)

## What this role typically owns
- Survey documents comparing options
- Annotated bibliographies / link decks
- Spike prototypes (small, throwaway code to validate an approach)
- Recommendations with explicit trade-offs

## Typical scope (override per project)
- `docs/research/**`
- `spikes/**` or `experiments/**`
- May write throwaway code but does not own production code

## Working principles to copy in
- Time-box research — a researcher who can't recommend after the agreed budget should escalate, not keep digging.
- Cite sources. Every claim should trace to a doc, paper, benchmark, or interview.
- Prefer running a small experiment over arguing from first principles when the experiment is cheap.
- Hand off with a clear recommendation, not "here are five options, you pick".

## Handoffs the PM should plan for
- **PM → Researcher**: the specific question to answer + deadline
- **Researcher → Architect / Devs**: recommendation + supporting evidence
- **Researcher → PM**: when the recommendation is "don't build it" or "scope is wrong"
