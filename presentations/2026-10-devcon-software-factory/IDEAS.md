# Building a Software Factory

- **Event:** DevCon
- **Date:** October 13, 2026
- **Location:** BNY Offices, Pittsburgh, PA
- **Duration:** 60 minutes
- **Format:** in-person
- **Audience:** developers at BNY DevCon

## Narrative

This is the CSA Birmingham governance deck
(`2026-09-csa-birmingham-ai-governance`, see its NOTES.md) with the
"software factory" framing from the abstract. Same three parts: make the
rules, enforce the rules, update the rules.

Differences from CSA:

- **Added** the abstract's first line as a statement slide after the title
  ("Software factories are great / in theory").
- **Added** the SkillOpt "Context and Skills" slide to Part 1, after context
  degradation and before the structured requirement. It answers the
  abstract's "how do you measure if they're even working?" line: bounded
  edits plus a held-out gate, versus ad hoc edits that jump to a worse skill.
- **Removed** sandboxing: the sandboxing control profile is out of the Part 2
  flip-through (five profiles remain), and "Sandboxing" is dropped from the
  Build and Run columns of the closing lifecycle slide via the new
  `exclude` argument on `sdlc()`.

29 slides. CSA ran 28 in 50 minutes.

## Slides reused

Everything from the CSA deck except `profile_sandboxing`, plus
`context/skill-optimization.j2` — `context_and_skills` from the SANS CSE deck.
