# Working notes — AI Governance and Guardrails for Software

Scratch space for first-draft thinking. Not polished, not for the deck yet.
When this feels done, revisit each item and turn it into an actual slide/content change.

---

## IMPLEMENTED (2026-08-16) — deck rewritten; everything below is now historical context

The content file was rewritten to the decided structure, plus the live edit
requests Jon made while reviewing the rendered deck. Current state:

**New shared modules created (all primitive-native):**
- `modules/guardrails/guardrail-spectrum.j2` — `highway_vs_monorail()`,
  `the_balance()`, `paved_roads()`
- `modules/guardrails/policy-as-code.j2` — `pac_history()`,
  `policy_architecture()` (PAP/PDP/PIP/PEP), `policy_architecture_today()`
  (same diagram remapped onto the agent pipeline)
- `modules/context/context-rules-intro.j2` — `context_files_rules()`
  ("Context Files & Rules" transition, replaces the maturity Crawl slides)
- `modules/verifiers/verifiers.j2` — `verifiers_are_guardrails()` (humans
  included), `ensembling_fast_verifiers()` (independence assumption on the
  slide), `weaver_evidence()` (figure + arXiv cite)
- `modules/verifiers/self-improvement.j2` — `verifier_self_improvement()`,
  `improvement_gates()` (the from-scratch close; no Fly / maturity framing)
- `modules/governance/tool-calls.j2` — `everything_is_a_tool_call()`,
  `monitor_allow_deny()`, `sandboxing_nono()`, `nono_scoped_call()`

**Assets:** Weaver figure moved to
`modules/verifiers/img/weaver-weighted-vs-naive-ensembles.png` (shared-module
convention, like the skillopt image). SOURCES.md updated with the CNCF
whitepaper, Weaver, nono, and GitHub-data attributions.

**Removed per Jon's live review:** both numbered section-divider slides (and
all other dividers, since the numbering no longer held), `why_guardrails`
(replaced by the two GitHub-velocity slides from
`modules/agents/code-volume.j2`: `ten_years_github` + `late_2025_inflection`),
`maturity_overview`, `maturity_crawl` (and `walk`/`run`/`fly` with the whole
maturity spine), `cicd_enforcement`, `server_side_wiring`, and all of the old
Part 4 except `decision_frame` ("Three questions for any guardrail").

**Kept vis-era slides:** coding-agent evolution, context window/degradation/
files/injection, layered AI review, layered defense, PCI example, hooks,
agent feedback loop, policy feedback, outro.

**Verified:** renders under zenable, unbranded, and sans-cloud — 40 slides.

**For the review/consolidation pass (Jon trims):** 40 slides / 60 min is
~90s each; the governance section (4 slides) and the paved-roads→context run
(7 slides) are the thickest candidates if it runs long.

---

## New content thread: policy-as-code history → enforcement → verifiers as guardrails

Likely lands somewhere in Part 3 ("Run" / deterministic enforcement), alongside
the existing `layered_defense()` / `deterministic_pci_example()` slides — exact
placement TBD.

