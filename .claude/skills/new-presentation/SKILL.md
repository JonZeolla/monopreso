---
name: new-presentation
description: Scaffold and author a new presentation deck in the monopreso repo — creates the deck directory, wires the modern engine and brand pack, plans the run of show, and writes slides on top of shared topic modules and brand primitives. Use this whenever the user wants to add, start, build, or draft a talk, deck, presentation, webcast, webinar, keynote, workshop, or conference session in this repo, including when they only mention an event and a date ("I'm speaking at BSides in November", "SANS asked me to do a 60-minute session", "need a deck for the CSE summit"), when they ask to copy or adapt an existing deck for a new venue, or when they ask where slide content should live. Also use it when adding a new shared slide module under modules/<topic>/ or a new brand pack under modules/branding/, since those follow the same primitive contract.
---

# Building a new presentation

This repo renders decks from Jinja templates. A deck is **not** a pile of HTML — it is a
thin orchestration file that picks a brand and calls shared slide macros in order.
Getting that separation right is the whole job; everything below serves it.

Read `AGENTS.md` at the repo root first. It is the authoritative contract. This skill
tells you how to *apply* it when starting from nothing.

## The one idea that matters

Every slide splits into two halves that live in different places:

- **WHAT** — the content and structure of the slide. Lives in `modules/<topic>/<slide>.j2`.
- **HOW** — what it looks like. Lives in `modules/branding/<brand>/primitives.j2`.

A shared slide describes *"compare these benefits against these shortcomings"*. The brand
pack decides that benefits are teal cards on the left. The seam between them is the
**primitive contract** — a fixed set of macro names and signatures that every brand pack
implements identically.

The payoff is that the same talk re-renders for a different audience by changing one line
in a `Taskfile.yml`. That only holds if shared slides never mention a color, a class name,
or a pixel value. The moment one does, the deck is welded to a brand and the abstraction
is dead weight.

**Write shared slides against primitives. If a primitive is missing, build it in all three
brand packs before you write the slide.** That rule is the point of the architecture, and
it is the rule this repo has been failing to follow — see "Current reality" below, because
you will be working alongside a lot of code that predates it.

## Workflow

### 1. Establish the deck facts

A deck is a commitment to a specific room on a specific day, and almost every later
decision — how many slides, how much background to assume, which brand — follows from
facts about that engagement rather than from the topic. Collect them before creating
anything, and ask for whatever the user hasn't volunteered:

| Fact | Why it changes the deck |
|---|---|
| **Event name** | Goes on the cover and in SOURCES.md; determines house expectations |
| **Date** | Sets the `YYYY-MM-` folder prefix. Use the *event* date, not today |
| **Location** | In-person vs remote changes pacing, and the city belongs in IDEAS.md |
| **Title** | The cover slide. Get the exact submitted title if there is one |
| **Abstract** | The promise made to attendees — the deck must deliver on it. Goes in ABSTRACT.md |
| **Duration** | Drives the run of show. ~60–90 seconds per content slide |
| **Audience** | Practitioners vs leadership decides how much you must explain from scratch |
| **Format** | In-person / virtual / hybrid |

If a submitted abstract exists, treat it as a specification: every claim it makes needs a
slide behind it, and material that serves none of its claims is a candidate to cut.

Pass what you have to the scaffold script so it lands in the files rather than being
retyped later. Brand picks itself in practice:
- `zenable` — Jon's own material, company-affiliated talks. The usual default.
- `sans-cloud` — anything under SANS Cloud Security (webcasts, summits, SANS@Night).
- `unbranded` — talks that should carry no employer or sponsor branding.

Folder name is `YYYY-MM-<slug>`, where the slug identifies the venue and topic:
`2026-08-sans-cse-guardrails-ai-coding`, `2026-06-coding-guardrails`. Match the date to
the event, not to today.

### 2. Scaffold

