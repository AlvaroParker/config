
if [[ -z "$TMUX" && "${HERDR_ENV:-}" != "1" ]]; then
  fastfetch
fi

# Oh-my-zsh configurations
export ZSH="$HOME/.oh-my-zsh"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-fzf-history-search)
source $ZSH/oh-my-zsh.sh

bindkey -v # enable vi mode
KEYTIMEOUT=1 # leave insert mode immediately on Esc
bindkey '^F' forward-char
bindkey "^P" up-line-or-beginning-search
bindkey "^N" down-line-or-beginning-search
bindkey "^R" fzf_history_search

# Cursor follows the vi mode: a block in normal mode, a bar while typing.
# Defined before starship, which wraps this widget to redraw its prompt mark.
_nocturne_cursor() {
  if [[ $KEYMAP == vicmd ]]; then
    printf '\e[2 q'
  else
    printf '\e[6 q'
  fi
}
zle-keymap-select() { _nocturne_cursor }
zle-line-init() { _nocturne_cursor }
zle -N zle-keymap-select
zle -N zle-line-init

# Aliases
alias ls='lsd'
alias nv='nvim'
alias tree='eza --icons=always --tree'
alias ipinfo='ip -br -c a'
alias graph='git log --oneline --graph --all --decorate'
alias sudo='sudo -A'
alias vim='nvim'
alias gs='git status'
alias gss='git status'
alias ga='git add'
alias fixtail='sudo tailscale down && sudo tailscale up'
alias ex='exit 0'
gbc() {
  printf '`%s`' "$(git branch --show-current)" | wl-copy
}

b() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "Not inside a Git repository"
    return 1
  }
  cd "$root"
}
# Env variables
export EDITOR=nvim
export ANDROID_HOME=$HOME/Android/Sdk
export DOTNET_ROOT=$HOME/.dotnet
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export GEM_HOME=$HOME/.gem
export SUDO_ASKPASS=/usr/bin/systemd-ask-password
export LOCAL_NOTEBOOK_DEV=1
export R_LIBS_USER=$HOME/R/x86_64-pc-linux-gnu-library/4.4
export TIMEFMT=$'%E real\n%U user\n%S sys'

# Nocturne colours for terminal tools (see DESIGN.md).
export FZF_DEFAULT_OPTS_FILE="$HOME/.config/nocturne/fzfrc"
export BAT_THEME=Nocturne # bat/themes/Nocturne.tmTheme

# Path exports
export PATH=$JAVA_HOME/bin:$PATH
export PATH="$PATH:$HOME/.cargo/bin:$HOME/.local/share/gem/ruby/3.2.0/bin:$HOME/.local/bin:$HOME/go/bin:/usr/local/bin:$HOME/.dotnet:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$HOME/.dotnet"
export PATH=$GEM_HOME/bin:$PATH
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$HOME/.bun/bin:$PATH"

# Machine-specific settings and secrets live here, outside the repo.
[[ -r ~/.custom_zshrc ]] && source ~/.custom_zshrc
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"

# Tools that are not in packages/ are set up only where they are installed,
# so a fresh machine starts a shell without errors.
autoload -U +X bashcompinit && bashcompinit
if (( $+commands[terraform] )); then complete -o nospace -C "$commands[terraform]" terraform; fi
# CF CLI completions
[[ -f "$HOME/.config/cf/completions/_cf.zsh" ]] && source "$HOME/.config/cf/completions/_cf.zsh"

# opencode
export PATH=$HOME/.opencode/bin:$PATH
if (( $+commands[rbenv] )); then eval "$(rbenv init - zsh)"; fi
