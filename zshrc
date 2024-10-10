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
export EDITOR=nvim
export ANDROID_HOME=$HOME/Android/Sdk
export DOTNET_ROOT=$HOME/.dotnet
export JAVA_HOME=/usr/lib/jvm/java-22-openjdk
export PATH=$JAVA_HOME/bin:$PATH
export PATH="$PATH:$HOME/.cargo/bin:$HOME/.local/share/gem/ruby/3.2.0/bin:$HOME/.local/bin:$HOME/go/bin:/usr/local/bin:$HOME/.dotnet:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/emulator"
alias vim='nvim'
