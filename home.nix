{ config, pkgs, dotfiles, ... }:

{
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    htop curl
    fastfetch
    mpv
    libnotify
    jq
    ncdu
    xclip
    xorg.xrdb
    feh
    xdotool
    playerctl
    maim
    pulsemixer
    dunst
    picom
    sxhkd
  ];

  programs.home-manager.enable = true;

  home.sessionPath = [ "${dotfiles}/bin/.local/bin" ];

  programs.git = {
    enable = true;
    settings.user.name = "Wade";
    settings.user.email = "wade@nixos-btw";
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      if [ -f "${dotfiles}/bashrc/.bashrc" ]; then
        source "${dotfiles}/bashrc/.bashrc"
      fi
      alias update='sudo nixos-rebuild switch --flake /etc/nixos#nixos-btw'
    '';
  };

  programs.zoxide.enable = true;
  programs.fzf = {
    enable = true;
    fileWidgetOptions = [
      "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
      "--bind 'ctrl-/:toggle-preview'"
    ];
  };
  programs.bat.enable = true;
  programs.yazi.enable = true;
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    git = true;
    icons = "auto";
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  programs.ripgrep.enable = true;
  programs.fd.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](green)";
        error_symbol = "[➜](red)";
      };
      nix_shell = {
        symbol = "❄️ ";
        format = "via [$symbol]($style) ";
      };
    };
  };

  home.file = {
    ".xinitrc".text = ''
      [ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"
      exec dwm
    '';
    ".Xresources".source = "${dotfiles}/xresources/.Xresources";
    ".config/picom/picom.conf".source = "${dotfiles}/picom/.config/picom/picom.conf";
    ".config/scripts/sxhkd-volume.sh".source = "${dotfiles}/scripts/.config/scripts/sxhkd-volume.sh";
    ".config/scripts/sxhkd-brightness.sh".source = "${dotfiles}/scripts/.config/scripts/sxhkd-brightness.sh";
    ".config/scripts/sxhkd-toggle-mic.sh".source = "${dotfiles}/scripts/.config/scripts/sxhkd-toggle-mic.sh";
    ".config/scripts/sxhkd-maim.sh".source = "${dotfiles}/scripts/.config/scripts/sxhkd-maim.sh";
    ".config/scripts/sxhkd_record.sh".source = "${dotfiles}/scripts/.config/scripts/sxhkd_record.sh";
    ".config/scripts/dmenu_define.sh".source = "${dotfiles}/scripts/.config/scripts/dmenu_define.sh";
    ".config/scripts/dmenu_media.sh".source = "${dotfiles}/scripts/.config/scripts/dmenu_media.sh";
    ".config/scripts/record-webcam.sh".source = "${dotfiles}/scripts/.config/scripts/record-webcam.sh";
    ".config/sxhkd/sxhkdrc".source = "${dotfiles}/sxhkd/.config/sxhkd/sxhkdrc";
    ".config/dunst/dunstrc".source = "${dotfiles}/dunst/.config/dunst/dunstrc";
    ".config/dunst/scripts/battery-alert.sh" = {
      source = "${dotfiles}/dunst/.config/dunst/scripts/battery-alert.sh";
      executable = true;
    };
    ".config/nvim/init.lua".source = "${dotfiles}/nvim/.config/nvim/init.lua";
    ".config/nvim/lua" = {
      source = "${dotfiles}/nvim/.config/nvim/lua";
      recursive = true;
    };
    ".bash" = {
      source = "${dotfiles}/bashrc/.bash";
      recursive = true;
    };
  };

  systemd.user.services.dunst = {
    Unit = {
      Description = "Dunst notification daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.dunst}/bin/dunst -config %h/.config/dunst/dunstrc";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.picom = {
    Unit = {
      Description = "Picom compositor";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.picom}/bin/picom --backend xrender --config %h/.config/picom/picom.conf";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.sxhkd = {
    Unit = {
      Description = "Simple X hotkey daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      Environment = "PATH=${dotfiles}/bin/.local/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin";
      ExecStart = "${pkgs.sxhkd}/bin/sxhkd -c %h/.config/sxhkd/sxhkdrc";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
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
      ExecStart = "%h/.config/dunst/scripts/battery-alert.sh";
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
