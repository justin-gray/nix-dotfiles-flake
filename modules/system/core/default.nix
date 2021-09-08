{ pkgs, config, lib, ... }:
with lib;

let
  scripts = import ./scripts.nix { inherit pkgs; };
  cfg = config.jd.core;
in {
  options.jd.core = {
    enable = mkOption {
      description = "Enable core options";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    nix = {
      package = pkgs.nixUnstable;
      extraOptions = "experimental-features = nix-command flakes";
      gc = {
        automatic = true;
        options = "--delete-older-than 5d";
      };
    };

    environment.shells = [ pkgs.zsh pkgs.bash ];

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "America/Los_Angeles";

    powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      wget
      curl
      zsh
      unzip
      neofetch
      pstree

      # system monitors
      bottom
      htop
      acpi

      git
      git-crypt

      nix-index
      manix

      neovimJD

      scripts.sysTool
    ];

    programs.dconf.enable = true;
    services.dbus.packages = with pkgs; [ gnome.dconf ];

    security.sudo.extraConfig = "Defaults env_reset,timestamp_timeout=5";
    security.sudo.execWheelOnly = true;
  };
}