#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-addon-template
  mkdir -p $TESTDIR
  export PROJNAME=test-ddev-onex
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "1x-token-setup" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  DDEV_NON_INTERACTIVE=true PERSONAL_ACCESS_TOKEN=123 ddev 1x-token-setup
  run ddev exec "npm config get @dxp:registry"
    [ "$status" -eq 0 ]
    [ "$output" = "https://git.1xinternet.de/api/v4/groups/392/-/packages/npm/" ]
  run ddev exec "npm config get @1xINTERNET:registry"
    [ "$status" -eq 0 ]
    [ "$output" = "https://git.1xinternet.de/api/v4/projects/1121/packages/npm/" ]
  run ddev exec "npm config get @1xinternet:registry"
    [ "$status" -eq 0 ]
    [ "$output" = "https://git.1xinternet.de/api/v4/groups/4/-/packages/npm/" ]
  run ddev exec "grep '=123' ~/.npmrc"
    [ "$status" -eq 0 ]
    [ "$output" = "//git.1xinternet.de/:_authToken=123" ]
 }

@test "1x-pax-login" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart -y >/dev/null
  [ -f .ddev/commands/host/1x-pax-login ]
  [ -f .ddev/docker-compose.pax.yaml ]
  run ddev exec "kubectl version --client"
    [ "$status" -eq 0 ]
  run ddev exec "kubectl-oidc_login --version"
    [ "$status" -eq 0 ]
  run ddev exec "test -x /usr/local/bin/pax-gke-token"
    [ "$status" -eq 0 ]
  run ddev exec "printenv KUBECONFIG"
    [ "$status" -eq 0 ]
    [ "$output" = "/mnt/pax/kubeconfig" ]
}

@test "upgrade replaces 1x-lib.sh from 0.1.9 or older" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  # Releases up to 0.1.9 shipped 1x-lib.sh without the #ddev-generated
  # signature, so ddev never overwrites it and newer commands that call
  # jq_compat fail with "command not found".
  mkdir -p .ddev/commands/host
  printf '%s\n' '#!/usr/bin/env bash' '#' '# Shared helper library for 1x DDEV host commands.' > .ddev/commands/host/1x-lib.sh
  ddev get ${DIR}
  grep -q '#ddev-generated' .ddev/commands/host/1x-lib.sh
  grep -q '^jq_compat()' .ddev/commands/host/1x-lib.sh
}

@test "upgrade keeps a 1x-lib.sh that is not from this add-on" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  mkdir -p .ddev/commands/host
  printf '%s\n' '#!/usr/bin/env bash' '# my own helpers' > .ddev/commands/host/1x-lib.sh
  ddev get ${DIR}
  grep -q '# my own helpers' .ddev/commands/host/1x-lib.sh
}
