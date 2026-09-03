# herdr

- `config.toml` — keybindings (alt-layer vim navigation). Symlinked to
  `~/.config/herdr/config.toml` by `deploy`.
- `session-snapshot.json` — copy of `~/.config/herdr/session.json` taken
  2026-09-03 (7 workspaces: realtyads, dashboard, agents, complaince_api,
  datawarehouse, alt, dot). Herdr maintains the live file itself; this is
  disaster insurance only. To restore on a fresh box:

      cp ~/dotfiles/herdr/session-snapshot.json ~/.config/herdr/session.json

  before starting `herdr`.
