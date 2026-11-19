# Nocturne

The design system for this desktop: a cold, dark field with a single warm
light in it. Every app in the repo follows it. When something new is added,
it should follow it too.

## Rules

1. **One warm light.** The accent marks where you are: the focused window, the
   active workspace, the cursor, the current section, a switch that is on.
   Nothing else uses it.
2. **Colour is information.** Red, gold, green and blue mean error, warning,
   success and link. Decoration uses none of them. Modes (resize, keep awake)
   use gold, because they are states you can forget you are in.
3. **Quiet until needed.** The bar shows where you are, the time, and what
   needs attention. Normal readings (CPU, memory, volume level, network name)
   stay out of sight until they matter.
4. **Solid where you work.** Terminals and editors are opaque. Blur is for
   surfaces that appear briefly over your work: the launcher, notifications,
   the control centre and the volume display.
5. **One edge per object.** A surface gets a hairline or a lighter fill, never
   both plus a shadow. No glows, no gradients. Lighter means closer. Only
   floating windows cast a shadow.
6. **Still unless something happened.** No seconds, no blinking, no bounce.
   Motion takes 120 to 280 ms and settles without overshoot.

## Colour

`nocturne/palette.toml` is the only place colours are defined. Values are
OKLCH, so neutrals share one hue and the syntax colours share one lightness.
Run `nocturne/build` after editing it; it rewrites every generated file and
prints a contrast table.

| Token | Hex | Use | On ink-1 |
| --- | --- | --- | --- |
| `ink-0` | `#080b14` | bar, panels, title bars | |
| `ink-1` | `#0f121e` | window background | |
| `ink-2` | `#171b2a` | raised surfaces: popups, notifications | |
| `ink-3` | `#222739` | selected rows, hover, inactive switches | |
| `line` | `#30364a` | hairlines, unfocused borders | |
| `faint` | `#80879d` | comments, placeholders, off states | 5.2 |
| `muted` | `#a1a7bb` | secondary text, bar icons | 7.8 |
| `text` | `#d9deec` | body text | 13.9 |
| `bright` | `#f3f5fc` | emphasis, the time, the active item | 17.1 |
| `accent` | `#f4a4ad` | where you are (rose) | 9.6 |
| `accent-dim` | `#522a30` | selection and search-hit backgrounds | |
| `red` | `#fc5950` | error, offline, critical battery | 5.9 |
| `gold` | `#f2c36a` | warning, modes, modified files | 11.4 |
| `green` | `#7dd89f` | success, added lines, strings | 10.8 |
| `blue` | `#8ab6f7` | links, functions | 9.0 |
| `foam` | `#8bd6de` | terminal cyan, types | 11.4 |
| `iris` | `#c7a6ee` | terminal magenta, keywords | 9.0 |

The build also derives `*-bright` variants for the terminal, and red and green
diff backgrounds. Every text colour passes 4.5:1 on `ink-0`, `ink-1` and `ink-2`.

**Changing the accent.** Set `accent = "ember"` or `"ice"` in `palette.toml`,
run `nocturne/build`, then reload (see below).

## Type

| Role | Face | Size |
| --- | --- | --- |
| Lock screen clock | IBM Plex Sans Light | 120 |
| Launcher query | IBM Plex Sans | 15 pt |
| Launcher rows, notifications, GTK and Qt apps | IBM Plex Sans | 11 to 14 |
| Bar, terminal, code, captions, keys | Lilex Nerd Font | 13 px, 10.5 pt in Ghostty |

Two weights: 400 and 500. Bold is for one thing per surface. Zed's built-in
fonts are the same two faces (`.ZedSans` and `.ZedMono`). Packages:
`ttf-ibm-plex` and `ttf-lilex-nerd`.

## Space and shape

- **One gap: 8 px.** Between windows, from the bar to the first window, and
  from windows to the screen edge.
- **Two radii:** 10 px for objects (windows, launcher, notifications, panels),
  6 px for the parts inside them (rows, buttons, switches). The bar has none,
  because it is attached to the screen edge.
- **A 4 px grid** for padding: 4, 8, 12, 16, 24.
- **Borders:** 1 px. The accent on the focused window, `line` everywhere else.

## Motion

| Speed | Duration | Used for |
| --- | --- | --- |
| Fast | 120 ms | fades, hovers, borders, layers |
| Standard | 200 ms | windows opening and moving |
| Slow | 280 ms | workspace changes |

One curve, `settle` (0.16, 1, 0.3, 1), for anything arriving. Things leaving
use `leave` (0.4, 0, 1, 1) and take about three quarters of the time.

## Surfaces

| Surface | Treatment |
| --- | --- |
| Bar | `ink-0`, a floating island 34 px tall with 12 px corners, 8 px from the screen edges like the windows below it. Workspaces as numbers, the current one underlined in the accent. Right side: icons in `muted`, warnings in gold, errors in red. |
| Windows | Opaque, 1 px border, 10 px radius. Unfocused windows dim by 8%. |
| Launcher | One glass surface, query on top, sections in the footer, fixed height. Dims the screen behind it. |
| Notifications | `ink-2` at 90%, one hairline, actions under a hairline. Inside the control centre they become rows, not cards. |
| Control centre | Switches outlined in `line` when off and in the accent when on. Sliders in `text` on `ink-3`. |
| Wallpaper | `hypr/wallpapers/nocturne.jpg`, painted by `nocturne/wallpaper` from the palette: a night sky that starts at `ink-0` under the bar, receding hills, and a low moon in the accent colour, right of centre so the lock-screen clock never covers it. Run it after changing the accent; `--seed` gives a different skyline. |
| Desktop | Shown on empty workspaces only, below every window. Text only, left-aligned in the empty sky so the moon stays the one warm light: the date in small capitals, a large light clock, one line of weather, and the current track while something plays or is paused (click it to play or pause). No cards, boxes or glow. |
| Lock screen | Your current wallpaper, heavily blurred; open windows never show. Darker wallpapers are dimmed less (0.6 for the brightest, up to 1.0), measured when the wallpaper is chosen. Date in small capitals above a clock about 100 px tall, password dots in the accent below it. A soft dark shadow keeps the text readable on any wallpaper. |
| Terminal | `ink-1` glass at 85% with Hyprland's blur behind, text solid, Lilex 10.5 pt, a steady block cursor in the accent (a bar while typing in zsh). |

