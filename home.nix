{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    dmenu
    htop curl bat
    fastfetch
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings.user.name = "Wade";
    settings.user.email = "wade@nixos-btw";
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
      alias update='sudo nixos-rebuild switch --flake /etc/nixos#nixos-btw'
    '';
  };

  home.file = {
    ".xinitrc".text = ''
      exec dwm
    '';
    ".Xresources".text = ''
      Xft.dpi: 96
    '';
  };
}
