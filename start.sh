#!/usr/bin/env bash

set -o errtrace
set -o nounset
set -o errexit
set -o pipefail

# shellcheck disable=SC2034
{
    declare -r FATAL='\033[0;31m'
    declare -r ERROR='\033[0;31m'
    declare -r WARNING='\033[0;33m'
    declare -r INFO='\033[0m'
    declare -r DEFAULT='\033[0m'
}

function help() {
  exitCode="${1:-0}"
  # Purposefully using tabs for the HEREDOC
  cat <<- HEREDOC
		Preferred Usage: ./${0##*/} --preso=PRESENTATION [--list] [--engine=ENGINE] [--branding=BRANDING] [--port=PORT] [--no-open] [--no-cleanup]
		--branding     Override the brand. For modern engine: any directory under modules/branding/
		               (default: "unbranded"). For revealjs engine: seiso or zenable.
		               Also honoured via the BRANDING env var (set per-presentation in a
		               local Taskfile.yml); CLI flag wins over env.
		--engine       Presentation engine: modern (default) or revealjs
		--list         List the available presentations
		--port         Host port to serve on (default: 8000). Also honoured via the PORT env var;
		               CLI flag wins over env.
		--preso        The presentation name i.e. --preso=dev_tls
		--no-open      Don't open the presentation in Chrome automatically
		--port         Serve on this port instead of auto-selecting a free one
		--no-cleanup   Disable the cleanup prompt at the end
		-h|--help      Usage details
	HEREDOC

  exit "${exitCode}"
}

function feedback() {
    color="${1:-DEFAULT}"
    case "${1}" in
        FATAL)
            >&2 echo -e "${!color}${1}:  ${2}${DEFAULT}"
            exit 1
            ;;
        ERROR)
            >&2 echo -e "${!color}${1}:  ${2}${DEFAULT}"
            help 1
            ;;
        WARNING)
            >&2 echo -e "${!color}${1}:  ${2}${DEFAULT}"
            ;;
        *)
            echo -e "${!color}${1}:  ${2}${DEFAULT}"
            ;;
    esac
}

function run_quiet() {
  # Run a command, suppressing output on success. On failure, display captured output.
  local _qout _rc
  _qout=$(mktemp)
  _rc=0
  "$@" >"${_qout}" 2>&1 || _rc=$?
  if [[ "${_rc}" -ne 0 ]]; then
    cat "${_qout}" >&2
  fi
  rm -f "${_qout}"
  return "${_rc}"
}

function find_free_port() {
  # First free TCP port at or above $1. Several presentations can run at once,
  # so the default is a starting point rather than a fixed address.
  local port="${1}"
  local limit=$(( port + 50 ))
  while (( port < limit )); do
    if ! nc -z 127.0.0.1 "${port}" >/dev/null 2>&1; then
      printf '%s\n' "${port}"
      return 0
    fi
    port=$(( port + 1 ))
  done
  feedback ERROR "No free port found between ${1} and ${limit}"
}

function others_running() {
  # Number of *other* presentations currently served from this repo.
  local count=0 f
  for f in .container_id.*; do
    [[ -e "${f}" ]] || continue
    [[ "${f}" == ".container_id.${PORT}" ]] && continue
    count=$(( count + 1 ))
  done
  printf '%s\n' "${count}"
}

function cleanup() {
  # Stop only this run. A full `task clean` would delete current-*.html and the
  # shared modern.css out from under any presentation still running, so it is
  # deferred until this is the last one.
  feedback INFO "Cleaning up..."
  if [[ -r ".container_id.${PORT}" ]]; then
    docker kill "$(cat ".container_id.${PORT}")" >/dev/null 2>&1 || true
    rm -f ".container_id.${PORT}"
  fi
  rm -f "${RENDERED_PRESENTATION}"
  local remaining
  remaining="$(others_running)"
  if [[ "${remaining}" -eq 0 ]]; then
    task clean
  else
    feedback INFO "${remaining} other presentation(s) still running; leaving shared assets in place"
  fi
  feedback INFO "Cleanup complete"
}

# Run cleanup and exit if we receive a SIGINT
trap 'cleanup; exit 130' SIGINT

