alias ls='lsd'
alias nv='nvim'
alias tree='exa --icons=always --tree'
alias doc_server='cd ~/.cargo-target/doc && python3 -m http.server 3494'
alias ipinfo="ip -br -c a"
set -g -x AndroidSdkPath "/home/parker/Android/Sdk"
set -g -x AndroidNdkPath "/home/parker/Android/Sdk/ndk/26.1.10909125"
set fish_greeting
if status is-interactive
    # Check if we are not in tmux
    if test -z "$TMUX"
        neofetch
    end
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
