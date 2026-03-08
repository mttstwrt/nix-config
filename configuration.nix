{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ─── Boot ─────────────────────────────────────────────────────────────────

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;          # Keep last 10 generations in boot menu
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Required for NVIDIA Wayland — must be set at kernel level
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  # ─── Networking ───────────────────────────────────────────────────────────

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # ─── Locale / Time ────────────────────────────────────────────────────────

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # ─── NVIDIA ───────────────────────────────────────────────────────────────

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;                        # Required for Turing+ (RTX 20xx and newer)
    modesetting.enable = true;          # Required for Wayland
    nvidiaSettings = true;
    powerManagement.enable = false;     # Desktop — no power management needed
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;                 # Required for Steam / 32-bit games
    extraPackages = with pkgs; [
      egl-wayland                       # NVIDIA Wayland compatibility layer
    ];
  };

  # ─── NVIDIA + Wayland environment variables ───────────────────────────────
  # Set system-wide so SDDM inherits them before starting the Wayland session

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";              # Hint Electron apps to use Wayland
  };

  # ─── Desktop: Hyprland ────────────────────────────────────────────────────

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # ─── Audio ────────────────────────────────────────────────────────────────

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ─── User ─────────────────────────────────────────────────────────────────

  users.users.syrval = {
    isNormalUser = true;
    description = "syrval";
    extraGroups = [
      "wheel"           # sudo
      "networkmanager"  # manage network without sudo
      "video"           # GPU access
      "input"           # input devices
    ];
    shell = pkgs.bash;
  };

  # ─── System Packages ──────────────────────────────────────────────────────
  # Only things that belong at the system level or need to be available
  # before login. User applications go in home.nix.

  environment.systemPackages = with pkgs; [
    # CLI essentials
    git
    wget
    curl
    htop
    btop
    pciutils                            # lspci
    usbutils                            # lsusb

    # NVIDIA
    nvtopPackages.nvidia                # GPU monitor

    # Hyprland supporting tools
    waybar                            # Status bar
    wofi                              # App launcher (or swap for rofi-wayland)
    dunst                             # Notification daemon
    swww                              # Wallpaper daemon
    wl-clipboard                      # Wayland clipboard CLI
    grim                              # Screenshots
    slurp                             # Region selector for screenshots
    hyprlock                          # Lock screen
    hypridle                          # Idle daemon

    # Nix tooling
    nix-tree
    nixpkgs-fmt
  ];

  # ─── Gaming ───────────────────────────────────────────────────────────────

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  programs.gamemode.enable = true;

  programs.mangohud.enable = true;      # System-wide MangoHud support

  # ─── Flatpak ──────────────────────────────────────────────────────────────

  services.flatpak.enable = true;

  # ─── Nix ──────────────────────────────────────────────────────────────────

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ─── State Version ────────────────────────────────────────────────────────
  # Do NOT change after install. Controls stateful migration, not package versions.

  system.stateVersion = "26.05";
}
