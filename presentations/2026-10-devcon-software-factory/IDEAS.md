# Building a Software Factory

- **Event:** DevCon
- **Date:** October 13, 2026
- **Location:** BNY Offices, Pittsburgh, PA
- **Duration:** TODO (planned against 45 minutes below; rescale if different)
- **Format:** TODO (in-person / virtual / hybrid)
- **Audience:** TODO — assumed developers and platform engineers at large,
  regulated companies, with a few security and compliance people in the room

## Narrative

The "software factory" is the DevCon-friendly name for the same spine as the
CSA Birmingham governance deck: make the rules, enforce the rules, update the
rules. The difference is the framing and the audience. CSA heard it as
*governance*; DevCon hears it as *a production line*, and the enterprise
wrinkle (auditors, regulators, platform teams) is the opening tension rather
than an aside.

The one idea to leave with: **compliance is a set of tolerances like any other,
and the same line that checks correctness can check it, at the station where
a defect is cheapest to catch.** The close is the compounding argument from
the CSE deck: structure is speed, because every constraint written down is a
decision the agent no longer guesses at.

What has to be true for a sceptical enterprise developer to accept it:

1. Rules have to be written where the agent actually reads them, and they
   have to be specific enough to act on (Part 1).
2. Enforcement has to be cheap enough to run on every change and leave
   evidence an auditor will accept without a meeting (Part 2).
3. The loop has to change the rules, not just count violations, or the
   factory never gets better (Part 3).

## Run of show (45 minutes)

- **0–5** — Opening. Title, "great... in theory", the volume problem: code
  output grew 11× and the reviewer pool did not.
- **5–8** — What a factory actually is. Lifecycle bare, then the three boxes:
  make / enforce / update.
- **8–17** — Part 1: Make the rules. The unenforceable policy, where the
  agent reads rules, why they decay, the structured requirement.
- **17–31** — Part 2: Enforce the rules. Hooks in action, verifiers, coverage,
  the six control profiles on one scale. Payoff: nothing scores four across
  the board, so pick stations deliberately.
- **31–39** — Part 3: Update the rules. Policy feedback, the rewritten
  requirement, the rule in five engines, the agent feedback loop, the
  lifecycle with every control hung under its stage.
- **39–42** — Close: Structure = Speed.
- **42–45** — Questions.

~30 content slides at ~80 seconds each. If the slot is 30 minutes, drop the
control-profile flip-through to three profiles and cut `refined_rules`.

## Slides to reuse

Nearly everything comes from the CSA Birmingham deck
(`2026-09-csa-birmingham-ai-governance`) and the SANS CSE deck:

- `intro/ai-janitor.j2` — `both` (opening image beats)
- `agents/code-volume.j2` — `ten_years_github`, `late_2025_inflection`
- `sdlc/lifecycle.j2` — `sdlc` (bare lifecycle up front, with controls at the close)
- `governance/what-is-governance.j2` — `what_it_is`
- `governance/policy-statement.j2` — `unenforceable`
- `context/context-files.j2` — `mockup`
- `context/context-degradation.j2` — `quality_drop`
- `governance/structured-requirement.j2` — `structured`, `encryption_at_rest`
- `hooks/hooks.j2` — `in_action`
- `verifiers/verifiers.j2` — `four_kinds`, `coverage`
- `guardrails/control-profile.j2` — all six profiles
- `guardrails/policy-feedback.j2` — `policy_feedback`
- `guardrails/refined-rules.j2` — `refined_rules`
- `agents/agent-feedback-loop.j2` — `feedback_loop`
- `guardrails/structure-enables-speed.j2` — the close
- `outro/outro.j2` — `thank_you`

## Slides to write

- **"Great... in theory."** A statement slide for the opening tension: the
  whiteboard factory vs. the auditor, the regulator, three platform teams and
  a spreadsheet. `statement()` primitive, no new module needed unless it
  grows.
- **"Compliance is a tolerance."** The bridge from Part 1 into Part 2 for the
  regulated-shop audience: the same requirement expressed as a check at the
  cheapest station. Candidate for `modules/governance/`.
- **Evidence for the auditor.** Part 2 promises "every decision leaves
  evidence an auditor can read". Nothing in the repo shows that yet; this is
  the one genuinely new slide. Candidate for `modules/ci-cd/`.
