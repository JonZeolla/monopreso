#!/usr/bin/env bash

# shellcheck disable=SC1091
source ../../../modules/shared/demo/demo-magic.sh

export ALLOW_FORCE_PUSH=true
rm -rf bsidespgh 2>/dev/null || true
pe "uvx --with gitpython cookiecutter git+ssh://git@github.com/zenable-io/ai-native-python.git"
wait

# We want this to be single quoted and not expanded
# shellcheck disable=SC2016
pe 'cd $(ls -td * | head -1)'
task clean

pe "grep -r NotImplementedError *"
wait

pe "task lint"
wait

task clean
pe "tree -I .git -I .venv -I .task -I .ruff_cache -a"
wait

pe "head -5 .github/workflows/*.yml .github/actions/*/*.yml"
wait

pe "PLATFORM=all task build"
wait

pe "task unit-test"
wait

pe "task sbom vulnscan license-check"
pe "ls sbom* vulns* license*"
wait
