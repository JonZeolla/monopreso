#!/usr/bin/env bash

# shellcheck disable=SC1091
source ../../../modules/shared/demo/demo-magic.sh

docker_hub="https://hub.docker.com/repository/docker/jonzeolla/bsidespgh25/general"
echo "# Ok, and now let's look at ${docker_hub}"
open "${docker_hub}"

export ALLOW_FORCE_PUSH=true
rm -rf bsidespgh25 2>/dev/null || true
pe "uvx --with gitpython cookiecutter git+ssh://git@github.com/zenable-io/ai-native-python.git project_name=bsidespgh25"
# pe "uvx --with gitpython cookiecutter git+ssh://git@github.com/zenable-io/ai-native-python.git prjoect_name=bsidespgh25 --checkout TODO --keep-project-on-failure"
#
github=https://github.com/JonZeolla/bsidespgh25
echo "# Let's take a quick look at ${github}"
open "${github}"
wait


# We want this to be single quoted and not expanded
# shellcheck disable=SC2016
pe 'cd $(ls -td * | head -1)'
task clean

pe "grep -r NotImplementedError *"

pe "task lint"

task clean
export IGNORES="-I .git -I .venv -I .task -I .ruff_cache"
pe "tree $IGNORES -a"

pe "head -5 .github/workflows/*.yml .github/actions/*/*.yml"

pe "PLATFORM=all task build"

pe "task unit-test"

pe "task sbom vulnscan license-check"
pe "ls sbom* vulns* license*"
