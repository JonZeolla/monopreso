# AI Governance and Guardrails for Software

- **Event:** Cloud Security Alliance (CSA) Birmingham
- **Date:** September 8, 2026
- **Location:** Birmingham, AL
- **Duration:** 60 minutes
- **Format:** in-person
- **Audience:** security practitioners, engineers, and governance leaders

## Narrative

The room is mixed — governance people who do not write software, and engineers
who do not sit in governance meetings. Neither group can act on advice pitched
at the other, so the talk earns the right to its recommendations by first
drawing the delivery lifecycle everyone half-knows and showing that every stage
of it is a place a control can attach.

From there it is one cumulative maturity model rather than four unrelated
categories of tooling. The argument closes on the claim most likely to be
resisted: that structure and guardrails make agentic development *faster*,
because every constraint written down is a decision the agent no longer guesses
at. Guardrails are not a tax on velocity — at level 4 they are the training
signal that produces it.

The one idea to leave with: **governance is a property of the whole delivery
line, and the cheapest place to enforce anything is the earliest place you can.**

## Run of show (60 minutes)

- **0–7** — Opening. Title, how coding agents got here, why guardrails now.
- **7–18** — Part 1: the ground truth. The delivery lifecycle bare, then the
  same diagram with controls annotated onto it, then the survey of the four
  families of control. This is the section that makes the rest legible to the
  non-engineers.
- **18–21** — Part 2 opens: the four-level maturity model, overview.
- **21–29** — Level 1 Crawl: context windows, degradation, context files and
  their tradeoffs.
- **29–35** — Level 2 Walk: layered agent review, right context at the right
  time.
- **35–44** — Level 3 Run: layered defense, a deterministic policy example,
  hooks, the CI/CD enforcement window, server-side wiring.
- **44–50** — Part 3: deterministic rules vs. model judgement, and the
  composition pattern (models advise, rules decide).
- **50–56** — Part 4: the "should you?" decisions — hooks, agent review,
  blocking CI. Each commits to a verdict.
- **56–60** — Part 5: Level 4 Fly. Structure is speed, the feedback loop,
  questions.

Level 4 is deliberately pulled out of Part 2 and used as the close, so the talk
ends on the compounding argument rather than on enforcement.

## Slides reused

From the merged CSE deck (PR #30) and earlier work:

- `guardrails/ai-coding-maturity.j2` — `why_guardrails`, `overview`, `crawl`,
  `walk`, `run`, `fly`
- `context/` — `context-window`, `context-degradation`, `context-files`,
  `context-injection`
- `agents/` — `coding-agent-evolution`, `agent-review`, `agent-feedback-loop`
- `guardrails/` — `layered-defense`, `deterministic-guardrails`, `policy-feedback`
- `ci-cd/` — `cicd-enforcement`, `server-side-review`
- `hooks/hooks.j2` — `when_x_then_y`

## Slides written for this talk

All four modules are primitive-native — no hex, no brand classes — so they
render under any brand pack.

- `modules/sdlc/lifecycle.j2` — `stages()`, `stages_with_controls()`,
  `survey()`. The bare-then-annotated pair shares one stage list so the cards
  land in the same screen position and only the annotations change.
- `modules/guardrails/deterministic-vs-llm.j2` — `two_kinds()`,
  `working_together()`.
- `modules/guardrails/guardrail-decisions.j2` — `decision_frame()`,
  `should_you_hooks()`, `should_you_agent_review()`, `should_you_blocking_ci()`.
  A pros/cons slide lists tradeoffs; these commit to a verdict and name the
  condition that flips it.
- `modules/guardrails/structure-enables-speed.j2` — `structure_is_speed()`,
  `the_loop()`.

Primitives added to all three brand packs to support these: `content_slide(label)`
and `pipe(stages)`.

## Open threads

- The reused `vis-*`-era slides still render through the Zenable compatibility
  shim. They look right under `zenable` and `sans-cloud`, degraded under
  `unbranded`. The four new modules do not have this problem.
- Gherkin / spec-driven material exists only as revealjs HTML
  (`modules/coding-agents/spec-driven-development.html`). If it should appear
  here it needs porting to a modern macro — not currently wired in.
- 38 slides for 60 minutes is ~95 seconds each. Comfortable, but Level 3 is the
  first place to cut if the run-through goes long.
