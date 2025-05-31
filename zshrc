
if [[ -z "$TMUX" ]]; then
  fastfetch
fi
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh-my-zsh configurations
export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="agnoster"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

prompt_context(){}

# Aliases
alias ls='lsd'
alias nv='nvim'
alias tree='exa --icons=always --tree'
alias ipinfo='ip -br -c a'
alias graph='git log --oneline --graph --all --decorate'
alias sudo='sudo -A'
alias vim='nvim'

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

# Path exports
export PATH=$JAVA_HOME/bin:$PATH
export PATH="$PATH:$HOME/.cargo/bin:$HOME/.local/share/gem/ruby/3.2.0/bin:$HOME/.local/bin:$HOME/go/bin:/usr/local/bin:$HOME/.dotnet:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$HOME/.dotnet"
export PATH=$GEM_HOME/bin:$PATH
export PATH="$PATH:$HOME/.dotnet/tools"

# export PATH="$PATH:$HOME/github/chromium-project/depot_tools"


# Key bindings
bindkey -v # enable vi mode
bindkey '^F' forward-char
bindkey "^P" up-line-or-beginning-search
bindkey "^N" down-line-or-beginning-search

source ~/.custom_zshrc

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

