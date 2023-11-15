#!/usr/bin/env bash
# shellcheck disable=SC2016

task clean

# shellcheck disable=SC1091
source ../../../modules/shared/demo/demo-magic.sh

cat <<EOF > Dockerfile
FROM ubuntu:22.04

RUN apt-get update \\
 && apt-get install -y --no-install-recommends cowsay \\
                                               lolcat \\
 && rm -rf /var/lib/apt/lists/*

CMD /usr/games/cowsay HONK! | /usr/games/lolcat
EOF

pe 'cat Dockerfile'
wait

pe 'image="jonzeolla/docker-provenance:latest"'
pe 'docker buildx build --attest type=provenance,mode=max -t "${image}" --push .'
wait

pe 'docker run -t "${image}"'
wait

pe 'docker buildx imagetools inspect "${image}" --format "{{ json .Provenance.SLSA }}" | less'
wait

# Ignore unused variable and variable referenced but unassigned; shellcheck has limited visiblity with demo-magic use
# shellcheck disable=SC2034,SC2154
manifest_digest=$(docker inspect --format='{{index .RepoDigests 0}}' "${image}" | cut -f2 -d@)

pe 'export COSIGN_PASSWORD="example"'
pe 'echo y | cosign generate-key-pair'
pe 'cosign sign --yes --key cosign.key -a tag=latest -a approval=jonzeolla "${image}@${manifest_digest}"'
wait

pe 'cosign verify --key cosign.pub "${image}@${manifest_digest}"'
wait

open -a "Google Chrome" "https://hub.docker.com/r/jonzeolla/docker-provenance/tags"

pe 'approver="$(cosign verify --key cosign.pub "${image}@${manifest_digest}" 2>/dev/null | jq -r ".[-1].optional.approval")"'
pe 'if [[ "${approver}" == "jonzeolla" ]]; then echo "Approved"; else echo "Do NOT use"; fi'
wait
