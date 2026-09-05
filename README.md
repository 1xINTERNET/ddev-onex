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
- `ddev 1x-playwright-install` - installs `lullabot/ddev-playwright` and configures it minimally
- `ddev 1x-start` - test script wrapping `ddev start`, `ddev auth ssh` and symlinking `.gitconfig` to ensure git commit are nice.
- `ddev 1x-token-setup` - test script wrapping setting up tokens for 1X internal tools and services.
- `ddev 1x-pax-login` - signs in to the 1pax hosting platform with the company Google account, one login for every cluster. It fetches the cluster list from `pax/kubeconfig.yaml` in this repository, so adding or removing a cluster there reaches every developer at their next login, and it keeps the login in `~/.config/1x-pax`, mounted into the web container, where the drush kubectl aliases pick a cluster with `context: pax-<cluster>` (drush 13.7.6 or newer). `kubectl`, `kubectl-oidc_login` and `pax-gke-token` are installed in the web container by `web-build/Dockerfile.pax`. To sign out or start over, delete the contents of `~/.config/1x-pax/cache`, never the directory itself, it is mounted into the web container of every project and a deleted directory leaves those containers with a dead mount until they are restarted.

Commands running in the web-container:
- `ddev 1x-phpcs` - run phpcs *within* the webcontainer to ensure correct PHP version.