1. **Brief history of policy as code.** What predates today's policy-as-code
   tooling. Introduce the classic architecture vocabulary:
   - PDP — Policy Decision Point
   - PIP — Policy Information Point
   - PAP — Policy Administration/Management Point
   - (presumably PEP — Policy Enforcement Point, goes with the others even
     though Jon didn't say it explicitly — confirm)
   - Wants to reuse a diagram from a CNCF white paper he contributed to.

   **Repo research on the diagram — did NOT find a PDP/PIP/PEP/PAP diagram
   already in the repo.** What exists instead:
   - `modules/governance/img/k8s_grc_paper_overview.png` — a Governance/Risk/
     Compliance pyramid diagram (Audit & Assurance → Operational Areas →
     "Kubernetes Policy Management"), used in `governance_intro_simple.html`
     with the caption `zenable.io/cncf-grc-paper`. This is from the K8s
     SIG-Security **GRC** whitepaper, not a PDP/PIP/PEP/PAP architecture
     diagram.
   - `modules/policy_as_code/IDEAS.md` (dated Jan 2024) lists two whitepapers
     as **un-implemented future additions**, never turned into slides or image
     assets:
     - `CNCF_Kubernetes_Policy_Management_WhitePaper_v1.pdf` (kubernetes/sig-security repo) — more likely candidate for a PDP/PIP/PEP/PAP-style architecture diagram, given the title.
     - `kubernetes-grc.md` — the GRC paper, source of the pyramid diagram above.
   - No prior CSA Birmingham deck (`presentations/2024-09-CSA_Birmingham/`)
     covers this either — it did container/IaC/governance-pyramid content
     instead.

   **RESOLVED — confirmed source, and the diagram exists.** Jon confirmed:
   Policy Management whitepaper, downloadable from GitHub. Fetched it:
   `github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/policy/CNCF_Kubernetes_Policy_Management_WhitePaper_v1.pdf`
   (saved to scratchpad as `policy_mgmt_whitepaper.pdf` for reference — not
   committed anywhere). It has exactly the PDP/PIP/PEP/PAP content, all four
   terms confirmed (PEP is in fact the fourth term, as guessed above):

   - **p.6 — "Policy Architecture"**: the generic XACML diagram. Simplest,
     most quotable version — probably the one to lead with.
     `users/systems → PEP ⇄ PDP ⇄ PIP`, `PDP ⇄ PAP ⇄ policies ⇄ administrator`,
     `PEP → resources`. Explains the roles in one paragraph: PAP authors a
     Policy/PolicySet and hands it to the PDP; the PEP intercepts a user
     request and asks the PDP how to handle it; the PDP enriches the request
     with attributes from the PIP and applies policy; PDP tells PEP allow/deny.
   - **p.7 — "Policy Administration Point (PAP)"**: Kubernetes-specific
     diagram — one PAP doing centralized policy management, fanning out to a
     CI/CD pipeline (pre-commit checks) and multiple K8s clusters (admission
     controls), each with its own PEP.
   - **p.8 — "Policy Enforcement Point (PEP)"**: PEPs enforce that current
     state matches policy; built-in K8s policy objects, admission-controller
     extensions, and runtime policy engines are the three enforcement
     mechanisms (not mutually exclusive — paper recommends using all three
     together).
   - **p.12 "Policy Decision Point (PDP)"** and **p.13 "Policy Information
     Point (PIP)"**: prose sections, no extra diagrams — PDP is the policy
     engine rendering decisions (inform/audit vs. enforce mode); PIP is
     the extra metadata/config a decision needs (e.g. namespace labels).
   - Authors: Anca Salier (IBM), Ardhna Chetal (TIAA), Jayashree Ramanathan
     (Red Hat), Jim Bugwadia (Nirmata), Robert Ficcaglia (Sunstone Secure) —
     worth double-checking whether Jon is a listed author/acknowledged
     contributor or contributed some other way (the deck's claim is "a CNCF
     white paper he contributed to" — confirm which credit line before it
     goes on a slide).

   **Still open:** does the *K8s-specific* framing (p.7/p.8, admission
   controllers, clusters) serve a talk that's about AI coding guardrails, or
   is the generic p.6 diagram (which maps cleanly onto CI/CD-pipeline /
   agent-guardrail equivalents: agent-or-user request → PEP → PDP ⇄ PIP,
   PAP ⇄ policies) the better one to adapt? Leaning toward adapting the p.6
   generic diagram as a primitive-native `pipe()`/custom diagram rather than
   embedding the K8s-flavored image — but confirm with Jon before building it.

2. **Policy enforcement and verifiers.** Follows the history bit.

3. **Verifiers as a type of guardrail.** Ties back into the deck's existing
   "rules vs. models" framing (`modules/guardrails/deterministic-vs-llm.j2`)
   and the maturity model's Level 3 (`ai-coding-maturity.j2` / `run`).

Explicit ask: **this needs to be visually insightful** — Jon wants to talk
through it live with participants, so lean on a diagram/visual rather than
bullet text. Given the deck's primitive-native direction (see AGENTS.md), this
is a candidate for a new `pipe()`-based or custom shared-slide diagram rather
than an embedded image, but that's an implementation decision for later.

---

## New content thread: verifiers, the highway/monorail analogy, paved roads, → context engineering

Extends the thread above rather than replacing it — verifiers are introduced
as *why* policy enforcement (PDP/PEP/etc.) matters for keeping agents/models
on track, then broadens into a standalone argument about how much constraint
is the right amount.

1. **Verifiers keep models on track.** The throughline from "here's the
   policy architecture" to "here's why it matters for agentic coding":
   verifiers are the mechanism that checks a model's output/action against
   policy before it lands. Frame verifiers explicitly as **a type of
   guardrail** — ties directly into `deterministic-vs-llm.j2`'s "two kinds of
   guardrail" framing (rules vs. models) already in the deck. Verifiers are
   presumably deterministic-side.

2. **The highway vs. monorail analogy.** Core visual metaphor Jon wants:
   - A **highway guardrail** keeps a (human-driven, general-purpose) car from
     leaving the road, but the car still has full freedom of speed, lane,
     route within those limits.
   - **Disney's monorail** is a guardrail taken to the extreme — a fixed
     track with (his words) "less discretion." Because the vehicle has less
     freedom, it can go much faster, safely.
   - The point: **more constraint → more speed**, but only along the one path
     the constraint defines. This is the same "structure enables speed"
     argument already in `modules/guardrails/structure-enables-speed.j2`
     (`structure_is_speed()`, `the_loop()`) — this analogy could either
     *replace*/strengthen that slide's framing, or sit right before/after it
     as the visual hook. Worth deciding whether to merge into that existing
     module or add alongside it.

3. **But — the balance/tradeoff.** Explicit counterpoint Jon wants on the
   record: go too far toward the monorail extreme and you strip out the
   model's creativity and problem-solving ability, which is a genuinely
   positive attribute, not just noise to be constrained away. So this isn't
   "more guardrails = strictly better" — there's a balance point, and the
   talk should name it rather than just asserting structure-is-speed
   uncritically. This is a new nuance not currently in
   `structure-enables-speed.j2`, which currently reads as a fairly one-sided
   "structure is good, full stop" argument — may need a counterpoint
   card/callout added, or a dedicated "how far is too far" beat.

4. **Paved roads.** The resolution to the balance problem: companies set
   guardrails a.k.a. **paved roads** — not a fixed single track (monorail),
   but a road that provides examples and direction *up front*, still leaves
   room to steer. Note: "paved road" already has history in this repo —
   `modules/policy_as_code/paved_road.html` (old revealjs content) and the
   2024 policy-as-code talk's IDEAS.md both used this term/demo. Worth a
   quick look at that old content for language/framing to reuse, even though
   it predates the primitive-native rewrite and won't be reused as markup.

5. **From paved roads → context engineering.** Jon's explicit bridge: paved
   roads lead naturally into the context-engineering material, and "we have
   some slides on this already" — this is Level 1 Crawl in the current deck:
   `context_window_interactive()`, `context_degradation_quality_drop()`,
   `context_files_mockup()`, `context_files_tradeoffs()` (all already wired
   into the content file). So this new thread's likely job is to build the
   *bridge* connecting verifiers/guardrails-as-constraint into the existing
   Level 1 context-files material, rather than writing new context-engineering
   content from scratch.

6. **Citation: "Shrinking the Generation-Verification Gap with Weak
   Verifiers"** — [arxiv.org/abs/2506.18203](https://arxiv.org/abs/2506.18203),
   Saad-Falcon, Buchanan, Chen, Huang, McLaughlin, Bhathal, Zhu, Athiwaratkun,
   Sala, Linderman, Mirhoseini, Ré. Introduces **Weaver**: rather than one
   strong/oracle verifier (perfect but unscalable — e.g. a human, or
   narrowly-useful — e.g. Lean), combine multiple weak, imperfect verifiers.
   Weighted ensembles (accuracy-weighted, estimated via weak supervision to
   avoid needing labeled data) significantly beat unweighted combos and
   single verifiers. Result: an ensemble of 70B-or-smaller judge/reward models
   hit o3-mini-level accuracy (87.7% avg) with Llama 3.3 70B as generator —
   a jump comparable to GPT-4o → o3-mini (69.0% → 86.7%), achieved via
   verification/ensembling instead of expensive finetuning/post-training.

   **Jon's framing of the takeaway** — use the phrase **"ensembling multiple
   fast verifiers"**: many diverse, fast/naive verifiers, each doing one
   small thing well, combined, beats a single bigger/smarter "oracle"
   verifier. The strength is both the speed/performance of each individual
   verifier *and* the fact that they compose well specifically because they
   are naive/narrow. **A human reviewer is explicitly one form of verifier**
   in this framing, not a separate category — worth tying back to
   `agent-review.j2` (`layered_ai_review`) and the existing rules-vs-models
   material, since "verifier" now spans deterministic checks, model-based
   judges, and humans.

   **Load-bearing assumption (Jon flagged this explicitly):** Weaver's gains
   depend on the ensembled verifiers capturing **different, independent
   aspects of correctness**. If the verifiers are redundant/correlated —
   checking the same thing in slightly different ways — ensembling them buys
   little to nothing; the paper's improvement numbers come from diversity of
   signal, not just from having more verifiers or faster ones. Should be
   stated alongside "ensembling multiple fast verifiers" so it isn't
   mis-read as "just add more cheap checks."

   **Evidence image saved:** `img/weaver-weighted-vs-naive-ensembles.png` —
   screenshot of the paper's bar chart "Weighted Verifier Ensembles Outperform
   Naive Verifier Ensembles" (improvement over naive ensemble, % — across
   MATH500, GPQA Diamond, MMLU, MMLU Pro; compares Oracle Unweighted Ensembles
   [Top-1/5/10 Verifiers] against Supervised Weighted Ensembles [Naive Bayes,
   Logistic Regression]). Saved directly from the paper by Jon, not yet wired
   into any slide.

