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
