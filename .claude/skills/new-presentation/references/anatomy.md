# Deck anatomy and the render pipeline

What each file in a deck directory is for, and what `start.sh` does with it. Read this
when a render misbehaves or you need to know where a value comes from.

## Contents

- [Deck directory](#deck-directory)
- [Brand resolution](#brand-resolution)
- [The modern render pipeline](#the-modern-render-pipeline)
- [Engine selection](#engine-selection)
- [Slide markup requirements](#slide-markup-requirements)
- [Troubleshooting](#troubleshooting)

## Deck directory

```
presentations/2026-11-example/
├── 2026-11-example_modern_content.j2   # the deck — orchestration only
├── Taskfile.yml                        # default brand for this deck
├── IDEAS.md                            # narrative + run of show (working doc)
├── ABSTRACT.md                         # published abstract / CFP submission
├── SOURCES.md                          # citations and asset attribution
└── img/                                # deck-specific images
```

### `<deck>_modern_content.j2`

The only required file. Imports the brand theme and primitives, imports shared slide
macros, calls them in order. `start.sh` finds it by the exact filename
`<PRESENTATION>_modern_content.j2`, where `<PRESENTATION>` is the deck folder name — so
folder name and file prefix must match.

### `Taskfile.yml`

Sets the deck's default brand and re-exports the root tasks so `task start` works from
inside the deck directory.

```yaml
env:
  BRANDING:
    sh: echo "${BRANDING:-zenable}"
```

The `sh:` form matters. A bare `BRANDING: zenable` would clobber the value the user set in
their shell, making `BRANDING=sans-cloud task start` silently do the wrong thing.

### `IDEAS.md`, `ABSTRACT.md`, `SOURCES.md`

Not rendered — working documents that keep the deck reviewable.

`IDEAS.md` holds the narrative spine and a minute-by-minute run of show. `ABSTRACT.md`
holds the published abstract. `SOURCES.md` matters more than it looks: decks cite papers
and copy figures from other repos, and attribution needs to survive past the moment you
remember where the image came from. Record the source URL and license for every borrowed
asset as you add it.

### `<deck>_title.j2` — legacy, skip it

A revealjs-era artifact. The modern engine never reads it: `start.sh` renders the page
title from the folder name (`main.render(title='${PRESENTATION}', ...)`). Existing decks
still carry one out of habit. Don't create it and don't wire anything to it.

## Brand resolution

Highest priority wins:

1. `./start.sh --branding=<name>` — CLI flag
2. `BRANDING=<name>` — shell environment variable
3. The deck's `Taskfile.yml` `env:` block
4. Engine default — modern → `unbranded`, revealjs → none

For the modern engine the resolved name is validated against `modules/branding/<name>/`
existing, then passed into Jinja as the variable `branding`. That is why deck files write
`"modules/branding/" ~ branding ~ "/theme.html.j2"` rather than a literal path.

For revealjs the allowlist is `seiso` or `zenable` only.

## The modern render pipeline

`start.sh` with `--engine=modern` (the default):

1. **Render Jinja.** The content file is rendered with `branding` set; the result is
   injected into `modules/shared/modern_template.j2`, which supplies the scroll container,
   nav dots, keyboard handling, and print styles. Jinja's search path is `.`,
   `modules/shared/`, and `modules/shared/components/` — so `{% from %}` paths for slide
   modules are written repo-relative (`modules/context/context-files.j2`).
2. **Compile Tailwind** from `modules/shared/css/modern-input.css` using
   `modules/shared/tailwind.config.js`, into `modules/shared/css/modern.css`. That output
   is regenerated on every render and must never be committed.
3. **Build and run** a container serving the repo, then wait for
   `http://localhost:8000/current.html`.

Steps 2 and 3 need Docker running.

`task stop` stops the server; `task clean` clears rendered artifacts.

## Engine selection

| Engine | Flag | Content file | Wrapper |
|---|---|---|---|
| modern | default | `<deck>_modern_content.j2` | `modules/shared/modern_template.j2` |
| revealjs | `--engine=revealjs` | `<deck>_content.j2` | `modules/shared/template.j2` |

If you ask for modern and only `_content.j2` exists, `start.sh` warns and silently falls
back to revealjs. A deck that renders with unexpected styling is often this — check the
warning line in the output.

**All new work is modern.** Revealjs decks are frozen; touch them to fix things, not to
add capability. The brand-pack architecture is modern-only by deliberate choice — carrying
every primitive across two engines was judged not worth it for legacy decks.

## Slide markup requirements

The modern engine is one scroll-snap page. There is no reveal.js fragment or transition
system — no `data-fragment`, no per-slide transitions.

Each slide must be a direct `<section>` child of `.scroll-container`. Nav dots and URL
hash navigation are generated from each section's `data-label`, so every slide needs one;
without it the dot falls back to `Slide N` and the hash link is useless.

Slide-scoped `<style>` and `<script>` inside a section do work — the 2026-06 deck has an
animated divider built that way. Keep such effects inside the slide's own macro rather
than in the deck file, so the deck stays pure orchestration.

## Troubleshooting

**Deck renders unstyled or collapsed under a brand.** A shared slide is emitting
brand-specific markup. Most likely a hardcoded `vis-slide` section class or inline hex.
`unbranded` exposes this fastest since it has no compatibility shim.

**`TemplateNotFound: 'modules/branding//primitives.j2'`.** The empty path segment means
`branding` was undefined when a shared slide module loaded. Import that module
`with context` from the deck. See `references/primitives.md`.

**`UndefinedError` on a macro name.** Either the import alias doesn't match the call, or
the primitive isn't implemented in the selected pack. Check:
`grep -n "macro <name>" modules/branding/*/primitives.j2` — if it appears in fewer than
three packs, that is the bug.

**Deck not found by `start.sh`.** The folder name and the `<deck>_modern_content.j2`
prefix must match exactly. `./start.sh --list` shows what it can see.

**Styling looks like a different deck's.** Check for the revealjs fallback warning; a
missing `_modern_content.j2` sends you to the other engine.
