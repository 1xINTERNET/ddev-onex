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
- `ddev 1x-pax-login` - signs in to the 1pax hosting platform with the company Google account, one login for every cluster. It fetches the cluster list from `pax/kubeconfig.yaml` in this repository, so adding or removing a cluster there reaches every developer at their next login, and it keeps the login in `~/.config/1x-pax`, mounted into the web container, where the drush kubectl aliases pick a cluster with `context: pax-<cluster>` (drush 13.7.6 or newer). `kubectl`, `kubectl-oidc_login` and `pax-gke-token` are installed in the web container by `web-build/Dockerfile.pax`. Every run starts a fresh sign-in, so running it again is also how you switch accounts or pick up a new grant at once. Never delete `~/.config/1x-pax` itself, it is mounted into the web container of every project and a deleted directory leaves those containers with a dead mount until they are restarted.
- `ddev 1x-user-guide-install [prepare|establish|store|show|apply] [--manifest <file>] [--yes] [--dry-run]` - sets up the end-user guide in `docs/user-guide/`, published on the project's own GitLab Pages, in phases. Idempotent: every step skips what is already in place.
  - **prepare** (local): checks the prerequisites (VPN/GitLab, a running local site, Playwright), adds the `user-guide` agents package to `.1xai-manifest.json` and installs it, creates `docs/user-guide/`, adds the screenshot runner and builds the guide once.
  - **establish**: after a `[y/N]`, Claude Code finds the facts and asks the decisions (publish on tags or from a branch, existing Pages job, Stage/Prod URLs, branding).
  - **store**: the facts are piped to `store`, which validates them and writes `docs/user-guide/setup.json`.
  - **apply** (deterministic): adds the `gitlab-pages.yml` include and `GITLAB_PAGES_BRANCH` to `.gitlab-ci.yml` with `yq`, gives the jobs a stage when GitLab's CI lint dry run says the pipeline would be empty, updates `site.config.json` and copies the logo/favicon, shows every diff and asks before writing, and sets `pages_access_level=private` only after an interactive yes. `--dry-run` changes nothing (and skips prepare).
  - Without arguments it runs prepare, then `apply` when facts exist, otherwise `establish`. Re-run a single phase with its name, e.g. `ddev 1x-user-guide-install apply`.
  - Without Claude Code (or when you do not want it): `ddev 1x-user-guide-install --manifest facts.json` validates, stores and applies the same JSON. The format is described below.
  - After applying, Claude Code continues with the STANDARDS section and the first page. Needs `glab` for the GitLab part; `yq` runs through docker when it is not installed.
- `ddev 1x-user-guide` - previews (`serve`, default), checks (`check`, full build with link check) or builds (`build`, into `public/`) the user guide with the same gitlab-pages image as CI. The preview runs as the optional `user-guide` service (`docker-compose.user-guide.yaml`, off by default) behind the ddev router at `https://<project>.pages.ddev.site/<base>/` and reloads on edits; run `serve` again after adding, moving or reordering pages, and `stop` to end it. After installing or updating the add-on, run `ddev restart` once. If `<project>.pages.ddev.site` does not resolve, `serve` adds it to the hosts file with `ddev hostname`, like ddev does for the project's own hostnames.

  ```
  ddev 1x-user-guide-install    # once per project: prepare, then establish, store, apply (asks first)
  ddev 1x-user-guide            # preview
  ddev 1x-user-guide stop       # end the preview
  ddev 1x-user-guide check      # before committing
  ```

  The setup manifest (`docs/user-guide/setup.json`, version 1) that `store` and `--manifest` accept; only `version` and `publish` are required:

  ```json
  {
    "version": 1,
    "publish": "branch:main",
    "pages": "own",
    "sites": [
      { "name": "Stage", "url": "https://stage.example.com" },
      { "name": "Prod", "url": "https://www.example.com" }
    ],
    "branding": {
      "title": "Example user guide",
      "logo": "web/themes/custom/example/logo.svg",
      "favicon": "web/themes/custom/example/favicon.png",
      "accent": "#e30613"
    }
  }
  ```

  - `publish`: `tags` (release tags, what Prod has) or `branch:<name>` (sets `GITLAB_PAGES_BRANCH`).
  - `pages`: `own` (default) or `existing`; `existing` keeps another Pages job and only checks the guide in CI (`GITLAB_PAGES_ENABLED: 'false'`).
  - `sites`: the websites listed besides Local; `name` and an `http(s)` `url`.
  - `branding`: all optional. `logo` and `favicon` are paths relative to the project root, copied to `docs/user-guide/assets/`; `accent` is a hex colour.

Commands running in the web-container:
- `ddev 1x-phpcs` - run phpcs *within* the webcontainer to ensure correct PHP version.
