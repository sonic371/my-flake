{ config, lib, pkgs, ... }:

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
  }) ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    xclip
    st
  ];

  environment.variables.EDITOR = "vim";

  system.stateVersion = "25.11";
}

