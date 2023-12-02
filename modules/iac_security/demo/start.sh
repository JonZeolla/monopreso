#!/usr/bin/env bash
trap cleanup INT

function cleanup() {
  docker-compose -f loki/docker-compose.yaml -f grafana/docker-compose.yaml down
  exit
}

if [[ "${1}" == "--fast-forward" ]]; then
  default_answer="Y"
else
  default_answer="N"
fi

echo "Starting loki and grafana..."
docker-compose -f loki/docker-compose.yaml -f grafana/docker-compose.yaml up --force-recreate -d
sleep 2
echo "Loki and grafana are running"
open /Applications/Google\ Chrome.app http://localhost:3000/d/pou-6tq7k/easy-infra\?orgId=1

# TODO: Autoload the dashboard

function confirm_with_user() {
  answer="${default_answer}"
  until [[ "${answer}" =~ ^[Yy]$ ]]; do
    read -rp "Are you ready to move on? (y/N): " -n1 answer
    if [[ ! "${answer}" =~ ^[Yy]$ ]]; then
      echo -e "\nWaiting..."
    else
      echo -e "\nGreat! Running easy_infra in $1 mode\n"
    fi
  done
}

easy_infra_version="2023.11.06-terraform"

set -x
for directory in "general/secure" "tool/checkov"; do
  docker run -e DISABLE_SECURITY=true --network loki_default -v "${PWD}/easy_infra/tests/terraform/${directory}:/iac" -v "${PWD}/fluent-bit.loki.conf:/usr/local/etc/fluent-bit/fluent-bit.outputs.conf" seiso/easy_infra:"${easy_infra_version}" terraform init -backend=false
done
set +x

echo "Done!"

confirm_with_user "learning"
set -x
for directory in "general/secure" "tool/checkov"; do
  docker run -e LEARNING_MODE=true --network loki_default -v "${PWD}/easy_infra/tests/terraform/${directory}:/iac" -v "${PWD}/fluent-bit.loki.conf:/usr/local/etc/fluent-bit/fluent-bit.outputs.conf" seiso/easy_infra:"${easy_infra_version}" /bin/bash -c "terraform init && terraform validate"
done
set +x

echo "Done!"

confirm_with_user "blocking"
set -x
for directory in "general/secure" "tool/checkov"; do
  docker run --network loki_default -v "${PWD}/easy_infra/tests/terraform/${directory}:/iac" -v "${PWD}/fluent-bit.loki.conf:/usr/local/etc/fluent-bit/fluent-bit.outputs.conf" seiso/easy_infra:"${easy_infra_version}" /bin/bash -c "terraform init && terraform validate"
done
set +x

echo "Done!"

answer="N"
until [[ "${answer}" =~ ^[Yy]$ ]]; do
  read -rp "Shut down the demo? (y/N): " -n1 answer
  if [[ ! "${answer}" =~ ^[Yy]$ ]]; then
    echo -e "\nWaiting..."
    continue
  fi

  echo
  read -rp "Really? " -n1 answer
  if [[ "${answer}" =~ ^[Yy]$ ]]; then
    echo -e "\nOk..."
    cleanup
  fi
done
