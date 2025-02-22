# What is ddev-onex?

Building on the ddev/ddev-addon-template this repo provides additional commands
that run on the host or inside ddev containers.

# Installation

`ddev get 1xINTERNET/ddev-onex`

or if you use a current `ddev`:

`ddev add-on get 1xINTERNET/ddev-onex`

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
