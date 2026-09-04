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
- `ddev 1x-pax-login` - signs in to the 1pax hosting platform with the company Google account, one login for every cluster. It fetches the cluster list from `pax/kubeconfig.yaml` in this repository, so adding or removing a cluster there reaches every developer at their next login, and it writes one kubeconfig per cluster to `~/.config/1x-pax` for the drush kubectl aliases (`kubectl`, `kubectl-oidc_login` and `pax-gke-token` are installed in the web container by `web-build/Dockerfile.pax`).

Commands running in the web-container:
- `ddev 1x-phpcs` - run phpcs *within* the webcontainer to ensure correct PHP version.
