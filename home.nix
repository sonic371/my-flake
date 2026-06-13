{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    dmenu
    curl bat
    fastfetch
    xorg.xrdb
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
      [ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"
      exec dwm
    '';
    ".Xresources".source = "${(builtins.fetchGit {
      url = "https://github.com/sonic371/dotfiles.git";
      rev = "88ae24141dfc0b8867c14d460a88627295278110";
      lfs = true;
    })}/xresources/.Xresources";
  };
}
