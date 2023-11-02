alias ls='lsd'
alias nv='nvim'
alias tree='exa --icons=always --tree'
alias doc_server='cd ~/.cargo-target/doc && python3 -m http.server 3494'
set fish_greeting
set JAVA_HOME /usr/lib/jvm/default
if status is-interactive
    # Check if we are not in tmux
    if test -z "$TMUX"
        neofetch
    end
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
