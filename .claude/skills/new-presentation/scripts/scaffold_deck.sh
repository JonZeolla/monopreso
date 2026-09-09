#!/usr/bin/env bash
#
# Scaffold a new modern-engine presentation deck.
#
# The repo's root ./create.sh scaffolds the legacy revealjs layout
# (<deck>_content.j2 copied from modules/template_content.j2). This creates the
# modern-engine layout instead: a thin orchestration content file, a per-deck
# Taskfile that sets the default brand, and the working documents.
#
# Usage:
#   scaffold_deck.sh --folder=2026-11-bsides-pgh-agents \
#                    --title="Agent Security" \
#                    [--brand=zenable] \
#                    [--speaker="Jon Zeolla"] \
#                    [--dry-run]

set -o errexit
set -o nounset
set -o pipefail

FOLDER=""
TITLE=""
BRAND="zenable"
SPEAKER="Jon Zeolla"
EVENT=""
DATE=""
LOCATION=""
DURATION=""
AUDIENCE=""
FORMAT=""
DRY_RUN="false"

usage() {
  cat >&2 <<'EOF'
Usage: scaffold_deck.sh --folder=YYYY-MM-slug --title="Talk Title" [options]

Required:
  --folder=NAME     Deck directory name under presentations/. Convention is
                    YYYY-MM-<venue-topic>, dated to the event.
  --title=TITLE     Talk title as it appears on the cover slide.

Engagement facts — each one omitted leaves a TODO in the generated files:
  --event=NAME      Event or conference name.
  --date=DATE       Event date, e.g. "September 8, 2026".
  --location=PLACE  City / venue, or "Virtual".
  --duration=MIN    Slot length in minutes. Drives the run of show.
  --audience=DESC   Who is in the room.
  --format=DESC     in-person / virtual / hybrid.

Other:
  --brand=NAME      Default brand pack (default: zenable). Must exist under
                    modules/branding/.
  --speaker=NAME    Cover slide kicker and outro name (default: Jon Zeolla).
  --dry-run         Print what would be created, create nothing.
EOF
  exit "${1:-64}"
}

for arg in "$@"; do
  case "${arg}" in
    --folder=*)   FOLDER="${arg#*=}" ;;
    --title=*)    TITLE="${arg#*=}" ;;
    --brand=*)    BRAND="${arg#*=}" ;;
    --speaker=*)  SPEAKER="${arg#*=}" ;;
    --event=*)    EVENT="${arg#*=}" ;;
    --date=*)     DATE="${arg#*=}" ;;
    --location=*) LOCATION="${arg#*=}" ;;
    --duration=*) DURATION="${arg#*=}" ;;
    --audience=*) AUDIENCE="${arg#*=}" ;;
    --format=*)   FORMAT="${arg#*=}" ;;
    --dry-run)    DRY_RUN="true" ;;
    -h|--help)    usage 0 ;;
    *) echo "ERROR: unrecognized argument: ${arg}" >&2; usage ;;
  esac
done

# Anything the caller left out becomes a visible TODO rather than a silent blank,
# so a half-specified deck is obvious on sight instead of shipping with gaps.
EVENT="${EVENT:-TODO}"
DATE="${DATE:-TODO}"
LOCATION="${LOCATION:-TODO}"
AUDIENCE="${AUDIENCE:-TODO}"
FORMAT="${FORMAT:-TODO (in-person / virtual / hybrid)}"
if [[ -n "${DURATION}" ]]; then
  DURATION_LINE="${DURATION} minutes"
else
  DURATION_LINE="TODO"
fi

[[ -n "${FOLDER}" ]] || { echo "ERROR: --folder is required" >&2; usage; }
[[ -n "${TITLE}" ]]  || { echo "ERROR: --title is required" >&2; usage; }

# Resolve the repo root from this script's location so it works from any cwd.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

if [[ ! -d "${REPO_ROOT}/presentations" || ! -f "${REPO_ROOT}/start.sh" ]]; then
  echo "ERROR: could not locate the monopreso repo root (looked at ${REPO_ROOT})" >&2
  exit 1
fi

if [[ ! -d "${REPO_ROOT}/modules/branding/${BRAND}" ]]; then
  echo "ERROR: brand '${BRAND}' not found. Available:" >&2
  ls -1 "${REPO_ROOT}/modules/branding/" | sed 's/^/  /' >&2
  exit 1
fi