7. **How this closes the argument.** Jon's stated throughline: **paved roads
   start the model on the right path, but you still need verifiers** — and
   this is reinforced by scaling laws (models keep getting better on their
   own) *plus* Weaver's finding (ensembles of fast, imperfect verifiers close
   most of the generation-verification gap without needing an oracle). So the
   conclusion isn't "guardrails forever because models won't improve" — it's
   "guardrails *and* verification remain necessary even as models improve,
   because verification is what turns raw capability into something you can
   trust to ship." This is a stronger/more specific version of the
   maturity-model's Level 4 "Fly" argument already in the deck
   (`ai-coding-maturity.j2` / `structure-enables-speed.j2`'s `the_loop()`) —
   may fold into that close rather than becoming a wholly separate beat.

---

## DECIDED: restructured run of show (Jon, 2026-08-16)

This supersedes the open questions that were here and most of IDEAS.md's
original run of show. The maturity model is no longer the spine of the talk.

- **Opening — KEEP as is.** Title, `coding_agent_evolution()`,
  `why_guardrails()`.
- **Part 1 — KEEP as is.** The delivery lifecycle: `sdlc_stages()`,
  `sdlc_stages_with_controls()`, `sdlc_survey()`.
- **Part 2 — REPLACED.** The four-level maturity model (overview + Levels
  1–3: Crawl/Walk/Run and all their supporting slides — context window,
  degradation, context files, layered AI review, right-context-right-time,
  layered defense, PCI example, hooks, CI/CD enforcement, server-side
  wiring) is **cut for time**. In its place: similar territory but through
  the new angle —
  1. **Guardrails** (highway guardrail → Disney monorail spectrum; the
     balance point — too much constraint kills model creativity)
  2. **Policy as code** (the history: PDP/PIP/PEP/PAP from the CNCF
     Kubernetes Policy Management whitepaper, generic p.6 architecture)
  3. **Paved roads** (the resolution: examples and direction up front,
     still room to steer; bridges to context engineering)
  4. **Verifiers** (verifiers as a type of guardrail; humans as one form
     of verifier)
- **Part 3 — KEEP.** `guardrails_two_kinds()` +
  `guardrails_working_together()` — Jon: "a perfect segue from the
  verifiers conversation," now enriched with the Weaver evidence:
  the ensembling argument, the independence assumption, and the
  `img/weaver-weighted-vs-naive-ensembles.png` chart.
- **Part 4 ("Should you?") — fate not explicitly stated.** Jon didn't
  mention the decision-frame/should-you slides. Given "more slides than
  fewer, I'll trim," keep them wired in for now and let the review pass
  decide.
- **Final part — REWRITTEN FROM SCRATCH, named "Verifier Self-Improvement."**
  Replaces the old Part 5. Covers the Level-4 continuous-improvement
  content, but: **no "Fly" branding, no maturity-level framing at all**
  (levels 1–3 are skipped, so a "Level 4" label would be orphaned).
  Essentially the old Part 5 territory — feedback loops, evidence-driven
  context/guardrail updates, promotion gates — recast as verifiers
  improving themselves/the system. Existing modules
  (`maturity_fly`, `structure_is_speed`, `agent_feedback_loop`,
  `policy_feedback`, `the_loop`) are raw material, not the outline.
- **Close — KEEP.** Questions, thank-you.

**Working principles for the rewrite:**
- Err toward MORE slides, not fewer — Jon will trim in review. Keep
  everything related to the flow; review-and-consolidate comes after.
- The maturity model modules stay in the repo untouched (other decks use
  them); this deck just stops calling most of them.

**Remaining smaller open questions (carried forward):**
- Is "paved road" a named concept slide or connective narration? (Now
  leaning slide, since it's one of the four beats of new Part 2.)
- Weaver material: own slide vs. callout — now clearly at least one slide
  in Part 3, given it carries the evidence image.
- Whether any of the cut Level 1–3 supporting slides (esp. context files,
  layered review) get pulled into new Part 2's paved-roads/context bridge
  rather than dropped entirely.

---
