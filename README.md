# plugin-kit

The shared tooling behind every `yigitkonur/plugin-*` repo: one `plugin` command to see and switch plugins per project (Claude Code and Codex), and the one update job plus the canonical release and CI files the plugin repos vendor.

The rule it enforces: **every plugin is installed once, globally, and off. A project turns it on.** The one exception is `research`, which is on everywhere in both hosts. Nothing is enabled globally, so no tokens are spent in chats that don't use a plugin.

## install

```sh
curl -fsSL https://raw.githubusercontent.com/yigitkonur/plugin-kit/main/install.sh | sh -s -- --all
```

This clones the kit to `~/.local/share/plugin-kit`, links `plugin` (and the helper `codex-plugin-project.sh`) into `~/.local/bin`, installs every plugin in `registry.json` globally and off in Claude Code and Codex, schedules the 6-hourly update job and prints `plugin doctor`. Drop `--all` to install only the commands. Needs `git`, `python3` 3.11+, and `claude` and/or `codex` on the PATH.

## use

```sh
plugin                       # TUI for this folder: ↑↓ move, space = both hosts, c = Claude, x = Codex, i = install, u = update, q = quit
plugin status                # what is on here, per host
plugin on sentry testsprite  # switch on in this folder (installs globally, off, first if missing)
plugin off sentry
plugin install [NAME|all]    # global install, off (research: on)
plugin update [--all]        # marketplaces + installed plugins, both hosts
plugin autoupdate install    # schedule `plugin update --all --log` every 6 hours (launchd on macOS, cron on Linux)
plugin doctor                # is this machine in the standard state; exit 1 when not
```

Switching on writes `<folder>/.claude/settings.json` (or `settings.local.json` when the repo tracks the first) and `<folder>/.codex/config.toml`; both are kept out of `git add -A` through `.git/info/exclude`. Codex reads a folder's `.codex/config.toml` only when the folder is trusted, so `plugin on` asks once (`--trust` answers yes); trusting also enables that folder's hooks and rules, so only do it for projects you own. Restart `claude` / `codex` in the folder afterwards.

## what is in here

| path | what |
|---|---|
| `bin/plugin` | the CLI and TUI (Python 3.11+, standard library only) |
| `bin/codex-plugin-project.sh` | Codex has no `plugin enable/disable`; this edits the global and per-project config (`on`, `off`, `global-on`, `global-off`) |
| `bin/plugin-here`, `bin/sp` | thin shims for older READMEs |
| `registry.json` | every plugin: id, repo, marketplace, Codex yes/no, `project` or `global` mode |
| `release/release.py`, `release/release.yml` | the one release script and workflow every plugin repo vendors |
| `ci/` | `check-manifests.py` (versions, install policy, Codex packaging, kit copies), `secret-scan.py`, `check-links.py`, `render.py` (the README install block and AGENTS.md block), `ci-manifests.yml` (the shared CI job) |
| `sync.sh REPO...` | copy all of the above into plugin repos and refresh `scripts/kit.sha256` and the rendered blocks |

## the standard every plugin repo follows

- Installed globally and off (`defaultEnabled: false` in the Claude manifest; Codex `enabled = false` through `plugin install`). Turned on per project.
- One version, in the manifests. Claude manifest, Codex manifest and marketplace entries carry the same string. Never in code.
- The README install block and the AGENTS.md release block are rendered from this repo between `kit:` markers; `scripts/kit/check-manifests.py` fails CI when a block, a vendored file or the shared CI job drifts.
- A push to `main` that changes shipped files releases: `feat` is a minor, `fix`/`perf` a patch, `!` or `BREAKING CHANGE` a major (a minor while 0.x). Docs, CI, tests and chore-only pushes release nothing. The `release` workflow runs after `ci` is green, tags `vX` and `<plugin>--vX` and publishes the GitHub release.

## develop

`registry.json` is the one list. Add a plugin there, then `plugin install NAME`. Run `python3 bin/plugin doctor` and `sh -n install.sh` before pushing.
