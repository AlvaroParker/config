# Agent notes for this repo

Arch Linux and Hyprland dotfiles, built around **Nocturne**, the design system
in [DESIGN.md](DESIGN.md). Read DESIGN.md before changing anything visible:
its rules (one warm light, colour is information, quiet until needed, one edge
per object, still unless something happened) decide most design questions.
`CLAUDE.md` is a link to this file.

The repo is public, and most folders are linked live into `~/.config`, so an
edit here changes the running desktop at once.

## Working here

- Work on `main`. Do not create branches or worktrees; commit straight to
  `main`, and only when asked.
- Write commit messages as Conventional Commits, with a scope:
  `type(scope): summary`, such as `feat(btop): theme btop from the Nocturne
  palette` or `fix(install): pick graphics drivers by GPU`. Types in use:
  `feat`, `fix`, `docs`, `chore`, `refactor`, `style`. The body says why, in plain
  sentences. No attribution lines.
- Write docs and comments the way DESIGN.md is written: short, plain
  sentences that say what something does and why.
- Run `nocturne doctor` after a change. It checks colour files, contrast,
  links, fonts, packages, Obsidian vaults and the login screen.

## Colours

- `nocturne/palette.toml` is the only place colours are defined (OKLCH).
- App colour files are generated from `nocturne/templates/` by
  `nocturne/build`. Never edit a generated file; each says so in its first
  lines. After editing a template or the palette, run `nocturne build`, then
  `nocturne reload` to update the running apps.
- Templates use `{{token}}` (`#rrggbb`), `{{token:hex}}`, `{{token:rgb}}` and
  `{{token:qt}}`. Tokens are the palette names plus `*-bright`, `accent-dim`,
  and `red-bg`/`green-bg` (with `-strong`).
- Every text colour must reach 4.5:1 on `ink-0`, `ink-1` and `ink-2`
  (`nocturne check`). The login screen's background is dimmed for the dimmest
  colour written over it (`greeter/background`).

## Adding or theming an app

1. Add a template in `nocturne/templates/` and register it in `TEMPLATES` (or
   `BLOCKS`, for a marked block inside a hand-written file) in
   `nocturne/build`.
2. Link the result into place with a line in `links.txt`. Apps that rewrite
   their own config (btop, qt6ct) get only their theme linked, and `install`
   selects it in the config.
3. If the running app can pick the change up, teach `reload` in
   `bin/nocturne`; otherwise add it to the "restart to see the change" list.
4. Add a row to "Where things live" in DESIGN.md.
5. Check it live (see below), then run `nocturne doctor`.

## Packages

Each list in `packages/` holds packages from one source, and every package
must be in the list for where it really comes from:

- `pacman.txt`: official repositories. `gpu-intel.txt` and `gpu-amd.txt`:
  graphics drivers, picked by the GPU's PCI vendor ID.
- `aur.txt`: the AUR, through paru. Before adding one, check that the
  official repositories do not have it (`pacman -Sp NAME`).
- `flatpak.txt`: Flathub, installed system-wide.
- `install` itself fetches a few things from their own sources: Starship,
  Zed nightly, Herdr, oh-my-zsh and its plugins, tpm, ranger_devicons, the
  cursor theme, the icon theme, and ChatGPT from OpenAI's pacman repository.

`nocturne unlisted` shows what is installed on purpose but in no list. Some of
that is deliberately left out (personal apps, the base system). GNOME and i3
are kept on purpose: i3 is for testing X11 work, and its config lives outside
this repo in `~/.config/i3`.

Never remove packages yourself. Give the user the commands, and dry-run them
first (`pacman -Rsp`): GNOME was the only reason PipeWire's PulseAudio layer
was installed.

## System files and the login screen

- `system/` holds files for `/etc` and `/usr/local`. Nothing installs them
  automatically, because they control how the machine boots;
  `system/README.md` says how. Disk identifiers there are placeholders.
- The login screen (`greeter/`) runs from root-owned copies in
  `/etc/greetd/nocturne`. Preview changes with `nocturne greeter preview`;
  the user installs them with `nocturne greeter install`, which needs sudo.
  Real logins (Hyprland, GNOME, i3) can only be tested by the user.

## Hyprland

The config is Lua: `hypr/hyprland.lua` and `hypr/lua/`. The API's type stubs
are in `/usr/share/hypr/stubs/hl.meta.lua`. `hyprctl dispatch` takes a Lua
expression, for example `hyprctl dispatch 'hl.dsp.focus({ workspace = 5 })'`.
Hyprland reloads its config on save; check `hyprctl configerrors` afterwards.
Every key binding needs a description, because `SUPER + /` lists them.

Workspaces come in groups of ten (`hypr/lua/groups.lua`): group 2 is 11-20,
and so on. Anything that moves between workspaces should go through that
module so it stays inside the current group. It is global as
`workspace_groups`, so a script can call it with
`hyprctl dispatch 'function() workspace_groups.step(1) end'`.

The bar and the desktop panel are one Quickshell config (`quickshell/`),
which reloads itself on save; `qs log` shows its errors. Scripts reach the
bar with `qs ipc call bar refresh` or `qs ipc call bar toggle`.

## Testing on the live desktop

When the user lets you drive the desktop:

- Their own windows live on workspaces 1, 2 and 10. Test on 3 to 9, and
  switch back when done.
- `hyprctl dispatch 'hl.dsp.send_shortcut({ mods = "CTRL", key = "P",
  window = "address:0x…" })'` sends keys to a window; `grim -g "X,Y WxH"`
  captures a region in layout coordinates. A newly opened window may miss the
  first keys.
- Close only windows you opened, by address
  (`hl.dsp.window.close({ window = "address:0x…" })`). Never `pkill` by a
  bare name: the desktop panel runs as plain `qs`, and `pkill -f` patterns
  can match your own command line.
- If a test copies to the clipboard, save the clipboard first, restore it
  afterwards, and delete the test entry from `cliphist`.

## Personal data

Names, email, keys, hosts, disk IDs and Wi-Fi names stay out of the repo; the
root `.gitignore` refuses common credential files, and DESIGN.md's "State
outside the repo" lists where personal settings live instead.
