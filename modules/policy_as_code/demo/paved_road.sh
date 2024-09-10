#!/usr/bin/env bash

task clean

# shellcheck disable=SC1091
source ../../../modules/shared/demo/demo-magic.sh

rm -rf TODO
pe "uvx --with gitpython cookiecutter git+ssh://git@github.com/seisollc/cookiecutter-python.git"
wait

# We want this to be single quoted and not expanded
# shellcheck disable=SC2016
pe 'cd $(ls -td * | head -1)'

pe "task init"
wait

pe "grep -r NotImplementedError *"
wait

pe "task lint"
wait

task clean
pe "tree -I goat/ -I .git -a"
wait

pe "head -13 .github/workflows/*.yml"
wait

pe "PLATFORM=all task build"
wait

pe "task test"
wait

pe "task sbom vulnscan"
wait

pe "ls sbom* vulns*"
wait
