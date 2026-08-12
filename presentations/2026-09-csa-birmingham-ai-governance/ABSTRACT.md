# AI Governance and Guardrails for Software

**Cloud Security Alliance (CSA) Birmingham** · September 8, 2026 · Birmingham, AL

> DRAFT — not yet submitted. Replace with the published abstract once the
> chapter confirms wording.

Generative AI is becoming a default part of how software gets built. That
changes delivery speed, and it changes the risk equation underneath it: more
code, more change, and more decisions made before any human reads the diff.

This session is a practical survey of what you can actually do about it. We
start by drawing the software delivery lifecycle — plan, build, test,
distribute, deploy, run — and showing that every stage of it is a place a
control can attach. From there we walk four cumulative levels of maturity for
agentic coding controls:

1. **Crawl — basic steering.** Project context files, rules, and instructions,
   and the limits of what they can carry.
2. **Walk — agents reviewing agents.** Specialised review agents, and
   delivering the right context for the change in front of you.
3. **Run — policy as code.** Deterministic security and compliance controls
   enforced in pull requests and CI, producing audit-ready evidence.
4. **Fly — continuous improvement.** Feedback loops that turn every guardrail
   violation into better guidance.

Along the way we look at where deterministic rules beat model judgement and
where they do not, and how the two compose — models advise, rules decide. We
close on the argument that matters most to anyone being asked to choose between
governance and velocity: structure in a repository makes agents faster, because
every constraint you write down is a decision the agent no longer has to guess
at.

Attendees should leave able to decide *which* guardrails their team should adopt
next, and which ones they are better off skipping for now.

---

Treat this as a specification: every claim made here needs a slide behind it,
and deck material that serves none of these claims is a candidate to cut.