OPTSPEC=":h-:"
PRESENTATION=
SUBMODULES_NEED_UPDATE="False"
LIST_PRESENTATIONS="False"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SHARED_DIR="modules/shared/"
JINJA2_TEMPLATE="template.j2"
RENDERED_PRESENTATION=  # set once the presentation name is known
PORT=
DEFAULT_PORT=8000
BRANDING="${BRANDING:-False}"  # respect env; CLI --branding overrides below
ENGINE="modern"
PORT="${PORT:-8000}"  # respect env; CLI --port overrides below
NO_CLEANUP="False"
NO_OPEN="False"

while getopts "${OPTSPEC}" optchar; do
  case "${optchar}" in
    -)
      case "${OPTARG}" in
        help)
          help ;;

        branding)
          BRANDING="${!OPTIND}"; OPTIND=$(( OPTIND + 1 )) ;;

        branding=*)
          BRANDING=${OPTARG#*=} ;;

        engine)
          ENGINE="${!OPTIND}"; OPTIND=$(( OPTIND + 1 )) ;;

        engine=*)
          ENGINE=${OPTARG#*=} ;;

        list)
          LIST_PRESENTATIONS="True" ;;

        port)
          PORT="${OPTARG#*=}"
          ;;
        no-cleanup)
          NO_CLEANUP="True" ;;

        no-open)
          NO_OPEN="True" ;;

        port)
          PORT="${!OPTIND}"; OPTIND=$(( OPTIND + 1 )) ;;

        port=*)
          PORT=${OPTARG#*=} ;;

        preso)
          PRESENTATION="${!OPTIND}"; OPTIND=$(( OPTIND + 1 )) ;;

        preso=*)
          PRESENTATION=${OPTARG#*=} ;;

        *)
          if [ "${OPTERR}" = 1 ] && [ "${OPTSPEC:0:1}" != ":" ]; then
            echo "Invalid argument: --${OPTARG}" >&2
            help 64
          fi
          ;;
      esac
      ;;

    h)
      help
      ;;

    *)
      if [ "${OPTERR}" != 1 ] || [ "${OPTSPEC:0:1}" = ":" ]; then
        echo "Invalid argument: -${OPTARG}" >&2
        help 64
      fi
  esac
done

# List presentations then exit
if [[ "${LIST_PRESENTATIONS}" == "True" ]]; then
  pushd "${SCRIPT_DIR}" > /dev/null
  while read -r presentation; do
    basename "${presentation//_content.j2/}"
  done < <(find modules presentations -type f -name "*_content.j2" | sed 's/_modern_content\.j2/_content.j2/' | sort -u)
  popd > /dev/null
  exit 0
fi

## Validation
echo -en "Getting set up.."

# Engine must be valid
echo -n "."
if [[ "${ENGINE,,}" != "revealjs" ]] && [[ "${ENGINE,,}" != "modern" ]]; then
  feedback ERROR "${ENGINE} is not a valid engine option"
fi

# Presentation is required
echo -n "."
if [[ -z "${PRESENTATION}" ]]; then
  feedback ERROR "--preso is required"
fi

# Per-run artifacts. Each presentation renders to its own file and gets its own
# port, so several can run side by side for comparison.
echo -n "."
RENDERED_PRESENTATION="current-${PRESENTATION}.html"
PORT="${PORT:-$(find_free_port "${DEFAULT_PORT}")}"

# Content file resolution based on engine
echo -n "."
if [[ "${ENGINE,,}" == "modern" ]]; then
  MODERN_CONTENT="$(find modules presentations -type f -name "${PRESENTATION}_modern_content.j2" -print -quit)"
  if [[ ! "${MODERN_CONTENT}" ]]; then
    feedback WARNING "No modern content for ${PRESENTATION}, falling back to revealjs engine"
    ENGINE="revealjs"
    PRESENTATION_CONTENT_FILE="$(find modules presentations -type f -name "${PRESENTATION}_content.j2" -print -quit)"
    if [[ ! "${PRESENTATION_CONTENT_FILE}" ]]; then
      feedback ERROR "Unable to find the presentation \"${PRESENTATION}\""
    fi
  else
    PRESENTATION_CONTENT_FILE="${MODERN_CONTENT}"
  fi
else
  PRESENTATION_CONTENT_FILE="$(find modules presentations -type f -name "${PRESENTATION}_content.j2" -print -quit)"
  if [[ ! "${PRESENTATION_CONTENT_FILE}" ]]; then
    feedback ERROR "Unable to find the presentation \"${PRESENTATION}\""
  fi
fi

