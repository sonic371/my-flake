{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    st dmenu
    htop curl
    fastfetch
  ];

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Wade";
    userEmail = "wade@nixos-btw";
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