```bash
.claude/skills/new-presentation/scripts/scaffold_deck.sh \
  --folder=2026-11-bsides-pgh-agent-security \
  --title="Agent Security" \
  --event="BSides Pittsburgh" \
  --date="November 14, 2026" \
  --location="Pittsburgh, PA" \
  --duration=45 \
  --audience="security practitioners and engineers" \
  --brand=zenable
```

This creates the deck directory with the content file, `Taskfile.yml`, `IDEAS.md`,
`ABSTRACT.md`, `SOURCES.md`, and `img/`, with the engagement facts already filled in.
Everything except `--folder` and `--title` is optional and leaves a TODO if omitted.

Both presentation styles in this repo are called by their engine name — **modern** (the
default: one scroll-snap page, brand packs, what you are building) and **revealjs** (the
legacy discrete-slide decks). Say which one you are using when you report back, since the
repo contains far more revealjs decks than modern ones and the two share no markup.

Do **not** use the repo's root `./create.sh` for a modern deck. It scaffolds the legacy
revealjs layout (`<deck>_content.j2` from `modules/template_content.j2`) and will send you
down the wrong engine.

`references/anatomy.md` explains what each generated file is for and how `start.sh` turns
them into a page. Read it if a render misbehaves or you need to understand the pipeline.

### 3. Plan the run of show before writing slides

Write `IDEAS.md` first: the narrative spine, then a minute-by-minute breakdown that sums
to the session length. Roughly 60–90 seconds per content slide is a realistic pace for
this deck style.

This is worth doing before touching a `.j2` file because the structure determines how much
you can reuse. A talk organized as four cumulative maturity levels needs a different
divider treatment than one organized as three independent themes, and you want to know
that before you have twenty slides to restructure.

Then survey what already exists:

```bash
ls modules/*/
grep -rn "^{%- macro" modules/{context,agents,hooks,guardrails,ci-cd,outro}/*.j2
```

Most of a new deck on a familiar topic is existing macros in a new order. Reuse
aggressively — that is what the topic modules are for.

### 4. Write the content file as pure orchestration

The deck file imports and calls. It contains no HTML beyond section comments.

```jinja
{%- include "modules/branding/" ~ branding ~ "/theme.html.j2" %}
{%- from "modules/branding/" ~ branding ~ "/primitives.j2" import
    title_slide, section_divider %}

{%- from "modules/context/context-files.j2" import
    mockup as context_files_mockup,
    tradeoffs as context_files_tradeoffs %}
{%- from "modules/outro/outro.j2" import questions, thank_you %}

{{ title_slide("Agent Security", kicker="Jon Zeolla") }}
{{ section_divider(1, "Context") }}
{{ context_files_mockup() }}
{{ context_files_tradeoffs() }}
{{ questions() }}
{{ thank_you(name="Jon Zeolla", linkedin_url="linkedin.com/in/jonzeolla") }}
```

`branding` is a Jinja variable supplied by `start.sh`. Never hardcode a brand name in the
content file — that is what breaks brand swapping.

Alias imports to a topic-prefixed name (`mockup as context_files_mockup`). Bare `mockup`
collides the moment a second module exports something similar, and the resulting Jinja
error points at the call site rather than the import.

### 5. Write new shared slides against primitives

New content goes in `modules/<topic>/<name>.j2` as a macro, never inline in the deck. Even
if you are certain only one talk will use it — the cost of extracting later is much higher
than the cost of putting it in the right place now.

The available primitives and their exact signatures are in `references/primitives.md`.
Read it before writing a slide; guessing a signature wastes a render cycle.

**A slide module that uses primitives must be imported `with context`:**

```jinja
{%- from "modules/context/context-files.j2" import tradeoffs with context %}
```

Without it, `branding` is undefined when the module loads, the brand path collapses, and
you get `TemplateNotFound: 'modules/branding//primitives.j2'` — note the empty segment.
This bites every primitives-based slide and nothing else in the repo, so it looks like a
mysterious path bug the first time. `references/primitives.md` explains the mechanics.