# Branding resolution — engine-aware
echo -n "."
if [[ "${ENGINE,,}" == "modern" ]]; then
  # Default for modern is the unbranded pack
  if [[ "${BRANDING}" == "False" || -z "${BRANDING}" ]]; then
    BRANDING="unbranded"
  fi
  # Validate brand pack exists on disk
  if [[ ! -d "modules/branding/${BRANDING}" ]]; then
    feedback ERROR "Brand '${BRANDING}' not found. Expected modules/branding/${BRANDING}/ to exist."
  fi
else
  # Revealjs: legacy allowlist
  if [[ "${BRANDING}" != "False" ]]; then
    if [[ "${BRANDING,,}" != "seiso" ]] && [[ "${BRANDING,,}" != "zenable" ]]; then
      feedback ERROR "${BRANDING} is not a valid revealjs branding (expected: seiso, zenable)"
    fi
  fi
fi

## Environment setup
# Start from a clean slate, but only when nothing else is being served: a full
# clean removes current-*.html and the shared modern.css, which other running
# presentations are still using.
OTHERS_RUNNING="$(others_running)"
if [[ "${OTHERS_RUNNING}" -eq 0 ]]; then
  task clean
else
  feedback INFO "${OTHERS_RUNNING} other presentation(s) running; skipping clean"
  rm -f "${RENDERED_PRESENTATION}"
fi

if [[ "${ENGINE,,}" == "modern" ]]; then
  ##############################################################################
  # Modern engine path
  ##############################################################################

  # 1. Render Jinja2 — content macros first, then main template
  echo -n "."
  _qout=$(mktemp)
  _rc=0
  uv run python3 << PYEOF >"${_qout}" 2>&1 || _rc=$?
from jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader(['.', 'modules/shared/', 'modules/shared/components/']))

# Render the content file (which may import macros)
content_src = open('${PRESENTATION_CONTENT_FILE}').read()
content_tmpl = env.from_string(content_src)
rendered_content = content_tmpl.render(branding='${BRANDING}')

# Render the main template with the content
main = env.get_template('modern_template.j2')
out = main.render(title='${PRESENTATION}', content=rendered_content)

with open('${RENDERED_PRESENTATION}', 'w') as f:
    f.write(out)
PYEOF
  if [[ "${_rc}" -ne 0 ]]; then cat "${_qout}" >&2; rm -f "${_qout}"; exit 1; fi
  rm -f "${_qout}"

  # 2. Compile Tailwind CSS
  echo -n "."
  run_quiet docker run --rm -v .:/data -w /data node:alpine \
    npx tailwindcss@3 \
      -i modules/shared/css/modern-input.css \
      -o modules/shared/css/modern.css \
      --config modules/shared/tailwind.config.js \
      --minify

  # 3. Build and run lightweight server
  echo -n "."
  docker buildx build --quiet --load -f Dockerfile.modern -t monopreso-modern:latest . >/dev/null 2>&1 || true
  echo -n "."
  container_id="$(docker run --rm -d -p "${PORT}":8000 -v .:/srv -w /srv monopreso-modern:latest)"

  # 4. Wait for server
  until curl --fail -s "http://localhost:${PORT}/${RENDERED_PRESENTATION}" >/dev/null; do
    echo -n "."
    sleep .4
  done
  url="http://localhost:${PORT}/${RENDERED_PRESENTATION}"

else
  ##############################################################################
  # Reveal.js engine path (existing behavior)
  ##############################################################################

  # Update submodules if needed
  while read -r submodule_status; do
    echo -n "."
    if grep -q '^-' <<< "${submodule_status}"; then
      SUBMODULES_NEED_UPDATE="True"
      break
    fi
  done < <(docker run --rm -v .:/git -w /git --entrypoint /bin/sh cgr.dev/chainguard/git:latest-dev -c "git config --global --add safe.directory /git && git submodule status")

  if [[ "${SUBMODULES_NEED_UPDATE}" == "True" ]]; then
    echo -n "."
    docker run --rm -v .:/git -w /git --entrypoint /bin/sh cgr.dev/chainguard/git:latest-dev -c "git config --global --add safe.directory /git && git submodule update --init --recursive >/dev/null"
  fi

  # Only backup if index.html is a normal file and bkp doesn't exist
  if [[ -f reveal.js/index.html && ! ( -f reveal.js/index.html.bkp || -L reveal.js/index.html.bkp ) ]]; then
    echo -n "."
    mv reveal.js/index.html{,.bkp}
  fi

  # Generate the presentation
  content=$(cat "${PRESENTATION_CONTENT_FILE}")

  for template in title reveal_config; do
    echo -n "."
    # Purposefully only return the first match
    search="$(find modules presentations -type f -name "${PRESENTATION}_${template}.j2" -print -quit)"

    if [[ "${search}" ]]; then
      # If the search found a match, use it
      declare "${template}=$(cat "${search}")"
    else
      # Otherwise, use the default
      declare "${template}=$(cat modules/shared/default_${template}.j2)"
    fi
  done

  # Generate the presentation
  echo -n "."
  # shellcheck disable=SC2154
  _qout=$(mktemp)
  _rc=0
  uv run python3 << EOF >"${_qout}" 2>&1 || _rc=$?
