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
		Preferred Usage: ./${0##*/} --preso=PRESENTATION [--list]
		--list         List the available presentations
		--preso        The presentation name
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

function cleanup() {
  feedback INFO "Cleaning up..."
  task clean
  feedback INFO "Cleanup complete"
}

# Run cleanup if we receive a SIGINT
trap cleanup SIGINT

OPTSPEC=":h-:"
PRESENTATION=
SUBMODULES_NEED_UPDATE="False"
LIST_PRESENTATIONS="False"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SHARED_DIR="modules/shared/"
JINJA2_TEMPLATE="template.j2"
RENDERED_PRESENTATION="current.html"
BRANDED="False"

while getopts "${OPTSPEC}" optchar; do
  case "${optchar}" in
    -)
      case "${OPTARG}" in
        help)
          help ;;

        list)
          LIST_PRESENTATIONS="True" ;;

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
  done < <(find modules presentations -type f -name "*_content.j2")
  popd > /dev/null
  exit 0
fi

## Validation
echo -en "Getting set up.."

# Presentation is required
echo -n "."
if [[ -z "${PRESENTATION}" ]]; then
  feedback ERROR "--preso is required"
else
  PRESENTATION_CONTENT_FILE="$(find modules presentations -type f -name "${PRESENTATION}_content.j2" -print -quit)"
  if [[ ! "${PRESENTATION_CONTENT_FILE}" ]]; then
    feedback ERROR "Unable to find the presentation \"${PRESENTATION}\""
  fi
fi

## Environment setup
# Update submodules if needed
while read -r submodule_status; do
  echo -n "."
  if grep -q '^-' <<< "${submodule_status}"; then
    SUBMODULES_NEED_UPDATE="True"
    break
  fi
done < <(docker run --rm -v .:/git -w /git --entrypoint /bin/sh cgr.dev/chainguard/git:latest -c "git config --global --add safe.directory /git && git submodule status")

if [[ "${SUBMODULES_NEED_UPDATE}" == "True" ]]; then
  echo -n "."
  docker run --rm -v .:/git -w /git --entrypoint /bin/sh cgr.dev/chainguard/git:latest -c "git config --global --add safe.directory /git && git submodule update --init --recursive >/dev/null"
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
# 2>&1 is to remove noisy known warnings
# shellcheck disable=SC2154
docker run --rm -v .:/usr/src/app -w /usr/src/app python:3.11 /bin/bash -c "python -m pip install --upgrade pip pipenv >/dev/null 2>&1 \
                                                                           && pipenv install --deploy --ignore-pipfile --dev >/dev/null 2>&1 \
                                                                           && pipenv run python3 << EOF
from jinja2 import Environment, FileSystemLoader

title = '''${title}'''
content = '''${content}'''
reveal_config = '''${reveal_config}'''
branded = '''${BRANDED}'''


template = Environment(loader=FileSystemLoader('${SHARED_DIR}')).get_template('${JINJA2_TEMPLATE}')
out = template.render(title=title, content=content, reveal_config=reveal_config, branded=branded)

with open(\"${RENDERED_PRESENTATION}\", \"w\") as f:
  f.write(out)
EOF"

# Setup links
echo -n "."
ln -sf "../${RENDERED_PRESENTATION}" reveal.js/index.html
ln -sFh ../modules reveal.js/modules
ln -sFh ../presentations reveal.js/presentations
ln -sFh ../../../../modules/shared/fonts/bitter reveal.js/dist/theme/fonts/
ln -sFh ../../../../modules/shared/fonts/rock-salt reveal.js/dist/theme/fonts/

# Render and link branded css
if [[ "${BRANDED}" == "True" ]]; then
  ln -sf ../../../../modules/shared/scss/example.scss reveal.js/css/theme/source/
  echo -n "."
  docker run --platform linux/amd64 --rm -v .:/data codycraven/sassc reveal.js/css/theme/source/example.scss > modules/shared/css/example.css
  ln -sf ../../../modules/shared/css/example.css reveal.js/dist/theme/example.css
fi

## Start the presentation
if [[ "$(uname -m)" == "arm64" ]]; then
  command="apt-get update >/dev/null && apt-get install -y chromium >/dev/null && PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm install >/dev/null && npm start -- --host 0.0.0.0"
else
  command="npm install >/dev/null && npm start -- --host 0.0.0.0"
fi
echo -n "."
container_id=$(docker run --rm -d -p 35729:35729 -p 8000:8000 -v .:/usr/src/app -w /usr/src/app/reveal.js node:20 /bin/bash -c "${command}")
until curl --fail -s -X GET http://localhost:8000 >/dev/null; do
  echo -n "."
  sleep .4
done
url="http://localhost:8000/"
open /Applications/Google\ Chrome.app "${url}"
echo -e "\n\nYour presentation is now running at ${url}"
answer="N"
until [[ "${answer}" =~ ^[Yy]$ ]]; do
  read -rp "Enter y when you are done presenting to cleanup (y/N): " -n1 answer
  if [[ ! "${answer}" =~ ^[Yy]$ ]]; then
    echo -e "\nOk, not done yet..."
  else
    echo -e "\nGreat! Cleaning up...\n"
    docker kill "${container_id}"
    cleanup
  fi
done
