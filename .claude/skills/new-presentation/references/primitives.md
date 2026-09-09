# The primitive contract

Every brand pack under `modules/branding/<brand>/primitives.j2` implements these macro
names with these signatures. Shared slides under `modules/<topic>/` call them and nothing
else. `AGENTS.md` at the repo root holds the canonical table; this file adds the calling
detail you need to actually write a slide.

## Contents

- [Importing: the `with context` rule](#importing-the-with-context-rule)
- [Implemented today](#implemented-today)
- [Accent vocabulary](#accent-vocabulary)
- [Which primitives emit a section](#which-primitives-emit-a-section)
- [Declared but not implemented](#declared-but-not-implemented)
- [The missing slide wrapper](#the-missing-slide-wrapper)
- [Implementing a primitive across packs](#implementing-a-primitive-across-packs)

## Importing: the `with context` rule

Read this before writing your first primitives-based slide. It will otherwise cost you a
confusing debugging session.

A shared slide that uses primitives resolves the brand path at load time:

```jinja
{%- from "modules/branding/" ~ branding ~ "/primitives.j2" import pros_cons, callout %}
```

Jinja evaluates that line when the module is imported, and by default an imported template
**does not receive the importing template's context**. So `branding` is undefined, the path
collapses, and you get:

```
TemplateNotFound: 'modules/branding//primitives.j2' not found in search paths
```

The empty segment between the two slashes is the signature of this bug.

The fix is on the **deck's** import of the slide module — it must pass context down:

```jinja
{%- from "modules/context/context-files.j2" import tradeoffs with context %}
```

With that, the module inherits `branding` and its own primitive import resolves normally.

Rules of thumb:

- Any shared slide module that imports primitives must be imported `with context` by
  whatever imports it. That includes module-to-module imports, so the whole chain from the
  deck down has to carry it.
- Modules that emit plain markup and import nothing brand-dependent do not need it. Most
  existing modules are in this category, which is why the repo has never hit this.
- The deck's own `{%- from "modules/branding/" ~ branding ~ "/primitives.j2" import ... %}`
  does not need it — `branding` is already in the deck's own context.

If a deck suddenly fails to render after you migrate a module to primitives, this is
almost always why: the deck is still importing it without context.

## Implemented today

All three packs (`sans-cloud`, `zenable`, `unbranded`) have working implementations.

### `title_slide(title, subtitle="", kicker="")`

Cover slide. Emits a complete `<section>`. `kicker` is the small line above the title —
conventionally the speaker name. `subtitle` renders as the styled sub-line.

```jinja
{{ title_slide("Guardrails for AI Coding", kicker="Jon Zeolla") }}
{{ title_slide("Agent Security", subtitle="What breaks when the reviewer is a robot", kicker="Jon Zeolla") }}
```

### `section_divider(num, title, subtitle="")`

Full-bleed break between sections. Emits a complete `<section>`. Pass `num=None` or `""`
to suppress the number.

```jinja
{{ section_divider(1, "Context", "How agents see your project") }}
{{ section_divider(None, "Intermission") }}
```

### `maturity_level(level, stage, title, subtitle="")`

Break slide for a staged model — renders "Level N: Stage" above the title. Emits a
complete `<section>`. Reach for this only when the deck is genuinely organized as
cumulative levels; otherwise `section_divider` is the right tool.

```jinja
{{ maturity_level(1, "Crawl", "Basic Steering") }}
```

Note: this landed on the `2026-08-cse` branch. Confirm it exists in the pack you are
targeting before calling it — `grep -n "macro maturity_level" modules/branding/*/primitives.j2`.

### `slide_heading(label, title, subtitle="")`

Top-of-slide heading block: kicker, headline, sub. **Emits bare `<div>`s, not a section** —
the caller supplies the surrounding `<section>`. See
[the missing slide wrapper](#the-missing-slide-wrapper) for why that is a problem.

```jinja
{{ slide_heading("Policy-as-Code", "Deterministic Guardrails",
                 "Rules the agent cannot argue with") }}
```

### `callout(text, accent="primary")`

Emphasis band, conventionally the last element in a slide. `text` is passed through
`|safe`, so inline `<strong>` works.

```jinja
{{ callout("A context file that <strong>sounds better</strong> is not evidence
            that the agent <strong>behaves better</strong>.", accent="warning") }}
```

### `card(title, body, accent="neutral")`

One bordered card. `body` is `|safe`. Pass `title=""` for a body-only card.

### `card_grid(items, cols=3)`

Grid of cards. Each item is a dict: `{title, body, accent}`. `detail` is accepted as an
alias for `body`, and `accent` defaults to `neutral` — but be explicit, since a grid where
every card is neutral usually means the slide has no visual hierarchy.

```jinja
{{ card_grid([
     {"title": "Security risk",  "body": "Unsafe defaults propagate quickly.",       "accent": "danger"},
     {"title": "Fragility",      "body": "Locally plausible, globally wrong.",       "accent": "warning"},
     {"title": "Review overload","body": "Human capacity does not scale with output.","accent": "info"},
   ], cols=3) }}
```

### `pros_cons(benefits, shortcomings, ben_label="Benefits", short_label="Shortcomings")`

Two-column ✓ / ✗ comparison. Each item is `{title, detail}`. `detail` is optional and
`|safe`.

```jinja
{{ pros_cons(
     benefits=[
       {"title": "Always loaded", "detail": "No retrieval step to get wrong."},
       {"title": "Reviewable",    "detail": "Lives in Git next to the code."},
     ],
     shortcomings=[
       {"title": "Costs context", "detail": "Every token competes with the actual task."},
       {"title": "Goes stale",    "detail": "Nothing fails when it drifts from reality."},
     ],
     ben_label="What works", short_label="What it costs") }}
```

### `pill_row(items, justify="center")`

Badge row. Each item is `{label, accent}`. `justify` takes any flexbox value —
`center`, `flex-start`, `space-between`.

```jinja
{{ pill_row([{"label": "PCI-DSS", "accent": "danger"},
             {"label": "SOC 2",   "accent": "info"}]) }}
```

## Accent vocabulary

Every `accent` parameter takes exactly these semantic names. Each pack maps them to its
own palette.

`primary` · `secondary` · `success` · `warning` · `danger` · `info` · `neutral`

Shared slides use the semantic name. A hex value in `modules/<topic>/` means the
abstraction has broken — the fix is in the pack, not the slide.

Unrecognized names fall through to neutral silently in every pack, so a typo produces a
bland slide rather than an error. Spell them correctly.

## Which primitives emit a section

This trips people up. The modern engine expects each slide to be a direct
`<section>` child of `.scroll-container`, carrying a `data-label` used for nav dots and
URL hash navigation.

| Primitive | Emits `<section>`? |
|---|---|
| `title_slide` | yes |
| `section_divider` | yes |
| `maturity_level` | yes |
| `slide_heading` | **no** — caller wraps |
| `callout`, `card`, `card_grid`, `pros_cons`, `pill_row` | no — content fragments |

So a content slide is: your own `<section>`, then `slide_heading(...)`, then content
primitives, then usually a `callout`.

## Declared but not implemented

Declared in the AGENTS.md contract, present in each pack only as a comment block:

| Primitive | Shape |
|---|---|
| `code_block(filename, lines)` | Mac-window code card with a filename bar |
| `step_flow(steps)` | Horizontal numbered steps joined by arrows |
| `pipe(stages)` | Pipeline diagram with stage cards |
| `ide_mockup(filename, sidebar, code_lines, chat_panel=None)` | Faux IDE with optional chat panel |

Existing slides hand-roll all four — `modules/context/context-refinement.j2` has a
step flow, `modules/guardrails/deterministic-guardrails.j2` has a code block,
`modules/hooks/hooks.j2` has IDE mockups. Those are the reference look to preserve when
you implement, and the first candidates to migrate afterward.

## The missing slide wrapper

There is no primitive for the slide container itself. A shared content slide today must
write:

```jinja
<section class="vis-slide" data-label="Guardrails">   {# brand leak #}
  {{ slide_heading("Policy-as-Code", "Deterministic Guardrails") }}
  ...
</section>
```

`vis-slide` is a sans-cloud class name, hardcoded in a file that is supposed to be
brand-agnostic. Under `unbranded` this section gets no styling at all.

The fix is a call-block primitive in each pack:

```jinja
{%- macro content_slide(label) -%}
<section class="unb-slide" data-label="{{ label }}">
  {{ caller() }}
</section>
{%- endmacro -%}
```

used as:

```jinja
{%- call content_slide("Guardrails") %}
  {{ slide_heading("Policy-as-Code", "Deterministic Guardrails") }}
  {{ card_grid(items) }}
  {{ callout("...", accent="warning") }}
{%- endcall %}
```

Jinja's `{% call %}` passes the block body to the macro as `caller()`. Note that `call`
blocks need the macro imported with context or referenced through the imported namespace —
if you hit a `caller` undefined error, check the import form.

Add this when you need it, following the same all-three-packs rule, and record it in the
AGENTS.md table.

## Implementing a primitive across packs

Each pack has its own idiom — match it rather than importing another pack's approach.

| Pack | Styling mechanism | Accent helper |
|---|---|---|
| `sans-cloud` | `vis-*` CSS classes from its `theme.html.j2` | `_accent_card_class`, `_accent_callout_class`, `_pill_border`, `_pill_text` |
| `zenable` | Tailwind utilities + Zenable tokens | `_accent_to_zen` |
| `unbranded` | `--unb-*` CSS variables | `_accent_class` |

Read all three existing implementations of a nearby primitive before writing a new one —
`card` is the shortest and shows each pack's whole approach in about ten lines.

Checklist:

- [ ] Implemented in `sans-cloud`, `zenable`, and `unbranded`
- [ ] Signature identical in all three, including default values
- [ ] `accent` routed through the pack's accent helper, no literal colors in the macro
- [ ] For `zenable`, confirm the token the helper maps to actually exists in
      `modules/shared/tailwind.config.js`. Tailwind silently generates nothing for an
      undefined color, so a wrong token produces an uncolored element rather than an
      error. `_accent_to_zen` currently maps `warning`/`danger`/`neutral` to `amber`,
      `red`, and `slate`, none of which are defined under the `zenable` palette — so those
      accents are colorless today. Don't copy that pattern; either add the token to the
      config or use a literal Tailwind class.
- [ ] Consistent about whether it emits a `<section>` — and `data-label` set if it does
- [ ] Added to the AGENTS.md primitive table
- [ ] Removed from the "not yet implemented" comment block in all three packs
- [ ] Renders correctly under `BRANDING=unbranded` (no shim to hide mistakes)
