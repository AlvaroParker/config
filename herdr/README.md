# Herdr TUI

Herdr configuration, validated with Herdr 0.9.5. Anything not set here uses the
built-in defaults (catppuccin theme, `ctrl+b` prefix, `h/j/k/l` pane focus).

## Files

| Repo path | Linked to |
| --- | --- |
| `config.toml` | `~/.config/herdr/config.toml` |
| `plugins/<id>/config.toml` | `~/.config/herdr/plugins/config/<id>/config.toml` |

Only the config files are linked, so Herdr's runtime state (logs, sockets,
`session.json`, snapshots, plugin checkouts) stays outside the repository. The
`.gitignore` here allows only these files; review anything new before adding an
exception.

## Plugins

Plugins are not vendored. Install them, then run the repository's `install`
script (or link the files by hand) so they pick up the configs above:

```sh
herdr plugin install persiyanov/herdr-reviewr      # diff review, sends comments to the agent
herdr plugin install andrewchng/herdr-sessionizer  # fzf project / worktree picker (needs bun, fzf)
herdr plugin install senna-lang/herdr-agent-usage  # sidebar context and rate limits (builds with go)
```

Agent Usage only sees Claude's 5h/7d limits through Claude Code's status line.
`~/.claude/statusline.sh` (not in this repository) pipes its input to the
plugin's `bin/run-statusline.sh` when `HERDR_ENV=1`.

Agent integrations are installed per machine with
`herdr integration install claude|codex|opencode`.

## Keys added on top of the defaults

| Key | Action |
| --- | --- |
| `prefix+f` | Sessionizer: find project / workspace |
| `prefix+shift+f` | Sessionizer: open or create worktree |
| `prefix+d` | reviewr: toggle diff review |
| `prefix+u` | Agent Usage: limits pane |
| `prefix+shift+e` | Open the focused pane's checkout in Zed |

## Applying changes

```sh
HERDR_CONFIG_PATH="$PWD/herdr/config.toml" herdr config check
herdr server reload-config
```

## Documentation

- [Configuration](https://herdr.dev/tui/docs/configuration/)
- [Config reference](https://herdr.dev/tui/docs/config-reference/)
- [Session state and restore](https://herdr.dev/tui/docs/session-state/)
