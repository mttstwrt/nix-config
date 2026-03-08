{ config, pkgs, ... }:

{
  home.stateVersion = "26.05";

  # ─── User Packages ────────────────────────────────────────────────────────
  # Applications that belong to the user, not the system.

  home.packages = with pkgs; [
    firefox
    obsidian
    vesktop                             # Discord client
    vlc                                 # Video playback
    nautilus                            # File manager
    pavucontrol                         # Audio control
    appimage-run                        # Run AppImages on NixOS
    protonup-qt                         # Manage Proton-GE versions
  ];

  # ─── Hyprland ─────────────────────────────────────────────────────────────

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,1";

      "$mod"      = "SUPER";
      "$terminal" = "kitty";
      "$launcher" = "wofi --show drun";

      exec-once = [
        "waybar"
        "swww-daemon"
        "dunst"
        "hypridle"
      ];

      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "WLR_NO_HARDWARE_CURSORS,1"
      ];

      general = {
        gaps_in   = 5;
        gaps_out  = 10;
        border_size = 2;
        layout    = "dwindle";
      };

      decoration = {
        rounding     = 8;
        blur.enabled = true;
      };

      input = {
        kb_layout    = "us";
        follow_mouse = 1;
      };

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, D, exec, $launcher"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        "$mod SHIFT, E, exit"

        # Focus
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"

        # Screenshot
        ", Print, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%F_%T).png"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  # ─── Terminal ─────────────────────────────────────────────────────────────

  programs.kitty = {
    enable = true;
    settings = {
      font_size          = "12.0";
      background_opacity = "0.95";
    };
  };

  # ─── Git ──────────────────────────────────────────────────────────────────

  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "syrval";  # Update if needed
        email = "";        # Fill in
      };
    };
  };

  programs.home-manager.enable = true;
}
