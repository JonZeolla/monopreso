#!/usr/bin/env bash

# shellcheck disable=SC1091
source ../../../modules/shared/demo/demo-magic.sh

docker_hub="https://hub.docker.com/repository/docker/jonzeolla/bsidescol25/general"
echo "# Ok, and now let's look at ${docker_hub}"
open "${docker_hub}"

export ALLOW_FORCE_PUSH=true
rm -rf bsidescol25 2>/dev/null || true
pe "uvx --with gitpython cookiecutter gh:zenable-io/ai-native-python project_name=bsidescol25"


github=https://github.com/JonZeolla/bsidescol25
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

pe "task unit-test"

release="https://github.com/JonZeolla/bsidescol25/actions/workflows/release.yml"
echo "# Let's take a quick look at ${release}"
open "${release}"
wait

pe "docker run --pull always jonzeolla/bsidescol25:0.1.0 --help"
