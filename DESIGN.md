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

**Changing the accent.** Press `SUPER + ALT + A` and pick one, or run
`nocturne accent ember`. Either way the choice is written to `palette.toml`,
every colour file is rebuilt, the running apps reload and the wallpaper's moon
is repainted. `nocturne accent` lists the choices; add your own under
`[accents]`.

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
| Slow | 280 ms | workspace changes: sideways within a group, up or down between groups, as if the groups were floors |

One curve, `settle` (0.16, 1, 0.3, 1), for anything arriving. Things leaving
use `leave` (0.4, 0, 1, 1) and take about three quarters of the time.

## Surfaces

| Surface | Treatment |
| --- | --- |
| Bar | `ink-0`, a floating island 34 px tall with 12 px corners, 8 px from the screen edges like the windows below it, drawn by Quickshell (`quickshell/Bar*.qml`). Workspaces come in groups of ten (`hypr/lua/groups.lua`), and the bar shows only the current group's, numbered 1 to 10 in every group: the focused one bright and underlined in the accent, ones on a screen in `text`, the rest faint. Outside group 1, "Group N" comes first in gold, because a group is a context you can forget you are in. Right side: icons in `muted`, warnings in gold, errors (offline, a nearly empty battery) in red. A screen recording shows as a gold dot first on the right, a mode you could forget is on; clicking it stops the recording. |
| Windows | Opaque, 1 px border, 10 px radius. Unfocused windows dim by 8%. |
| Launcher | One glass surface, query on top, sections in the footer, fixed height. Dims the screen behind it. |
| Notifications | `ink-2` at 90%, one hairline, actions under a hairline. Inside the control centre they become rows, not cards. |
| Control centre | Switches outlined in `line` when off and in the accent when on. Sliders in `text` on `ink-3`. |
| Wallpaper | `hypr/wallpapers/nocturne.jpg`, painted by `nocturne/wallpaper` from the palette: a night sky that starts at `ink-0` under the bar, receding hills, and a low moon in the accent colour, right of centre so the lock-screen clock never covers it. The moon rises through a lone rock arch shaped like the Arch Linux logo, with its flared feet and the fold on its left face; the moon lights the arch's inner edge. Run it after changing the accent; `--seed` gives a different skyline. The moon follows the real one: each night `nocturne moon` (from the `nocturne-moon` timer) paints tonight's phase into `~/.local/state/nocturne/tonight.jpg`, turned for your hemisphere (from the weather location), and that is what the desktop and lock screen show while the Nocturne wallpaper is chosen. The unlit part keeps a faint earthshine, and the glow and the light on the arch follow the phase but never drop below 15%, so the one warm light stays on dark nights. The repo's file always has a full moon, and so does the login screen. |
| Desktop | Shown on empty workspaces only, below every window. Text only, left-aligned in the empty sky so the moon stays the one warm light: the date in small capitals, a large light clock, one line of weather, and the current track while something plays or is paused (click it to play or pause). No cards, boxes or glow. |
| Login screen | The lock screen's sibling, drawn by Quickshell (`greeter/`). Your wallpaper, blurred and dimmed only as far as contrast needs: the brightest part behind the text must leave 4.5:1 for every colour written on it, red included. Date in small capitals, a large light clock, your name, then a hairline to type on that takes the accent while it has the focus, with a dot per character. No box and no placeholder. Two lines are kept free under it for what needs saying: why a login failed in red, Caps Lock in gold. Dots turn gold while the password is checked. Battery at the bottom, and Sleep, Restart and Shut down as quiet text in the corner, reachable with Tab. When GNOME or i3 is installed, the opposite corner names the session to start, after a `muted` "Session"; each press moves to the next, and anything but Hyprland is gold, because it is a mode you could forget you picked. Every boot starts at Hyprland. The bottom edge is dimmed for the dimmest of these colours, as the middle is for red. Each screen gets the scale it has on the desktop, so everything, the cursor included, is the size it is on the lock screen. If it cannot start, tuigreet takes over on the console, with its sixteen colours set from the palette. |
| Lock screen | Your current wallpaper, heavily blurred; open windows never show. Darker wallpapers are dimmed less (0.6 for the brightest, up to 1.0), measured when the wallpaper is chosen. Date in small capitals above a clock about 100 px tall, password dots in the accent below it. A soft dark shadow keeps the text readable on any wallpaper. |
| Terminal | `ink-1` glass at 85% with Hyprland's blur behind, text solid, Lilex 10.5 pt, a steady block cursor in the accent (a bar while typing in zsh). |

## Where things live