from jinja2 import Environment, FileSystemLoader

title = '''${title}'''
content = '''${content}'''
reveal_config = '''${reveal_config}'''
branding = '''${BRANDING}'''


template = Environment(loader=FileSystemLoader('${SHARED_DIR}')).get_template('${JINJA2_TEMPLATE}')
out = template.render(title=title, content=content, reveal_config=reveal_config, branding=branding)

with open("${RENDERED_PRESENTATION}", "w") as f:
  f.write(out)
EOF
  if [[ "${_rc}" -ne 0 ]]; then cat "${_qout}" >&2; rm -f "${_qout}"; exit 1; fi
  rm -f "${_qout}"

  # Setup links
  echo -n "."
  ln -sf "../${RENDERED_PRESENTATION}" reveal.js/index.html
  ln -sFh ../modules reveal.js/modules
  ln -sFh ../presentations reveal.js/presentations
  ln -sf ../../../../modules/shared/scss/custom.scss reveal.js/css/theme/source/
  run_quiet docker run --rm -v .:/data -w /data node:alpine npx sass --silence-deprecation=import reveal.js/css/theme/source/custom.scss modules/shared/css/custom.css
  ln -sf ../../../modules/shared/css/custom.css reveal.js/dist/theme/custom.css

  # Render and link branded css
  if [[ "${BRANDING,,}" == "seiso" ]]; then
    ln -sf ../../../../modules/shared/scss/seiso.scss reveal.js/css/theme/source/
    echo -n "."
    run_quiet docker run --rm -v .:/data -w /data node:alpine npx sass --silence-deprecation=import reveal.js/css/theme/source/seiso.scss modules/shared/css/seiso.css
    ln -sf ../../../modules/shared/css/seiso.css reveal.js/dist/theme/seiso.css
  elif [[ "${BRANDING,,}" == "zenable" ]]; then
    ln -sf ../../../../modules/shared/scss/zenable.scss reveal.js/css/theme/source/
    echo -n "."
    run_quiet docker run --rm -v .:/data -w /data node:alpine npx sass --silence-deprecation=import reveal.js/css/theme/source/zenable.scss modules/shared/css/zenable.css
    ln -sf ../../../modules/shared/css/zenable.css reveal.js/dist/theme/zenable.css
  fi

  ## Start the presentation
  echo -n "."
  docker buildx build --quiet --load -t monopreso:latest . >/dev/null 2>&1 || true # Continue regardless; assume it failed due to no internet but we have an old version available
  echo -n "."
  livereload_port="$(find_free_port 35729)"
  container_id="$(docker run --rm -d -p "${livereload_port}":35729 -p "${PORT}":8000 -v .:/usr/src/app monopreso:latest)"
  until curl --fail -s -X GET "http://localhost:${PORT}" >/dev/null; do
    echo -n "."
    sleep .4
  done
  url="http://localhost:${PORT}/"

fi

## Common post-startup
echo -e "\n\nYour presentation is now running at ${url}"
echo "${container_id}" > ".container_id.${PORT}"
if [[ "${NO_OPEN}" == "False" ]]; then
  open /Applications/Google\ Chrome.app "${url}"
fi
if [[ "${NO_CLEANUP}" == "True" ]]; then
  echo -e "\n\nWhen you are done presenting, run task stop clean to stop everything, or task stop -- ${PORT} to stop just this one"
else
  answer="N"
  until [[ "${answer}" =~ ^[Yy]$ ]]; do
    read -rp "Enter y when you are done presenting to cleanup (y/N): " -n1 answer
    if [[ ! "${answer}" =~ ^[Yy]$ ]]; then
      echo -e "\nOk, not done yet..."
    else
      echo -e "\nGreat! Cleaning up...\n"
      cleanup
    fi
  done
fi
