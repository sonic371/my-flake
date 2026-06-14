{ config, lib, pkgs, dotfiles, dwm-src, ... }:

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

  nixpkgs.overlays = [ (final: prev: {
    st = prev.st.overrideAttrs (old: {
      src = final.fetchzip {
        url = "https://github.com/sonic371/st-flexipatch/archive/5396e957352d440e343b4e6433b40f1ed7a74b83.tar.gz";
        hash = "sha256-pe26MrVb2mGvDzCU/GzY3SsxsMO8Qw0DBQox6RhR9qA=";
      };
      buildInputs = (old.buildInputs or []) ++ [ final.harfbuzz final.imlib2 ];
    });
    dmenu = prev.dmenu.overrideAttrs (old: {
      src = final.fetchzip {
        url = "https://github.com/sonic371/dmenu/archive/ccae9b52ec20bcb665bdaca53125bb137dcd07fa.tar.gz";
        hash = "sha256-RXmyTYkNt8MhQadG4AVidD88HDXmtwQeQV/KbGlttGg=";
      };
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
