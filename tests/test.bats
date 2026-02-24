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
  run ddev exec "grep '=123' ~/.npmrc"
    [ "$status" -eq 0 ]
    [ "$output" = "//git.1xinternet.de/api/v4/packages/npm/:_authToken=123" ]
 }
