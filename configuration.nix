{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot = {
    kernelParams = ["nohibernate"];
    tmp.cleanOnBoot = true;
    supportedFilesystems = ["ntfs"];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        device = "nodev";
        efiSupport = true;
        enable = true;
        useOSProber = true;
        timeoutStyle = "menu";
      };
      timeout = 300;
    };
    kernelModules = ["tcp_bbr"];
    kernel.sysctl = {
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
      "net.core.wmem_max" = 1073741824;
      "net.core.rmem_max" = 1073741824;
      "net.ipv4.tcp_rmem" = "4096 87380 1073741824";
      "net.ipv4.tcp_wmem" = "4096 87380 1073741824";
    };
  };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall = {
      enable = false; # Disable the firewall
      # allowedTCPPorts = [ ... ]; # Open TCP ports in the firewall
      # allowedUDPPorts = [ ... ]; # Open UDP ports in the firewall
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Brussels";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "nl_BE.UTF-8";
      LC_IDENTIFICATION = "nl_BE.UTF-8";
      LC_MEASUREMENT = "nl_BE.UTF-8";
      LC_MONETARY = "nl_BE.UTF-8";
      LC_NAME = "nl_BE.UTF-8";
      LC_NUMERIC = "nl_BE.UTF-8";
      LC_PAPER = "nl_BE.UTF-8";
      LC_TELEPHONE = "nl_BE.UTF-8";
      LC_TIME = "nl_BE.UTF-8";
    };
  };

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable the X11 windowing system
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Configure greetd as the display manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        #command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # Text-based Login (Comment on of the greeters)
        command = "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -c Hyprland"; # Graphical Login (Comment on of the greeters)
        user = "greeter";
      };
    };
  };

  # Sound configuration with PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mathias = {
    isNormalUser = true;
    description = "Mathias Wouters";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "flatpak" "disk" "qemu" "kvm" "libvirtd" "sshd" "root" "docker" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  hardware = {
    # Opengl configure graphics (adjust for your hardware)
    opengl = {
      enable = true;
    };
    # Most wayland compositors need this
    nvidia.modesetting.enable = true;
  };

  # XDG / Desktop Portals
  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  # Steam
  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  # };

  # Enable virtualisation
  # virtualisation.libvirtd.enable = true;

  # Fonts configuration
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    font-awesome
  ];

  # Packages
  environment.systemPackages = with pkgs; [
    # Utilities / Dependencies
    wget
    curl
    git
    neofetch
    whois
    ufw
    nano
    vim
    neovim
    tmux
    htop # Process viewer
    kitty # Terminal
    nautilus # File manager

    # System utilities
    brightnessctl # Control device brightness
    networkmanagerapplet
    
    # Wayland utilities
    waybar # Bar
    rofi # App launcher
    swww  # Wallpaper
    grim  # Screenshot (needs slurp)
    slurp # Screenshot - screen area selection (needs grim)
    mako  # Notifications
    
    # Appearance
    nerdfonts
    papirus-icon-theme
    
    # Default Applications
    firefox
    bitwarden-desktop
    spotify
    logiops

    # Development tools
    python3Full
    docker
    vscode

    # Video / Video editing
    davinci-resolve
    gimp
    obs-studio

  ];

  system.stateVersion = "24.11"; # Leave the version as it is

}
