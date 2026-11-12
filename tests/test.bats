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

@test "1x-user-guide" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev get ${DIR}
  [ -x .ddev/commands/host/1x-user-guide ]
  [ -x .ddev/commands/host/1x-user-guide-install ]
  # The preview service ships with the add-on and stays off unless its profile is started.
  grep -q 'VIRTUAL_HOST: ${DDEV_SITENAME}.pages' .ddev/docker-compose.user-guide.yaml
  grep -A1 'profiles:' .ddev/docker-compose.user-guide.yaml | grep -q user-guide
  # Without a guide the preview command says how to set it up.
  run ddev 1x-user-guide check
    [ "$status" -ne 0 ]
    [[ "$output" == *"ddev 1x-user-guide-install"* ]]
  # Building needs the gitlab-pages image from git.1xinternet.de, which CI runners may not reach;
  # that part is tested in a project.
  # Install phases: facts are validated on store, apply --dry-run writes nothing, establish never starts claude without a terminal.
  git init -q . && git remote add origin git@git.1xinternet.de:group/project.git
  mkdir -p docs/user-guide
  echo '{"url":"https://group.pages.1xinternet.de/project/"}' > docs/user-guide/site.config.json
  run bash -c 'echo "{\"version\":1,\"publish\":\"weekly\"}" | ddev 1x-user-guide-install store'
    [ "$status" -ne 0 ]
    [[ "$output" == *"publish must be"* ]]
  [ ! -f docs/user-guide/setup.json ]
  run bash -c 'echo "{\"version\":1,\"publish\":\"tags\",\"sites\":[{\"name\":\"Prod\",\"url\":\"https://www.example.com\"}]}" | ddev 1x-user-guide-install store'
    [ "$status" -eq 0 ]
    [ -f docs/user-guide/setup.json ]
  run bash -c 'ddev 1x-user-guide-install apply --dry-run < /dev/null'
    [ "$status" -eq 0 ]
    [[ "$output" == *"gitlab-pages.yml"* ]]
    [ ! -f .gitlab-ci.yml ]
  rm docs/user-guide/setup.json
  run bash -c 'ddev 1x-user-guide-install establish < /dev/null'
    [ "$status" -eq 0 ]
    [[ "$output" == *"Not an interactive terminal"* || "$output" == *"not installed"* ]]
  # A manifest replaces Claude Code: validated, stored and applied from a file (dry run: nothing is written).
  echo '{"version":1,"publish":"tags"}' > facts.json
  run bash -c 'ddev 1x-user-guide-install --manifest facts.json --dry-run < /dev/null'
    [ "$status" -eq 0 ]
    [[ "$output" == *"gitlab-pages.yml"* ]]
    [ ! -f docs/user-guide/setup.json ]
  echo '{"version":1,"publish":"weekly"}' > bad.json
  run bash -c 'ddev 1x-user-guide-install --manifest bad.json < /dev/null'
    [ "$status" -ne 0 ]
    [[ "$output" == *"publish must be"* ]]
  # Prepare stops early, with a clear message, when the project is not on git.1xinternet.de.
  git remote set-url origin https://github.com/example/project.git
  run bash -c 'ddev 1x-user-guide-install prepare < /dev/null'
    [ "$status" -ne 0 ]
    [[ "$output" == *"origin is not on git.1xinternet.de"* ]]
  # Without a guide, apply says how to create it.
  rm -rf docs/user-guide
  run bash -c 'ddev 1x-user-guide-install apply < /dev/null'
    [ "$status" -ne 0 ]
    [[ "$output" == *"ddev 1x-user-guide-install prepare"* ]]
}
