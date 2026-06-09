# SANS Cloud Security shared module (modern engine)

Reusable theme + intro/outro partials for SANS Cloud Security webcasts on the
modern engine. Drop these into a presentation's `_modern_content.j2` to get the
matching look-and-feel (header bar, theme toggle, light/dark, title slide, etc.)
without copying ~500 lines of CSS or hand-rolling each event's intro/outro.

## Usage

In your `presentations/<slug>/<slug>_modern_content.j2`:

```jinja
{# ── SANS shared variables ───────────────────────────────────── #}
{% set sans_title    = "AI-Driven DevSecOps" %}
{% set sans_subtitle = "Agentic Code Review in GitLab & GitHub" %}
{% set sans_speaker  = "Jon Zeolla" %}
{% set sans_speaker_linkedin   = "linkedin.com/in/jonzeolla/" %}
{% set sans_speaker_logo_url   = "https://zenable.io" %}
{% set sans_speaker_logo_dark  = "presentations/<slug>/img/zenable.svg" %}
{% set sans_speaker_logo_light = "presentations/<slug>/img/zenable-dark.svg" %}
{% set sans_speaker_tagline    = "Governance, Guardrails, and Observability<br>for coding agents like Claude Code, Cursor, VS Code, and more" %}
{% set sans_speaker_roles      = [
  "SANS Instructor — SEC540 & SEC545",
  "CNCF Ambassador • BSides Pittsburgh Organizer",
] %}

{% set sans_series_image = "presentations/<slug>/img/AI_DevSecOps_Series.png" %}
{% set sans_series_alt   = "5-part AI-Driven DevSecOps series — Part 3: Agentic Code Review …" %}

{% set sans_takeaways_title = "Key Takeaways" %}
{% set sans_takeaways = [
  "First takeaway",
  "Second takeaway",
] %}

{% set sans_course_url     = "sans.org/sec540" %}
{% set sans_course_tagline = "Take a Journey to Become a SANS Cloud Ace" %}
{% set sans_training_events = [
  {"name": "SANS 2026", "location": "Orlando, FL & Virtual",
   "dates": "Sun Mar 29 – Thurs Apr 2, 2026", "instructor": "Eric Johnson"},
] %}

{# ── Theme + chrome (include once, near the top) ─────────────── #}
{% include "modules/branding/sans-cloud/theme.html.j2" %}
{% include "modules/branding/sans-cloud/header.html.j2" %}

{# ── Intro slides ────────────────────────────────────────────── #}
{% include "modules/branding/sans-cloud/title-slide.html.j2" %}
{% include "modules/branding/sans-cloud/speaker-slide.html.j2" %}
{% include "modules/branding/sans-cloud/series-overview-slide.html.j2" %}

{# ── Your event-specific content slides go here ──────────────── #}
<section class="vis-slide" data-label="…">…</section>

{# ── Outro slides ────────────────────────────────────────────── #}
{% include "modules/branding/sans-cloud/takeaways-slide.html.j2" %}
{% include "modules/branding/sans-cloud/end-slide.html.j2" %}
```

## Files

- `theme.html.j2` — full SANS Cloud Security CSS (light/dark, vis-slide system, print styles).
- `header.html.j2` — fixed top header bar with the SANS logo, plus the theme-toggle button.
- `title-slide.html.j2` — orange title slide with the ace background.
- `speaker-slide.html.j2` — dark "about the speaker" slide.
- `series-overview-slide.html.j2` — single-image series-overview slide.
- `takeaways-slide.html.j2` — light "Key Takeaways" `<ol>`.
- `end-slide.html.j2` — dark thank-you slide with course CTA and upcoming training events.
- `img/` — SANS-branded backgrounds and the header logo (used by the partials and theme).

## What stays per-presentation

Speaker logos, event-specific imagery (series overview graphic, content slide
images, promo cards), and all of the deck's middle content slides remain in
`presentations/<slug>/` — the shared module covers chrome and intro/outro only.