| File | Kind |
| --- | --- |
| `nocturne/palette.toml` | source of every colour |
| `nocturne/build` | generator and contrast check |
| `bin/nocturne` | the `nocturne` command: switch accent, build, reload the running apps, and `nocturne doctor` to check the setup |
| `nocturne/wallpaper` | paints `hypr/wallpapers/nocturne.jpg` from the palette (needs numpy and Pillow); `--phase tonight` paints tonight's moon outside the repo |
| `systemd/user/nocturne-moon.*` | the timer that repaints the moon after midnight and at login; linked from `links.txt`, enabled by `install` |
| `nocturne/templates/` | templates for app-specific colour files |
| `nocturne/palette.css` | generated: GTK colours for swaync, swayosd, GTK apps |
| `rofi/palette.rasi` | generated: launcher colours |
| `hypr/lua/palette.lua`, `hypr/palette.conf` | generated: Hyprland and hyprlock colours |
| `ghostty/themes/nocturne` | generated: the sixteen terminal colours |
| `nocturne/tmux.conf`, `nocturne/fzfrc`, `nocturne/delta.gitconfig`, `nocturne/qt6ct.conf` | generated |
| `zathura/nocturne`, `firefox/chrome/nocturne.css`, `zed/themes/nocturne.json`, `nvim/lua/nocturne/palette.lua` | generated |
| `zen/chrome/nocturne.css`, `zen/chrome/userContent.css`, `zen/user.js` | generated: Zen colours, built-in pages and appearance settings |
| `thunderbird/chrome/nocturne.css`, `thunderbird/user.js` | generated: Thunderbird's colours. `thunderbird/chrome/variables.css` (hand-written) recolours Thunderbird's own variables with them, and both `userChrome.css` (the main window) and `userContent.css` (pages such as the Address Book, which read only that file) import it: the folder pane, toolbars and tab bar on `ink-0`, the message list on `ink-1`, menus on `ink-2` with one hairline; the accent marks the current tab, the open space, focus and primary buttons, and a selected message or day is a selection in `accent-dim`. Unread is `bright` at weight 500, folder icons are grey, notices are a dark tint of their meaning. Corners are 10 px for cards, menus and the search field, 6 px for rows, buttons and the floating tabs. Parts of Thunderbird (Chat, the calendar's panels, the blank view at startup) use the system's colours, Adwaita's greys and blue; `user.js` sets those from the palette too, and picks the dark theme underneath. `install` links everything into the profile Thunderbird starts with |
| `obsidian/themes/Nocturne/theme.css` | generated: Obsidian's theme, dark mode only. Obsidian keeps themes inside each vault, so `install` gives every vault listed in `~/.config/obsidian/obsidian.json` a `themes/Nocturne` folder of links to these files and selects it; run `install` again after opening a new vault. The folder is real and only its files are links, because Obsidian does not notice changes through a linked folder; `nocturne reload` makes the `theme.css` link again, and Obsidian reloads the theme when it sees that. Links are blue and the open note is the brightest row; the accent marks the cursor, the current tab and things that are on |
| `btop/themes/nocturne.theme` | generated: btop's theme. Box outlines are one hairline. In a monitor, colour tells you two things: load (CPU, used memory and disk, and each process's CPU, memory and threads) runs green to gold to red as it climbs, and every other kind of reading keeps a colour of its own so the eye can tell them apart: available memory foam, cached blue, free iris, download blue, upload iris. Temperatures stay foam until they near the limit, so a normal 50 °C is never a warning. Key letters are blue, as things you can act on, and the selected process is a selection in `accent-dim`. btop rewrites its own `btop.conf`, so only the theme is linked and `install` selects it there. A running btop needs a restart to show a change |
| `quickshell/Nocturne.qml` | generated: colours for the bar and the desktop panel (the rest of `quickshell/` is hand-written; `BarState.qml` holds what all bars share) |
| `greeter/` | hand-written: the login screen. `greeter/background` makes its blurred wallpaper; `rc.xml` configures labwc, the compositor underneath it (tap to click, and no keys or menus of its own); `outputs.sh` gives each screen its desktop scale, and must be kept in step with `hypr/lua/monitors.lua`; the cursor theme and size come from `hypr/lua/env.lua` when it is installed; `session.sh` is what a login starts, with Hyprland's launcher output dropped so it never shows on the console; `Nocturne.qml` there is a link to the generated one in `quickshell/` |
| `system/usr/local/bin/nocturne-greeter.sh` | generated: what greetd starts. It runs the login screen inside labwc and falls back to tuigreet, whose console colours it carries. `nocturne greeter install` puts both in place |
| blocks marked `nocturne` in `starship.toml`, `herdr/config.toml` and `Code/User/settings.json` | generated. VS Code has no theme file to link, so its block writes Nocturne over the built-in Dark Modern theme |
| `bat/themes/Nocturne.tmTheme` | hand-written: syntax colours for bat, delta and ranger's previews, the same as Neovim's |

Tools that read the terminal's colours (eza, fastfetch, zsh highlighting,
Claude Code's status line) need no files of their own. The bat theme is the
same idea: it names the terminal's colour slots instead of hex values, so it
follows the palette without being generated. That also keeps it readable by
ranger, which cannot show 24-bit colour.

## Reloading after a change

```sh
nocturne build     # rewrite the colour files from palette.toml
nocturne reload    # tell the running apps
bat cache --build  # only after editing the bat theme
```

`nocturne reload` reloads Hyprland, notifications, the volume
display, Ghostty, tmux, Herdr, Obsidian and any running Neovim, and skips what is not
running. Zed, VS Code, the launcher, the lock screen, the bar, the desktop panel
and new shells pick changes up on their own. Zen, btop and Thunderbird need a restart. The login screen
runs from copies that only root can replace, so a new accent or wallpaper
reaches it when you run `nocturne greeter install`; `nocturne reload` says
when those copies are out of date. `nocturne greeter preview` shows it in a
window first.

`nocturne doctor` checks the whole setup: that the colour files match the
palette, the contrast table passes, every link in `links.txt` points into this
repo, every Obsidian vault uses the theme, and the fonts and cursor are
installed.

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
