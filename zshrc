export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

alias ls='lsd'
alias nv='nvim'
alias tree='exa --icons=always --tree'
alias ipinfo='ip -br -c a'
prompt_context(){}
if [[ -z "$TMUX" ]]; then
  fastfetch
fi
EDITOR=nvim
export PATH="$HOME/.cargo/bin:$HOME/.local/share/gem/ruby/3.2.0/bin:$HOME/.local/bin:$HOME/go/bin:/usr/local/bin:$PATH"