# The folder name is also the content-file prefix start.sh searches for, so a
# name with spaces or a mismatched prefix silently makes the deck unfindable.
if [[ ! "${FOLDER}" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "ERROR: --folder must contain only letters, digits, dot, dash, underscore" >&2
  exit 1
fi

if [[ ! "${FOLDER}" =~ ^[0-9]{4}-[0-9]{2}- ]]; then
  echo "WARNING: '${FOLDER}' does not match the YYYY-MM-<slug> convention." >&2
fi

DECK_DIR="${REPO_ROOT}/presentations/${FOLDER}"

if [[ -e "${DECK_DIR}" && "${DRY_RUN}" != "true" ]]; then
  echo "ERROR: ${DECK_DIR} already exists — refusing to overwrite." >&2
  exit 1
fi

if [[ "${DRY_RUN}" == "true" ]]; then
  cat <<EOF
Would create ${DECK_DIR}/
  ${FOLDER}_modern_content.j2
  Taskfile.yml            (default brand: ${BRAND})
  IDEAS.md
  ABSTRACT.md
  SOURCES.md
  img/
Title:   ${TITLE}
Speaker: ${SPEAKER}
EOF
  exit 0
fi

mkdir -p "${DECK_DIR}/img"

cat > "${DECK_DIR}/${FOLDER}_modern_content.j2" <<EOF
{# ================================================================
   ${TITLE}
   ${EVENT} · ${DATE} · ${LOCATION} · ${DURATION_LINE}

   Modern-engine orchestration layer. This file chooses the brand and
   the slide order; it contains no HTML. Every rendered slide comes
   from a macro under modules/<topic>/ so other decks can reuse it.
   See AGENTS.md for the primitive contract.
   ================================================================ #}

{# ── Brand pack, resolved by start.sh into \`branding\` ──────────── #}
{%- include "modules/branding/" ~ branding ~ "/theme.html.j2" %}
{%- from "modules/branding/" ~ branding ~ "/primitives.j2" import
    title_slide,
    section_divider %}

{# ── Shared slide content ─────────────────────────────────────── #}
{# Alias imports by topic to avoid collisions as the deck grows.
   Survey what already exists before writing anything new:
     grep -rn "^{%- macro" modules/*/*.j2

   Any module that itself imports brand primitives MUST be imported
   "with context", or \`branding\` is undefined when it loads and you get
   TemplateNotFound: 'modules/branding//primitives.j2'. e.g.
     {%- from "modules/context/context-files.j2" import tradeoffs with context %} #}
{%- from "modules/outro/outro.j2" import questions, thank_you %}


<!-- ================================================================
     OPENING
     ================================================================ -->
{{ title_slide("${TITLE}", kicker="${SPEAKER}") }}


<!-- ================================================================
     SECTION 1 — TODO
     ================================================================ -->
{{ section_divider(1, "TODO") }}


<!-- ================================================================
     CLOSE
     ================================================================ -->
{{ questions() }}
{{ thank_you(name="${SPEAKER}", linkedin_url="linkedin.com/in/jonzeolla") }}
EOF

cat > "${DECK_DIR}/Taskfile.yml" <<EOF
---
# Per-presentation Taskfile, picked up when \`task start\` runs from this
# directory. Sets this deck's default brand; the root Taskfile is included so
# stop / clean / generate-pdf still work.
#
# Override the brand:
#   BRANDING=unbranded task start        # via env (useful for spotting brand leaks)
#   task start -- --branding=sans-cloud  # via CLI flag, wins over env

version: '3'

set:
  - nounset
  - errexit
  - pipefail

silent: true

includes:
  root:
    taskfile: ../../Taskfile.yml
    dir: ../..

env:
  # The sh: form is required so a BRANDING already set in the shell wins.
  # A bare "BRANDING: ${BRAND}" would clobber it.
  BRANDING:
    sh: echo "\${BRANDING:-${BRAND}}"

tasks:
  default:
    deps: [start]

  start:
    desc: "Start ${TITLE} (default brand: ${BRAND})"
    cmds:
      - task: root:start
EOF

cat > "${DECK_DIR}/IDEAS.md" <<EOF
# ${TITLE}

- **Event:** ${EVENT}
- **Date:** ${DATE}
- **Location:** ${LOCATION}
- **Duration:** ${DURATION_LINE}
- **Format:** ${FORMAT}
- **Audience:** ${AUDIENCE}

## Narrative

TODO — the spine of the talk in a few sentences. What is the one idea someone
should leave with, and what has to be true for them to accept it?

## Run of show

Budget roughly 60–90 seconds per content slide, and make the minutes add up to
the session length before writing any slides — the structure determines how much
existing material you can reuse.

- 0–TODO min: framing
- TODO: ...
- Last 5 min: takeaways and questions

## Slides to reuse

Survey first, write second:

    ls modules/*/
    grep -rn "^{%- macro" modules/*/*.j2

- TODO

## Slides to write

New content belongs in modules/<topic>/<name>.j2 as a macro, built from brand
primitives. If a primitive is missing, implement it in all three brand packs
before writing the slide — see .claude/skills/new-presentation/references/primitives.md.

- TODO
EOF

cat > "${DECK_DIR}/ABSTRACT.md" <<EOF
# ${TITLE}

**${EVENT}** · ${DATE} · ${LOCATION}

TODO — the published abstract, as submitted to the event.

Treat this as a specification: every claim made here needs a slide behind it,
and deck material that serves none of these claims is a candidate to cut.
EOF

cat > "${DECK_DIR}/SOURCES.md" <<EOF
# Sources and asset attribution

Record the origin and license of every borrowed figure, quote, and statistic as
you add it. Reconstructing attribution later is far harder than capturing it now.

- Event: ${EVENT} — TODO (link)
- TODO
EOF

cat <<EOF
Created presentations/${FOLDER}/
  ${FOLDER}_modern_content.j2
  Taskfile.yml            (default brand: ${BRAND})
  IDEAS.md  ABSTRACT.md  SOURCES.md
  img/

Next:
  1. Fill in IDEAS.md — narrative and run of show — before writing slides.
  2. Survey reusable macros:  grep -rn "^{%- macro" modules/*/*.j2
  3. Render:                  cd presentations/${FOLDER} && task start
  4. Check for brand leaks:   BRANDING=unbranded task start
EOF
