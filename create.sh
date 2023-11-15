#!/usr/bin/env bash

set -o errtrace
set -o nounset
set -o errexit
set -o pipefail

function help() {
  exit_code="${1:-0}"
  # Purposefully using tabs for the HEREDOC
  cat <<- HEREDOC
		Preferred Usage: ./${0##*/} [module|presentation] --folder=FOLDER --title="TITLE"
		[module|presentation]   The type of content to create
		--folder                The name of the folder
		--title                 Your presentation title
		-h|--help               Usage details
	HEREDOC

  exit "${exit_code}"
}

FOLDER=
TITLE=
DRY_RUN="false"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
OPTSPEC=":h-:"

# Must choose between a module or presentation
if [[ "${1:-not set}" == "module" ]]; then
  CONTENT_DIR="${SCRIPT_DIR}/modules/"
elif [[ "${1:-not set}" == "presentation" ]]; then
  CONTENT_DIR="${SCRIPT_DIR}/presentations/"
else
  echo "ERROR: Must specify whether you want to create a module or presentation" >&2
  help 1
fi
shift

while getopts "${OPTSPEC}" optchar; do
  case "${optchar}" in
    -)
      case "${OPTARG}" in
        help)
          help ;;

        folder)
          FOLDER="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
          FOLDER_DIR="${CONTENT_DIR}/${FOLDER}" ;;

        folder=*)
          FOLDER=${OPTARG#*=}
          FOLDER_DIR="${CONTENT_DIR}/${FOLDER}" ;;

        title)
          TITLE="${!OPTIND}"; OPTIND=$(( OPTIND + 1 )) ;;

        title=*)
          TITLE=${OPTARG#*=} ;;

        dry-run)
          DRY_RUN="true"
          ;;

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

## Validation
# Presentation is required
if [[ -z "${FOLDER}" ]]; then
  echo "--folder is required" >&2
  exit 1
elif [[ -z "${TITLE}" ]]; then
  echo "--title is required" >&2
  exit 1
fi

if [[ "${DRY_RUN}" == "true" ]]; then
  echo "FOLDER_DIR=${FOLDER_DIR}"
  echo "TITLE=${TITLE}"
  echo "FOLDER=${FOLDER}"
  echo "CONTENT_DIR=${CONTENT_DIR}"
  exit
fi

## Create the module
mkdir -p "${FOLDER_DIR}"
echo '# Ideas for this presentation' > "${FOLDER_DIR}/IDEAS.md"
echo "${TITLE}" > "${FOLDER_DIR}/${FOLDER}_title.j2"
cp "modules/template_content.j2" "${FOLDER_DIR}/${FOLDER}_content.j2"
sed -i '' -e "s%modules/TODO%modules/${FOLDER_DIR}%g" "${FOLDER_DIR}/${FOLDER}_content.j2"
echo "Make some content and replace the TODOs:"
grep -ri TODO "${FOLDER_DIR}"
