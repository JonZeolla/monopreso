# Guardrails for AI Coding

SANS@Night at the SANS Cloud Security Exchange Summit & Training 2026.

- **Date:** August 20, 2026
- **Time:** 6:00–7:00 PM PDT
- **Format:** In-person and virtual
- **Audience:** security practitioners, engineers, architects, managers, and governance leaders

## Narrative

The talk is one cumulative maturity model, not four unrelated categories of tools:

1. **Level 1: Crawl — Basic Steering.** Establish a consistent baseline with project context files, rules, and instructions.
2. **Level 2: Walk — Agent Reviewing Agents.** Layer specialized review agents and deliver relevant context based on the change, the work, and the workflow stage.
3. **Level 3: Run — Policy-as-Code Guardrails.** Convert non-negotiable requirements into deterministic PR/CI controls and audit-ready evidence.
4. **Level 4: Fly — Continuous Improvement.** Treat context and skills as versioned artifacts, evaluate them, make bounded updates, and promote only validated improvements.

Level 4 should receive the most new material. Hooks are supporting implementation detail in Level 3 and get one slide.

## Initial run of show (60 minutes)

- 0–7 min: framing, why guardrails, four-level roadmap
- 7–17 min: Level 1: Crawl — context files and their limits
- 17–27 min: Level 2: Walk — agent review, context injection, and progressive disclosure
- 27–40 min: Level 3: Run — policy-as-code, PR/CI enforcement, and one hooks slide
- 40–55 min: Level 4: Fly — feedback loops, evaluations, SkillOpt, related work, and promotion gates
- 55–60 min: takeaways and questions

## Level 4 anchor

Use the SkillOpt overview figure to explain the core analogy:

- model parameter → skill/context document
- gradient direction → trajectory-derived edit direction
- learning rate → bounded edit budget
- validation check → held-out selection gate
- deployed output → compact, reviewed context artifact

The operational takeaway is broader than any one research system: improve external context under evidence, not intuition.

## Remaining work

PR #30 was merged before this deck was finished. Tracked here so the gaps are
visible rather than rediscovered the week of the event.

- [ ] **Full timed run-through.** The run of show above is planned, not
      rehearsed. Level 4 carries the most new material and is the most likely
      to overrun.
- [ ] **Speaker notes.** None written. The SkillOpt analogy in particular needs
      a scripted delivery — it is the densest idea in the talk.
- [ ] **Migrate the reused slides onto primitives.** Every module this deck
      imports still emits `vis-*` markup, so the deck is effectively pinned to
      a brand. `2026-09-csa-birmingham-ai-governance` (PR #31) established the
      primitive-native pattern; these should follow it.
- [ ] **Confirm the abstract matches what was published** by SANS, and reconcile
      any drift between `ABSTRACT.md` and the deck's actual content.
- [ ] **`img/` is empty.** Either populate it or remove it — the only figure the
      deck references lives at `modules/context/img/skillopt-overview.png`.
- [ ] **Delete `2026-08-sans-cse-guardrails-ai-coding_title.j2`.** The modern
      engine never reads it; `start.sh` takes the page title from the folder
      name. It is a revealjs-era artifact carried over by habit.