The rule, restated because it is the one that gets broken: **a file under `modules/<topic>/`
must not contain a hex color, a brand class name (`vis-*`, `unb-*`, `zenable-*`), or a
brand-specific font.** If you are typing `#2dd4bf` into a shared slide, stop — that value
belongs in a brand pack.

**When no primitive fits**, you have found real work, not an excuse to hand-roll HTML.
Four primitives are declared in the AGENTS.md contract but exist only as comments at the
bottom of each pack: `code_block`, `step_flow`, `pipe`, `ide_mockup`. Several existing
slides hand-roll exactly these shapes, which is why they are stuck to one brand.

To add or implement a primitive:

1. Implement it in **all three** packs — `sans-cloud`, `zenable`, `unbranded`. A primitive
   present in two packs is worse than none, because it makes a deck silently degrade
   under the third rather than fail loudly.
2. Match each pack's idiom: `sans-cloud` uses `vis-*` CSS classes, `zenable` uses Tailwind
   utilities, `unbranded` uses `--unb-*` CSS variables.
3. Map the `accent` parameter through the pack's existing accent helper rather than
   inventing colors. The vocabulary is `primary`, `secondary`, `success`, `warning`,
   `danger`, `info`, `neutral`.
4. Update the primitive table in `AGENTS.md` and remove it from the "not yet implemented"
   list, including the comment block at the bottom of each pack.

Then write the slide. Skipping to step 4 with only one pack implemented is how the current
inconsistency happened.

### 6. Verify it renders — in every brand

```bash
cd presentations/<deck> && task start
```

Requires Docker (Tailwind compile + local server). Serves on `http://localhost:8000`;
`task stop` when done.

A deck that renders under its default brand proves very little. The claim you are actually
making is that content and brand are separable, so check it:

```bash
BRANDING=unbranded task start
```

`unbranded` is the honest test. It has no compatibility shim, so any brand leak shows up
immediately as unstyled or collapsed markup. If the deck looks broken there, a shared
slide is emitting brand-specific markup — find it and push that markup down into the
packs.

### 7. Update AGENTS.md

`AGENTS.md` is the contract other agents read. Leaving it stale means the next agent
guesses wrong. Update it when you:

- add a slide module to a topic dir, or create a new topic dir (the topic table)
- add or implement a primitive (the primitive table and the not-implemented list)
- change what the migration state says is done

## Current reality — read before you pattern-match on existing code

The architecture above is what the repo is moving toward. What you will actually find:

- All three packs implement 8 primitives (`title_slide`, `section_divider`, `slide_heading`,
  `callout`, `card`, `card_grid`, `pros_cons`, `pill_row`). This code is real and working.
- **Zero of the ~18 shared slide modules call any of them.** Every one emits `vis-*`
  classes and inline hex directly.
- The Zenable pack renders those slides by including the sans-cloud stylesheet and
  overriding tokens with `!important` (`modules/branding/zenable/theme.html.j2`). It is an
  interim shim, not the design. `unbranded` has no equivalent, which is why it is the
  useful test in step 6.

So the existing modules are **not** the example to copy. They are the backlog. When you
touch one for other reasons, migrating it to primitives is welcome; when you write a new
one, write it correctly from the start.

Two known gaps you may hit:

- **No slide-wrapper primitive.** `slide_heading()` emits bare `<div>`s — the enclosing
  `<section class="vis-slide">` is brand-specific but no primitive owns it. Writing a
  primitives-only content slide today still forces a hardcoded section class. The fix is a
  `content_slide(label)` call-block primitive in each pack; see `references/primitives.md`
  for the shape. Adding it is in scope when you need it.
- **`<deck>_title.j2` is dead on the modern engine.** `start.sh` renders the page title
  from the folder name. Decks still ship the file for revealjs-era consistency; the
  scaffold script omits it. Don't wire anything to it.
