if status is-interactive
    # Commands to run in interactive sessions can go here
#	pfetch
    set EDITOR /usr/bin/vim
	neofetch --ascii_distro fedora_small
	alias code='code --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland 2>/dev/null'
	alias librewolf='flatpak run io.gitlab.librewolf-community'
	alias l='lsd'
	alias ff='find -maxdepth 1 -type f -exec lsd {} \;'
	alias d='lsd -d */'
	alias nv='nvim'
	alias ls='lsd'
end
fish_add_path /home/parker/.spicetify
