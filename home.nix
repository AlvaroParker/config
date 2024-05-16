{ pkgs, ... }:


{
  home.username = "parker";
  home.homeDirectory = "/home/parker";

  home.stateVersion = "23.11";


  programs.bat = {
    enable = true;
  };
  services.network-manager-applet.enable = true;

  wayland.windowManager.hyprland = import ./programs/hyprland.nix { };
  programs.alacritty = import ./programs/alacritty.nix { };
  programs.waybar = import ./programs/waybar.nix { };
  # programs.hyprlock = import ./programs/hyprlock.nix { };


  # config path for hyprand
  xdg.configFile = {
    " hypr/hyprland.conf ".source = ~/config/hypr/hyprland.conf;
    " hypr/hyprpaper.conf ".source = ~/config/hypr/hyprpaper.conf;
  };
}
