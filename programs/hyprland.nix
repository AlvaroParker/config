{ ... }:
{
  enable = true;
  settings = {
    monitor = [
      "HDMI-A-1, 1920x1080, 1920x0, 1"
      "eDP-1, 1920x1080, 0x0, 1"
    ];
    windowrulev2 = [
      "opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$"
      "noanim,class:^(xwaylandvideobridge)$"
      "noinitialfocus,class:^(xwaylandvideobridge)$"
      "maxsize 1 1,class:^(xwaylandvideobridge)$"
      "noblur,class:^(xwaylandvideobridge)$"

      "float,class:(firefox),title:(.*Bitwarden.*)"
      "center,class:(firefox),title:.*(Bitwarden)"
    ];

    windowrule = [
      "float,yad|nm-connection-editor|pavucontrolk|xfce-polkit|kvantummanager|qt5ct|feh|Viewnior|Gpicview|Gimp|MPlayer|VirtualBox Manager|qemu|Qemu-system-x86_64|mpv|xdg-desktop-portal-gtk|org.parker.Postdex"

      "center,yad|nm-connection-editor|pavucontrolk|xfce-polkit|kvantummanager|qt5ct|feh|Viewnior|Gpicview|Gimp|MPlayer|VirtualBox Manager|qemu|Qemu-system-x86_64|mpv|xdg-desktop-portal-gtk"
    ];


    "exec-once" = [
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "waybar"
      "blueman-applet"
      "~/.config/hypr/screen-share-startup"
      "swayosd-server"
      "nm-applet"
      "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
      "hyprpaper"
    ];

    env = "XCURSOR_SIZE,12";
    input = {
      kb_layout = "us";
      follow_mouse = 1;
      touchpad = {
        natural_scroll = "yes,";
        tap-to-click = "yes,";
      };
      sensitivity = 0;
    };

    general = {
      no_border_on_floating = false;
      gaps_in = 5; # Gaps between windows
      gaps_out = 10; # Gaps between windows and monitor edge
      border_size = 3;

      "col.active_border" = "rgba(CAD3F5FF) rgba(4ABAAFFF) 50deg";

      "col.inactive_border" = "rgba(343A40FF)";

      layout = "dwindle";
    };

    group = {
      "col.border_active" = "rgba(CAD3F5FF) rgba(4ABAAFFF) 50deg";
      "col.border_inactive" = "rgba(343A40FF)";
      # col.group_border_active=rgba(CAD3F5FF)
      groupbar = {
        gradients = false;
        render_titles = false;
        "col.inactive" = "rgba(343A40FF)";
        "col.active" = "rgba(CAD3F5FF) rgba(4ABAAFFF) 50deg";
      };
    };

    decoration = {
      rounding = 8;
      # multisample_edges=true

      active_opacity = 1.0;
      inactive_opacity = 1.0;
      fullscreen_opacity = 1.0;

      blur = {
        enabled = true;
        size = 3;
        passes = 2; # minimum 1, more passes = more resource intensive.
        ignore_opacity = true;
      };
    };

    animations = {
      enabled = 1;
      animation = [
        "windows,1,5,default,slide"
        "border,1,10,default"
        "fade,1,8,default"
        "workspaces,1,3,default"
      ];
    };

    dwindle = {
      pseudotile = "yes"; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = "yes"; # you probably want this
    };

    master = {
      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      new_is_master = true;
    };

    gestures = {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more
      workspace_swipe = "on";
    };
    "$mainMod" = "SUPER";

    bind = [
      "$mainMod SHIFT, Q, killactive, "
      "$mainMod SHIFT, E, exit, "
      "$mainMod SHIFT, space, togglefloating, "
      "$mainMod, P, pseudo, # dwindle"
      "$mainMod, W, togglesplit, # dwindle"
      "$mainMod, H, movefocus, l"
      "$mainMod, L, movefocus, r"
      "$mainMod, K, movefocus, u"
      "$mainMod, J, movefocus, d"
      "$mainMod SHIFT, H, movewindow, l"
      "$mainMod SHIFT, L, movewindow, r"
      "$mainMod SHIFT, K, movewindow, u"
      "$mainMod SHIFT, J, movewindow, d"
      "SUPER,F,fullscreen"
      "$mainMod SHIFT, F, fakefullscreen"
      "$mainMod, x,togglegroup"
      "$mainMod, h, changegroupactive, b"
      "$mainMod, l, changegroupactive, f"
      "$mainMod, 1, workspace, 1"
      "$mainMod, 2, workspace, 2"
      "$mainMod, 3, workspace, 3"
      "$mainMod, 4, workspace, 4"
      "$mainMod, 5, workspace, 5"
      "$mainMod, 6, workspace, 6"
      "$mainMod, 7, workspace, 7"
      "$mainMod, 8, workspace, 8"
      "$mainMod, 9, workspace, 9"
      "$mainMod, 0, workspace, 10"
      "$mainMod SHIFT, 1, movetoworkspace, 1"
      "$mainMod SHIFT, 2, movetoworkspace, 2"
      "$mainMod SHIFT, 3, movetoworkspace, 3"
      "$mainMod SHIFT, 4, movetoworkspace, 4"
      "$mainMod SHIFT, 5, movetoworkspace, 5"
      "$mainMod SHIFT, 6, movetoworkspace, 6"
      "$mainMod SHIFT, 7, movetoworkspace, 7"
      "$mainMod SHIFT, 8, movetoworkspace, 8"
      "$mainMod SHIFT, 9, movetoworkspace, 9"
      "$mainMod SHIFT, 0, movetoworkspace, 10"
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"
      "$mainMod SHIFT,R,submap,resize # will switch to a submap called resize"
      "$mainMod, return, exec, alacritty"
      "$mainMod SHIFT, return, exec, alacritty -e ~/.local/bin/auto_tmux"
      "$mainMod, E, exec, nautilus"
      "$mainMod, D, exec, rofi -show drun"
      "$mainMod, I, exec, flatpak run org.mozilla.firefox"
      "$mainMod SHIFT, P, exec, hyprlock"
      "$mainMod SHIFT, N, exec, gammastep  -P -O 3500"
      "$mainMod SHIFT, M, exec, killall gammastep"
      "$mainMod SHIFT, O, exec, $HOME/.config/hypr/switch_monitor"
      "$mainMod SHIFT, W, exec, swaylock"
      "$mainMod,XF86MonBrightnessUp,exec,light -S 100"
      "$mainMod,XF86MonBrightnessDown,exec,light -S 0"
      ",XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
      ",XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
      ",Caps_Lock,exec,sleep 0.1 && swayosd-client --caps-lock"
      "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy && wl-paste > ~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png | dunstify \"Screenshot of the region taken\" -t 1000 # screenshot of a region "
      ", Print, exec, grim - | wl-copy && wl-paste > ~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png | dunstify \"Screenshot of whole screen taken\" -t 1000 # screenshot of the whole screen"
      "$mainMod SHIFT, B, exec, killall -SIGUSR1 waybar"
    ];

    binde = [
      ",XF86MonBrightnessUp,exec,swayosd-client --brightness raise"
      ",XF86MonBrightnessDown,exec,swayosd-client --brightness lower"
      ",XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
      ",XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
    ];

    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    submap = {
      "resize" = {
        binde = [
          ",L,resizeactive,10 0"
          ",H,resizeactive,-10 0"
          ",K,resizeactive,0 -10"
          ",J,resizeactive,0 10"

        ];
        bind = [
          ",escape,submap,reset" # use reset to go back to the global submap
        ];
      };
    };
  };
}
