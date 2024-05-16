# nixos-generate-config --root /mnt
# nixos-install
{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
in
{
  system.stateVersion = "23.11";

  # Allow unfree packages like vscode
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Use flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import "${home-manager}/nixos")
  ];
  # Boot loader
  boot.loader.systemd-boot.enable = true;

  # System configuration
  networking.networkmanager.enable = true;
  networking.hostName = "NixLaptop";
  services.xserver.enable = true;
  services.sshd.enable = true;
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  programs.dconf.enable = true;

  # Virtualization and QEMU config
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
      };
    };
  };

  # Nerdfonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" "DroidSansMono" ]; })
  ];



  # Display and desktop managers
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs;[
      dmenu #application launcher most people use
    ];
  };


  # System programs
  programs.fish.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # User declaration
  users.users.parker = {
    isNormalUser = true;
    home = "/home/parker";
    description = "Parker";
    extraGroups = [ "wheel" "docker" "users" "libvirt" "libvirt-qemu" "kvm" "networkmanager" ];
    shell = pkgs.fish;
  };


  # packages
  environment.systemPackages = with pkgs;[
    # essentials
    vim
    sudo
    git
    wget
    tmux
    curl
    unzip
    btop
    fish
    neovim
    docker
    docker-compose
    mesa
    nodejs_20
    lua
    libgcc

    # User specific, will move to home-manager
    rustup
    xdg-desktop-portal-hyprland
    flatpak
    gammastep
    grim
    wl-clipboard
    slurp
    dunst
    waybar
    blueman
    zathura
    lsd
    neofetch
    bat
    polkit_gnome
    picom
    i3
    polybar
    hyprpaper
    ripgrep
    light
    hyprpicker
    swayosd
    vscode
    rofi-wayland-unwrapped
    qemu
    fontconfig
    libvirt
    ranger
    gnomeExtensions.appindicator
    gnome.adwaita-icon-theme
    firefox
  ];

  home-manager.users.parker = import ./home.nix { inherit pkgs; };
}
