alias ls='lsd'
alias nv='nvim'
alias tree='exa --icons=always --tree'
alias doc_server='cd ~/.cargo-target/doc && python3 -m http.server 3494'
alias ipinfo="ip -br -c a"
alias gbc="GalaxyBudsClient"
alias zed="zeditor"
set -g -x AndroidSdkPath "/home/parker/Android/Sdk"
set -g -x AndroidNdkPath "/home/parker/Android/Sdk/ndk/26.1.10909125"
set -g -x VCPKG_ROOT "/home/parker/.local/share/vcpkg"
set -g -x XCURSOR_SIZE 24
set fish_greeting
if status is-interactive
    # Check if we are not in tmux
    if test -z "$TMUX"
        neofetch
    end
end

# bun

set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin $PATH /home/parker/.ghcup/bin # ghcup-env
