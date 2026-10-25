# Maintainer notes (plugin-kit)

Shared tooling for the `yigitkonur/plugin-*` repos. Read `README.md` for the standard; this file is the rules for changing the kit.

- `registry.json` is the one list of plugins. Names, ids and marketplaces must match what each repo's marketplace files say; `mode: global` is only for `research`.
- `bin/plugin` is one Python 3.11+ file, standard library only. It reads state from `claude plugin list --json`, `codex plugin list` and the settings files, and writes only through `claude plugin enable|disable`, `bin/codex-plugin-project.sh`, and the Claude `settings.json` keys `extraKnownMarketplaces.<m>.autoUpdate` and `env.CLAUDE_CODE_PLUGIN_PREFER_HTTPS`.
- `bin/codex-plugin-project.sh` is the single copy of the Codex helper. It matches TOML tables by parsed key path; do not go back to regexes on the header text.
- Never put a token, an account id or a personal path in this repo. Commit under the GitHub noreply identity.
- Check before pushing: `python3 -m py_compile bin/plugin`, `sh -n install.sh`, `bash -n bin/codex-plugin-project.sh`, then run `plugin status` and `plugin doctor` once.
