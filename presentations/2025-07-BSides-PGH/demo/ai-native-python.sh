#!/usr/bin/env bash

# shellcheck disable=SC1091
source ../../../modules/shared/demo/demo-magic.sh

export ALLOW_FORCE_PUSH=true
rm -rf bsidespgh25 2>/dev/null || true
pe "uvx --with gitpython cookiecutter git+ssh://git@github.com/zenable-io/ai-native-python.git project_name=bsidespgh25"
# pe "uvx --with gitpython cookiecutter git+ssh://git@github.com/zenable-io/ai-native-python.git prjoect_name=bsidespgh25 --checkout TODO --keep-project-on-failure"
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
export IGNORES="-I .git -I .venv -I .task -I .ruff_cache"
pe "tree $IGNORES -a"
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
