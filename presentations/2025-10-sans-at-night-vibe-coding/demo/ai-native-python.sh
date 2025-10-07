#!/usr/bin/env bash

# shellcheck disable=SC1091
source ../../../modules/shared/demo/demo-magic.sh

export ALLOW_FORCE_PUSH=true
rm -rf cloudsecnext25-at-night 2>/dev/null || true
pe "uvx --with gitpython cookiecutter gh:zenable-io/ai-native-python project_name=cloudsecnext25-at-night"
