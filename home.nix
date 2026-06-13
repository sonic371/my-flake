{ config, pkgs, ... }:

let
  dotfiles = builtins.fetchGit {
    url = "https://github.com/sonic371/dotfiles.git";
    rev = "88ae24141dfc0b8867c14d460a88627295278110";
    lfs = true;
  };
in {
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    dmenu
    curl bat
    fastfetch
    xorg.xrdb
    dunst
    feh
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
    ".Xresources".source = "${dotfiles}/xresources/.Xresources";
  };

  # User systemd services
  systemd.user.services.battery-alert = {
    Unit = {
      Description = "Battery Alert Service";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      Environment = [ "DISPLAY=:0" "PATH=${pkgs.dunst}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin" ];
      ExecStart = "${dotfiles}/dunst/.config/dunst/scripts/battery-alert.sh";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.timers.battery-alert = {
    Unit = {
      Description = "Run battery alert check every minute";
      Requires = [ "battery-alert.service" ];
    };
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  systemd.user.services.change-wallpaper = {
    Unit = {
      Description = "Change Wallpaper";
    };
    Service = {
      Type = "oneshot";
      Environment = [ "DISPLAY=:0" "PATH=${pkgs.feh}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin" ];
      ExecStart = "${dotfiles}/scripts/.config/scripts/wallpaper.sh";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.timers.change-wallpaper = {
    Unit = {
      Description = "Change wallpaper every minute";
    };
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
      OnStartupSec = "1min";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
