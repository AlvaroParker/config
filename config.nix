{ config, pkgs, ... }:

{
  # Grub installer
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = true;
  
  # GDM
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Wayland
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  programs.hyprland.xwayland.hidpi = false;

  # Fish 
  programs.fish.enable = true;

  # GNOME
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    gnome-terminal
    gedit # text editor
    epiphany # web browser
    geary # email reader
    # evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    yelp # help browser
  ]);
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };
  environment.systemPackages = with pkgs; [
    alacritty
    flatpak
    waybar
    neofetch
    light
    swaybg
    wget
    rofi
    gdb
    git
    vim 
    neovim

  ]
}


