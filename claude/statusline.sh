#!/usr/bin/env bash
# Claude Code status line: directory | git branch | model · effort | session id | time
# Styled like the Catppuccin Mocha status modules in ~/.tmux.conf:
# rounded pill caps, dark icon on a colored block, text on a surface block.
# Claude Code pipes session info as JSON on stdin.

input=$(cat)

# Inside Herdr, hand the same JSON to the Agent Usage plugin so the sidebar gets
# Claude's 5h/7d limits. Its output is discarded; this status line is unchanged.
# The glob follows the plugin's checkout directory, which moves on every update.
if [ "${HERDR_ENV:-}" = 1 ]; then
  for usagebar in "$HOME"/.config/herdr/plugins/github-installations/usagebar-*/*/checkout/bin/run-statusline.sh; do :; done
  [ -f "$usagebar" ] && bash "$usagebar" <<<"$input" >/dev/null 2>&1
fi

dir=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
session=$(jq -r '.session_id // empty' <<<"$input")
model=$(jq -r '.model.display_name // .model.id // empty' <<<"$input")
# Absent when the current model has no reasoning effort setting
effort=$(jq -r '.effort.level // empty' <<<"$input")
[ -z "$dir" ] && dir=$PWD

# Show the home directory as ~
short_dir=${dir/#$HOME/\~}

# Branch name, or short commit hash when detached; empty outside a repo
branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
  || git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

now=$(date +%H:%M)

# Catppuccin Mocha palette
fg() { printf '\e[38;2;%sm' "$1"; }
bg() { printf '\e[48;2;%sm' "$1"; }
bg_default=$'\e[49m'
reset=$'\e[0m'

crust="17;17;27"        # #11111b  icon text
text="205;214;244"      # #cdd6f4  label text
surface0="49;50;68"     # #313244  label background
rosewater="245;224;220" # #f5e0dc
green="166;227;161"     # #a6e3a1
peach="250;179;135"     # #fab387
mauve="203;166;247"     # #cba6f7
sapphire="116;199;236"  # #74c7ec

# Nerd Font glyphs, written as UTF-8 bytes so editors can't mangle them
cap_left=$'\xee\x82\xb6'        # U+E0B6  ple-left_half_circle_thick
cap_right=$'\xee\x82\xb4'       # U+E0B4  ple-right_half_circle_thick
icon_dir=$'\xef\x81\xbb'        # U+F07B  fa-folder (same as catppuccin's directory module)
icon_branch=$'\xef\x90\x98'     # U+F418  oct-git_branch
icon_model=$'\xf3\xb0\x9a\xa9'  # U+F06A9 md-robot
icon_chat=$'\xf3\xb0\xad\xb9'   # U+F0B79 md-chat
icon_clock=$'\xf3\xb0\xa5\x94'  # U+F0954 md-clock
dot=$'\xc2\xb7'                # U+00B7  middle dot, the separator tmux window titles use

out=""

# One module: rounded cap, icon block, label block. Modules sit edge to edge
# like tmux's connected separators, so each cap draws over the previous label.
module() { # color icon label
  local color=$1 icon=$2 label=$3
  [ -z "$out" ] && out+=$bg_default
  out+="$(fg "$color")${cap_left}"
  out+="$(fg "$crust")$(bg "$color")${icon} "
  out+="$(fg "$text")$(bg "$surface0") ${label} "
}

module "$rosewater" "$icon_dir" "$short_dir"
[ -n "$branch" ] && module "$green" "$icon_branch" "$branch"
[ -n "$model" ] && module "$peach" "$icon_model" "${model}${effort:+ $dot $effort}"
[ -n "$session" ] && module "$mauve" "$icon_chat" "$session"
module "$sapphire" "$icon_clock" "$now"

# Close the last label with a rounded cap
out+="$(fg "$surface0")${bg_default}${cap_right}${reset}"

printf '%s\n' "$out"