## Where things live

| File | Kind |
| --- | --- |
| `nocturne/palette.toml` | source of every colour |
| `nocturne/build` | generator and contrast check |
| `nocturne/wallpaper` | paints `hypr/wallpapers/nocturne.jpg` from the palette (needs numpy and Pillow) |
| `nocturne/templates/` | templates for app-specific colour files |
| `nocturne/palette.css` | generated: GTK colours for Waybar, swaync, swayosd, GTK apps |
| `rofi/palette.rasi` | generated: launcher colours |
| `hypr/lua/palette.lua`, `hypr/palette.conf` | generated: Hyprland and hyprlock colours |
| `ghostty/themes/nocturne` | generated: the sixteen terminal colours |
| `nocturne/tmux.conf`, `nocturne/fzfrc`, `nocturne/delta.gitconfig`, `nocturne/qt6ct.conf` | generated |
| `zathura/nocturne`, `firefox/chrome/nocturne.css`, `zed/themes/nocturne.json`, `nvim/lua/nocturne/palette.lua` | generated |
| `zen/chrome/nocturne.css`, `zen/chrome/userContent.css`, `zen/user.js` | generated: Zen colours, built-in pages and appearance settings |
| `quickshell/Nocturne.qml` | generated: desktop panel colours (the rest of `quickshell/` is hand-written) |
| blocks marked `nocturne` in `starship.toml` and `herdr/config.toml` | generated |
| `bat/themes/Nocturne.tmTheme` | hand-written: syntax colours for bat, delta and ranger's previews, the same as Neovim's |

Tools that read the terminal's colours (btop with the `TTY` theme, eza,
fastfetch, zsh highlighting) need no files of their own. The bat theme is the
same idea: it names the terminal's colour slots instead of hex values, so it
follows the palette without being generated. That also keeps it readable by
ranger, which cannot show 24-bit colour.

## Reloading after a change

```sh
nocturne/build
hyprctl reload                       # borders and colours
pkill -x waybar; setsid -f waybar    # bar
swaync-client --reload-css           # notifications
pkill -USR2 -x ghostty               # terminal
tmux source-file ~/.tmux.conf        # tmux
bat cache --build                    # after editing the bat theme
```

Zed, the launcher, the lock screen, the desktop panel and new shells pick
changes up on their own.
Zen needs a restart.

## Zen

Zen paints a gradient per workspace and derives its colours from an accent,
both written as inline styles. `zen/chrome/nocturne.css` pins those variables
with `!important`, which a user stylesheet is allowed to do over inline
styles, so the sidebar stays one flat `ink-0` surface whatever theme a
workspace has. That surface is glass: Zen's Linux transparency is on
(`zen/user.js`) and the sidebar is tinted 40%, so Hyprland's blur shows
through; text stays at 7.7:1 even over the moon. Web pages stay solid. The selected tab is a lighter row with bright text, like the
launcher; the accent is kept for focus rings, toggles and primary buttons.

The Flatpak sandbox gets read-only access to `zen/` only
(`flatpak override --user --filesystem=<repo>/zen:ro app.zen_browser.zen`), and
the files are linked into the default profile. `zen/user.js` sets appearance
preferences only; everything else in Zen's settings stays yours.

## State outside the repo

The repo is public, so personal details and credentials stay out of it. The
root `.gitignore` refuses the usual credential files in case an app writes one
into a linked folder.

- `~/.gitconfig`: name, email, commit signing and safe directories. Everything
  else (aliases, pull, merge, diff, delta, LFS) is in the repo's `git/config`.
- `~/.config/git/allowed_signers`: emails and public keys for signed commits.
- `~/.custom_zshrc`: machine-specific environment and secrets.
- `~/.config/gh/hosts.yml`, `~/.codex/auth.json`, Claude's credentials: logins.
- `~/.codex/config.toml`: per-project trust entries with home paths.
- `~/.local/state/nocturne/`: the chosen wallpaper, and the hyprpaper and
  hyprlock files made from it.
- `~/.config/nocturne-location.json`: where the desktop weather is for, written
  by `install` after you pick your city from a list. The format is in
  `quickshell/location.example.json`. Without it, the weather line stays empty.
  The coordinates, rounded to about a kilometre, are sent to Open-Meteo, which
  needs no account.
- `~/.config/zed/global_settings.json`: SSH connections.
- Herdr's agent hooks (`~/.claude/hooks/`, `~/.codex/herdr-agent-state.sh`,
  `~/.codex/hooks.json`): written by `herdr integration install`.
- `~/.config/qt6ct/qt6ct.conf` and `~/.config/btop/btop.conf`: rewritten by
  their apps, so they are edited in place rather than linked.
- Disk identifiers in `system/etc/dracut.conf.d/cmdline.conf` are placeholders;
  see `system/README.md`.
