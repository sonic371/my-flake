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
    options = "--delete-older-than 7d";
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
    xclip
    st
    dmenu
  ];

  environment.variables.EDITOR = "vim";

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

  # Better FHS compatibility
  services.envfs.enable = true;

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
