# Agentic AI Foundation (AAIF) brand pack — modern engine

A **light** brand pack matching the official "AAIF Presentation Template"
Google Slides deck and the [aaif.io](https://aaif.io) design system.

Everything else in this repo is a dark deck. This one is white with a
gradient rule; section dividers invert to a full-bleed
`#5765FF → #FF702D`. Content written against a dark pack will need its
colours re-checked before it lands here.

See the pack live:

```bash
cd presentations/aaif-template && task start
```

That deck is the pack's reference gallery — one slide per layout, each
captioned with the macro that renders it. It is also the pack's
regression check: if a primitive breaks, it breaks there first.

---

## Files

| File | What it is |
|---|---|
| `theme.html.j2` | Design tokens, `.aaif-*` CSS, and the engine overrides a light pack needs. Include once, at the top of a deck. |
| `primitives.j2` | The primitive macro contract (see repo-root `AGENTS.md`). |
| `slides.j2` | AAIF-specific layouts lifted from the source deck. Not part of the contract. |
| `logo-sprite.html.j2` | Generated `<symbol>` sprite. Emitted by `theme.html.j2`; you never include it yourself. |
| `img/aaif-logo.svg` | Official lockup, retinted to `currentColor`. |
| `img/aaif-mark.svg` | The dot-grid mark alone, for favicons and tight spaces. |

## Wiring a deck

```jinja
{%- include "modules/branding/" ~ branding ~ "/theme.html.j2" %}
{%- from   "modules/branding/" ~ branding ~ "/primitives.j2"
   import  title_slide, section_divider, card_grid, callout %}
{%- from   "modules/branding/aaif/slides.j2" import content_slide %}

{{ title_slide("My Talk", "A subtitle", kicker="Agentic AI Foundation") }}
{{ section_divider(1, "First act") }}

{% call content_slide("A content slide", "The subtitle", label="Kicker") %}
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

## Design tokens

Colour, type scale, and radii come verbatim from the CSS custom properties
on aaif.io. The gradient and every layout offset come from the source
Slides deck.

| Token | Value | Source |
|---|---|---|
| `--aaif-indigo` | `#5765FF` | Deck gradient start; also the corner decoration |
| `--aaif-coral` | `#FF702D` | Deck gradient end; aaif.io coral |
| `--aaif-gradient` | `linear-gradient(90deg, indigo, coral)` | The brand's one signature move |
| `--aaif-ink` / `--aaif-text` | `#000` / `#4a4a4a` | aaif.io `--color-primary` / `--color-text` |
| `--aaif-font` | Instrument Sans | aaif.io `--font-sans`, loaded from Google Fonts |

Type runs `--aaif-fs-hero` (64px) down to `--aaif-fs-xs` (12px), each with a
matching `--aaif-lh-*`. Coral and neutral ramps are `--aaif-coral-50…700` and
`--aaif-n-50…900`.

### Geometry

The source deck is authored in EMU on a 365760 × 205740 canvas. Every offset
in `theme.html.j2` is that EMU value divided by the canvas dimension, so
proportions match the original rather than being eyeballed:

| Token | Derivation |
|---|---|
| `--aaif-bar-h` | `3672 / 205740` — the gradient rule |
| `--aaif-pad-x` | `19331 / 365760` — content gutter |
| `--aaif-logo-w-cover` | `104672 / 365760` — cover lockup |
| `--aaif-logo-w-foot` | `34509 / 365760` — footer lockup |
| `--aaif-deco-size` | `74561 / 365760`, kept square in `vw` |

### Accents

`primary` indigo · `secondary` coral · `success` green · `warning` amber ·
`danger` red · `info` indigo · `neutral` grey.

Accents render as a 3px left rule on cards, never as a fill. The brand reads
as a line of colour against white. On gradient slides the rule gives way to a
white border, because coloured rules disappear against the gradient anyway.

---

## Slide chrome

`chrome()` in `primitives.j2` emits the gradient rule, corner decoration,
footer lockup, and page number, and every layout calls it — so all four move
together when a token changes. Reach for `content_slide()` rather than a
hand-rolled `<section>`; hand-rolled slides drift out of alignment the first
time an offset moves.

**Page numbers are a CSS counter** on `.aaif-slide`. Nothing to pass in,
nothing to renumber when slides move.

**The logo is a `<symbol>` sprite.** `theme.html.j2` emits the path data once;
slides reference it with `<use href="#aaif-logo">`. Both symbols inherit
`currentColor`, which is what lets identical markup render black on white
slides and white on gradient ones. To regenerate after a brand refresh,
re-download the official SVG and rebuild `logo-sprite.html.j2` from
`img/aaif-logo.svg` — do not hand-edit the sprite.

---

## Two things this pack does not do

**No `vis-*` compatibility layer.** The Zenable pack includes the sans-cloud
CSS framework so that shared slides under `modules/<topic>/` — which still
emit raw `vis-*` markup — render under a second brand. This pack deliberately
does not. Those shared slides will render unstyled here. Only slides written
against these primitives work, which also means this pack is a clean test of
whether the primitive contract is actually sufficient.

**Two primitives are ahead of the other packs.** `code_block()` and
`step_flow()` are implemented here but are still stubs in `sans-cloud`,
`zenable`, and `unbranded`. Use them from AAIF-specific slides only — a shared
slide under `modules/<topic>/` that calls them would break the "same content,
swap brand" guarantee. `pipe()` and `ide_mockup()` remain unimplemented
everywhere.

---

## Brand sources

- Site and design tokens: <https://aaif.io>
- Logo: the official 838×203 lockup from AAIF's CDN, retinted to
  `currentColor` and split into lockup + mark.
- Layouts: "AAIF Presentation Template" (Google Slides).
