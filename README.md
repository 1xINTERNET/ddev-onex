# What is ddev-onex?

Building on the ddev/ddev-addon-template this repo provides additional commands
that run on the host or inside ddev containers.

# Installation

`ddev get frega/ddev-onex`

# Commands

Commands running on the host:
- `ddev 1x-granite` - runs `build.sh` in the volcano theme (@todo: should probably be moved to web-container)
- `ddev 1x-playwright-install` - installs `deviantintegral/ddev-playwright` and configures it minimally
- `ddev 1x-start` - test script wrapping `ddev start`, `ddev auth ssh` and symlinking `.gitconfig` to ensure git commit are nice.
- `ddev 1x-theme-debug` ...
- `ddev 1x-twig-debug` ...

Commands running in the web-container:
- `ddev 1x-phpcs` - run phpcs *within* the webcontainer to ensure correct PHP version.
