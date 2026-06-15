{ config, lib, pkgs, dotfiles, dwm-src, st-src, dmenu-src, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Taipei";

  services.xserver = {
    enable = true;
    windowManager.dwm.enable = true;
    displayManager.sessionCommands = ''
      xset r rate 200 35 &
    '';
    # Daemons (fcitx5, dunst, picom, sxhkd) started via home-manager systemd user services
  };

  # Input Method (fcitx5)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-gtk
      fcitx5-lua
      fcitx5-nord
    ];
  };

  users.users.wade = {
    isNormalUser = true;
    extraGroups = [ "wheel" "vboxsf" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-old-generations 14";
  };

  nixpkgs.overlays = [ (final: prev: {
    st = prev.st.overrideAttrs (old: {
      src = st-src;
      buildInputs = (old.buildInputs or []) ++ [ final.harfbuzz final.imlib2 ];
    });
    dmenu = prev.dmenu.overrideAttrs (old: {
      src = dmenu-src;
    });
    dwm = prev.dwm.overrideAttrs (old: {
      src = dwm-src;
    });
  }) ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    st
    dmenu
    nodejs
  ];

  # Custom fonts from dotfiles (with git LFS support)
  fonts.packages = with pkgs; let
    fontDir = "${dotfiles}/fonts/.local/share/fonts";
  in [
    noto-fonts
    noto-fonts-cjk-sans
    (pkgs.stdenvNoCC.mkDerivation {
      name = "dotfiles-fonts";
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/share/fonts
        cp -r "${fontDir}/"* $out/share/fonts/
      '';
    })
  ];

  # Better FHS compatibility for non-Nix dynamic executables
  services.envfs.enable = true;
  programs.nix-ld.enable = true;

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  system.stateVersion = "25.11";
}
