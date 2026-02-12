# What is ddev-onex?

Building on the ddev/ddev-addon-template this repo provides additional commands
that run on the host or inside ddev containers.

# Installation

`ddev get 1xINTERNET/ddev-onex`

or if you use a current `ddev`:

`ddev add-on get 1xINTERNET/ddev-onex`

## Prerequisites

For `1x-playwright-install` and `1x-playwright-host-install`, you must have a `PERSONAL_ACCESS_TOKEN` set in your environment to access the private 1X NPM registry.

### Host setup

Export the token in your shell (e.g., in `~/.zshrc` or `~/.bashrc`):

```bash
export PERSONAL_ACCESS_TOKEN='<YOUR_TOKEN>'
```

### DDEV setup

To make the token available inside the DDEV web container, add the following to your `~/.ddev/global_config.yaml` and restart DDEV:

```yaml
web_environment:
  - PERSONAL_ACCESS_TOKEN=${PERSONAL_ACCESS_TOKEN}
```

or use `ddev config global --web-environment="PERSONAL_ACCESS_TOKEN=\${PERSONAL_ACCESS_TOKEN}"`

run `ddev restart` to apply the changes.

For more details, see:

- [Local Development DDEV Documentation](https://intranet.1xinternet.de/docs/development/drupal/local-development-ddev)
- [DDEV Customization Documentation](https://docs.ddev.com/en/stable/users/extend/customization-extendibility/)

### Additional hints (optional):

Instead of adding the token directly to you `.bashrc` or `.zshrc`, you can also use the securiy (MacOS) or secret-tool (Linux) to add the tokens

#### MacOS

add your gitlab token to your KeyChain:

```
security add-generic-password -a "$USER" -s "GITLAB_REGISTRY_TOKEN" -w "glpat-xxxx"
```

use it in your `.zshrc` or `.bashrc` like this:

```bash
export PERSONAL_ACCESS_TOKEN="$(security find-generic-password -a "$USER" -s "gitlab-npm-registry-token" -w 2>/dev/null)"
```

#### Linux

add your gitlab token to your KeyChain:

```
secret-tool store --label="GitLab Registry Token" \
    token_type gitlab_token \
    user "$USER"
```

use it in your `.zshrc` or `.bashrc` like this:

```bash
export GITLAB_REGISTRY_TOKEN=$(secret-tool lookup token_type gitlab_token user "$USER")
```

# Commands

Commands running on the host:

- `ddev 1x-playwright` - provides a convenience wrapper open the UI/reports  directly in the browser (determining the right hostnames and ports).
- `ddev 1x-playwright-install` - installs `deviantintegral/ddev-playwright` and configures it minimally
- `ddev 1x-playwright-host-install` - installs playwright on the *host*.
- `ddev 1x-granite` - runs `build.sh` in the volcano theme (@todo: should probably be moved to web-container)
- `ddev 1x-start` - test script wrapping `ddev start`, `ddev auth ssh` and symlinking `.gitconfig` to ensure git commit are nice.
- `ddev 1x-theme-debug`: wraps 1X's internal `theme-debug` helper
- `ddev 1x-twig-debug`: wraps 1X's internal `twig-debug` helper

Commands running in the web-container:

- `ddev 1x-phpcs` - run phpcs *within* the webcontainer to ensure correct PHP version.
