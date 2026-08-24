# Agentic AI Foundation (AAIF) brand pack — modern engine

A **light, warm** brand pack rebuilt slide-for-slide from the official
"AAIF Presentation Template" Google Slides deck (`Slides.pptx`, 23 slides)
and the [aaif.io](https://aaif.io) design system.

Everything else in this repo is a dark deck. This one is cream `#F6F5F1`
with black type, hairline rules, and exactly one accent — the chapter
green `#14964A`. Content written against a dark pack will need its colours
re-checked before it lands here.

See the pack live:

```bash
cd presentations/aaif-template && task start
```

That deck reproduces all 23 source slides with the same copy, in the same
order, using only this pack's macros. Keeping the sample text identical to
the original is deliberate: it makes the two decks diffable side by side,
which is how the pack stays aligned. It doubles as the regression check —
if a primitive breaks, it breaks there first.

---

## Files

| File | What it is |
|---|---|
| `theme.html.j2` | Design tokens, `.aaif-*` CSS, the 16:9 stage, and the engine overrides a light pack needs. Include once, at the top of a deck. |
| `primitives.j2` | The primitive macro contract (see repo-root `AGENTS.md`), plus `chrome()`, `cover_logo()` and `avatar()`. |
| `slides.j2` | The source deck's own layouts. Not part of the contract. |
| `logo-sprite.html.j2` | Generated `<symbol>` sprite. Emitted by `theme.html.j2`; you never include it yourself. |
| `img/aaif-logo.svg` | Official lockup, retinted to `currentColor`. |
| `img/aaif-mark.svg` | The dot-grid mark alone — what the slide chrome actually uses. |

## Wiring a deck

```jinja
{%- include "modules/branding/" ~ branding ~ "/theme.html.j2" %}
{%- from   "modules/branding/" ~ branding ~ "/primitives.j2"
   import  section_divider, card_grid, callout %}
{%- from   "modules/branding/aaif/slides.j2"
   import  event_cover, content_slide, timeline_slide %}

{{ event_cover("Agentic AI Night.",
     subtitle="Launch Series · Pittsburgh",
     kicker="AAIF Community Events",
     meta="TUE · JUNE 24, 2026 · 17:30 — LATE",
     eyebrow="PITTSBURGH · CHAPTER",
     hosts=["Host Venue Co."], with_label="With",
     members=["Member logo"]) }}

{{ section_divider(1, "Agents in production.",
     label="Tonight's theme", eyebrow="03 · TONIGHT'S THEME") }}

{% call content_slide("A content slide", label="Kicker",
                      eyebrow="04 · SECTION") %}
  {{ card_grid(items, cols=3) }}
{% endcall %}
```

Set the deck's default brand in its `Taskfile.yml`:

```yaml
env:
  BRANDING:
    sh: echo "${BRANDING:-aaif}"
```

Never hardcode `"aaif"` in the include path — `start.sh` supplies `branding`
so the CLI flag and env var keep working.

---

## Layouts

`primitives.j2` — the cross-brand contract:

| Macro | Source slide |
|---|---|
| `title_slide()` | p1, minus the logo-slot row |
| `section_divider(num, title, subtitle, label, eyebrow, footnote)` | p6 / p9 / p16 — the oversized numeral |
| `maturity_level()` | p6, relabelled "Level N · Stage" |
| `slide_heading()` / `callout()` / `card()` / `card_grid()` / `pros_cons()` / `pill_row()` / `code_block()` / `step_flow()` | not in the source deck; rendered in its hairline register |

`slides.j2` — the source deck's own layouts:

| Macro | Source slide |
|---|---|
| `event_cover()` | p1 · cover with host / member logo slots |
| `welcome_slide()` | p2 · doors-open, speakers + host chips |
| `facts_slide()` | p3 · prose left, big-number rail right |
| `stat_band()` | p4 · three headline words + captions |
| `media_slide()` | p5 · title, stat rail, framed media |
| `agenda_slide()` | p7 · numbered run-of-show columns |
| `speakers_slide()` | p8 · three speaker cards |
| `talk_slide()` | p9 · numeral + pull-quote + speaker |
| `feature_slide()` | p10 / p14 / p15 · full-bleed statement, any tone |
| `lineup_slide()` | p11 · numbered rows, person + quote |
| `thanks_slide()` | p12 · host + member wall |
| `join_slide()` | p13 · links + QR, dark |
| `chapter_cover()` | p17 · one word, nothing else |
| `table_slide()` | p18 · run-of-show table |
| `columns_slide()` | p19 · two-column prose |
| `quote_slide()` | p20 · pull quote + attribution |
| `stat_callouts()` | p21 · three big numbers |
| `chart_slide()` | p22 · bar chart |
| `timeline_slide()` | p23 · four-stop event timeline |
| `content_slide()` | the workhorse — heading + your body |

`split_slide()`, `statement_slide()`, `stat_row()` and `closing_slide()`
are carried over from the pack's first iteration for decks already written
against it. They are not in the source deck; prefer the layouts above.

Four tones are available wherever a layout takes one: `light` (cream, the
default), `navy` (`#1A2332`, deck p13), `dark` (`#252525`, p14), and
`gradient` (p10 / p15).

---

## Design tokens

| Token | Value | Source |
|---|---|---|
| `--aaif-cream` | `#F6F5F1` | every light slide's background |
| `--aaif-ink` / `--aaif-muted` | `#0A0A0A` / `#4A4A4A` | headings / body copy and chrome |
| `--aaif-rule` / `--aaif-rule-strong` | `#C9C6BF` / `#9A978F` | hairlines and table borders / chips and connectors |
| `--aaif-green` | `#14964A` | the deck's one accent — the "tonight" marker |
| `--aaif-display` | Space Grotesk Bold | headings, numerals, stat values |
| `--aaif-body` | Instrument Sans | body copy, names |
| `--aaif-mono` | JetBrains Mono | every label, eyebrow, footer, and time |

The gradient slides use the deck's own mesh-gradient PNG, downsampled to
320×180 and inlined as a data URI (~10 KB instead of 700 KB). A layered
`radial-gradient` fallback sits underneath it.

### Geometry, and the `--pt` unit

The source canvas is 9144000 × 5143500 EMU — 10 in × 5.625 in, or
720 pt × 405 pt. A point is therefore exactly 1/7.2 of the slide width,
and `--pt` encodes that:

```css
font-size: calc(21 * var(--pt));   /* the deck's sz="2100" */
```

So **copy `sz` values out of the pptx verbatim; do not convert them to px.**
`--pt` is an absolute length, which makes it correct for vertical offsets
too — every `calc(N * var(--pt))` in a layout traces back to a number in
the source file.

Positions are percentages of the slide, also lifted from the source:

| Row | Offset |
|---|---|
| logo mark | `left 5%`, `top 5.33%`, `2.7% × 4.8%` |
| eyebrow (top right) | `right 5%`, `top 4.8%` |
| section eyebrow | `top 15.11%` |
| section title | `top 20.98%` |
| footer hairline | `top 90.31%` |
| footer text / page number | `top 91.73%` |

Blocks also carry `+ 3.6 * var(--pt)` — the 0.05 in top inset Google Slides
applies inside every text box. Without it every line sits one inset high.

### The stage

`.aaif-slide` fills the viewport and paints the background colour.
`.aaif-stage` is a 16:9 box centred inside it and is the actual slide
canvas; `.aaif-canvas` sits inside the stage and is where `--pt` is
defined, because a container query unit resolves against the nearest
*ancestor* container rather than the element carrying `container-type`.

Because the background lives on the outer element, a non-16:9 window shows
no letterboxing — the content box simply stops scaling.

### Accents

`primary` ink · `secondary` green · `success` green · `warning` amber ·
`danger` red · `info` teal · `neutral` hairline grey.

The source deck has no card vocabulary — it is hairlines and type. The
contract's `card`, `callout` and `pill` render in that register: sharp
corners, one hairline, one accent rule.

---

## Slide chrome

`chrome()` in `primitives.j2` emits the logo mark, wordmark, mono eyebrow,
footer hairline, footer link, and page number, and every layout calls it —
so all six move together when a token changes. Reach for `content_slide()`
rather than a hand-rolled `<section>`; hand-rolled slides drift out of
alignment the first time an offset moves.

**Page numbers are a CSS counter** on `.aaif-slide`. Nothing to pass in,
nothing to renumber when slides move. Covers carry `aaif-slide--nonumber`,
which skips the increment the way the source deck leaves p1 and p17
unnumbered. (The source's own numbering has a gap — its p3 reads "03" —
so the gallery's numbers run one behind the original from there on.)

**The logo is a `<symbol>` sprite.** `theme.html.j2` emits the path data
once; slides reference it with `<use href="#aaif-mark">` (chrome) or
`<use href="#aaif-logo">` (the full lockup, on `closing_slide()`). Both
symbols inherit `currentColor`, which is what lets identical markup render
black on cream slides and white on dark ones. To regenerate after a brand
refresh, re-download the official SVG and rebuild `logo-sprite.html.j2`
from `img/aaif-logo.svg` — do not hand-edit the sprite.

**Avatars are drawn in CSS.** The source deck ships raster placeholder
headshots; `avatar(size, photo)` reproduces the silhouette so a deck stays
self-contained, and takes a real image URL when you have one.

---

## Two things this pack does not do

**No `vis-*` compatibility layer.** The Zenable pack includes the
sans-cloud CSS framework so that shared slides under `modules/<topic>/` —
which still emit raw `vis-*` markup — render under a second brand. This
pack deliberately does not. Those shared slides will render unstyled here.
Only slides written against these primitives work, which also makes this
pack a clean test of whether the primitive contract is actually sufficient.

**Two primitives are ahead of the other packs.** `code_block()` and
`step_flow()` are implemented here but are still stubs in `sans-cloud`,
`zenable`, and `unbranded`. Use them from AAIF-specific slides only — a
shared slide under `modules/<topic>/` that calls them would break the
"same content, swap brand" guarantee. `pipe()` and `ide_mockup()` remain
unimplemented everywhere.

---

## Brand sources

- Layouts, geometry, type sizes, and palette: "AAIF Presentation Template"
  (Google Slides / `Slides.pptx`, 23 slides).
- Site and design tokens: <https://aaif.io>
- Logo: the official 838×203 lockup from AAIF's CDN, retinted to
  `currentColor` and split into lockup + mark.
- Fonts: Space Grotesk, Instrument Sans, and JetBrains Mono, all loaded
  from Google Fonts — the same three the source deck embeds.
