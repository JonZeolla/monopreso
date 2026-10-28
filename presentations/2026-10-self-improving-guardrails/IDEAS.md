# Self Improving Guardrails for Coding Agents

- **Event:** TODO (venue not yet recorded)
- **Date:** Wednesday, October 28, 2026, 6:30–7:30 PM
- **Location:** TODO
- **Duration:** 60 minutes
- **Format:** in-person
- **Audience:** security practitioners and engineers adopting coding agents

## Narrative

TODO — the spine of the talk in a few sentences. What is the one idea someone
should leave with, and what has to be true for them to accept it?

## Run of show

Budget roughly 60–90 seconds per content slide, and make the minutes add up to
the session length before writing any slides — the structure determines how much
existing material you can reuse.

- 0–TODO min: framing
- TODO: ...
- Last 5 min: takeaways and questions

## Slides to reuse

Everything in the deck is an existing macro, assembled unchanged (first commit).
Later tweaks target the two-loop feedback slide (`agents/agent-feedback-loop.j2`):
add an in-place animation like the marketing site's lifecycle strip — a pill on
the path with glowing dots travelling behind it.

- Open: about-speaker profile + activity, mission Venn, AI janitor pair, code-volume pair
- Background: context layers / files / degradation, hooks ×2, verifiers ×2, layered AI review
- Self-improvement: loops use cases, agent feedback loop
- Context evals: SkillOpt (context_and_skills)

## Slides to write

New content belongs in modules/<topic>/<name>.j2 as a macro, built from brand
primitives. If a primitive is missing, implement it in all three brand packs
before writing the slide — see .claude/skills/new-presentation/references/primitives.md.

- TODO
