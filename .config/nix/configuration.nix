# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
    ];


  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  console = {
  earlySetup = true;
  #    font = "Lat2-Terminus16";
  #  font = "latarcyrheb-sun32";
  #  font = "sun12x22";
  # font = "iso01-12x22";
  font = "ter-i24b";
  packages = with pkgs; [
      terminus_font
    ];
 #    keyMap = "de";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.xserver = {
    enable = false;
    videoDrivers = ["nvidia"];
  };

  # enable qmk
  hardware.keyboard.qmk.enable = true;
  services.udev.packages = [ pkgs.via ];
  
  # Enable OpenGl
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
  };

  # Load nvidia driver for Xorg and Wayland
  hardware.nvidia = {
    # Modesetting is required
    modesetting.enable = true;
    # experimental and unstable
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    # use open-source driver
    open = false;
    #enable nvidia settings
    nvidiaSettings = true;
    # choose driver package
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver{
      version = "575.51.02";
      sha256_64bit = "sha256-XZ0N8ISmoAC8p28DrGHk/YN1rJsInJ2dZNL8O+Tuaa0=";
      openSha256 = "sha256-NQg+QDm9Gt+5bapbUO96UFsPnz1hG1dtEwT/g/vKHkw=";
      settingsSha256 = "sha256-6n9mVkEL39wJj5FB1HBml7TTJhNAhS/j5hqpNGFQE4w=";
      usePersistenced = false;
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    extraLayouts.de-fkeys = {
      description = "German layout with working F-keys for 60% layout keyboards";
      languages = [ "deu" ];
      symbolsFile = /home/jordi/dotfiles/.config/xkb/symbols/de-fkeys;
    };
  };
  
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR

  security.rtkit.enable = true;
  
  services.pipewire = {
     enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
     pulse.enable = true;
   };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jordi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs = {
    config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
             "cuda-merged"
             "castlabs-electron-35.1."
            ];
      allowUnfree = true;
      packageOverrides = pkgs: {
       unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {config.allowUnfree = true;};
       inputs = {
         zen-browser.url = "github:youwen5/zen-browser-flake";
        zen-browser.inputs.nixpkgs.follows = "nixpkgs";
        
      };
      };
    };
  };


  nix.settings.experimental-features = [ "nix-command" "flakes" ];  

  environment.systemPackages = with pkgs; 
  let
    # inputs = {
    #   zen-browser.url = "github:youwen5/zen-browser-flake";
    #   zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    # };
    swayConfig = pkgs.writeText "greetd-sway-config" ''
    # -l activates layer-shell mode. Notice that swaymsg will run ater gtkgreet
    exec "${pkgs.greetd.tuigreet}/bin/tuigreet -l; swaymsg exit"
    bindsym Mod4+shift+e exec swaynag\
      -t warning \
      -m "What do you want to do?" \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'
    '';
    R_custom = rWrapper.override{
      packages = with unstable.rPackages; [
        tidyverse
        #duckdb
        DBI
        duckplyr
        ggeffects
        gh
        gitcreds
        glue
        gt
        gridExtra
        haven
        googledrive
        httpgd
        knitr
        MASS
        tikzDevice
        tinytable
        viridis
        vroom
        # parallel
        rix    
      ];
    };
  in 
   [
    R_custom
    vim
    wget
    neovim
    firefox
    labwc
    swayfx
    swaybg
    greetd.greetd
    greetd.tuigreet
    R
    python314
    yazi
    wl-clipboard
    mako
    fastfetch
    zoxide
    stow
    htop
    btop
    zenith
    pciutils
    unstable.waybar
    wofi
    zinit
    git-credential-manager
    pass-wayland
    gnupg
    pinentry-tty
    fzf
    helix
    ffmpeg
    jq
    poppler
    fd
    resvg
    ripgrep
    imagemagick
    # vscodium
    zed-editor
    keepassxc
    unstable.onedrive
    pydf
    libgcc
    libgccjit
    # postgresql
    cachix
    unzip
    syncthing
    bat
    eza
    lsd
    powertop
    wlr-randr
    dconf
    kitty
    egl-wayland
    nvidia-vaapi-driver
    via
    starship
    eza
    lsd
    git-credential-keepassxc
    sioyek
    xorg.xkbcomp
    xorg.xev
    wev
    keyd
    unstable.hyprpolkitagent
    unstable.hyprpaper
    unstable.hyprpicker
    unstable.hypridle
    unstable.hyprland-qt-support
    unstable.hyprcursor
    unstable.hyprlock
    unstable.hyprsysteminfo
    unstable.hyprgraphics
    unstable.hyprutils
    ghostty
    unstable.tidal-hifi
    unstable.high-tide
    unstable.zed-editor
    unstable.zed-editor-fhs
    nvtopPackages.full
    dysk
    pavucontrol
    pamixer
    bluez
    bluez-tools
    alsa-utils
    unstable.texliveFull
    unstable.typst
    unstable.typstyle
    unstable.typstfmt
    unstable.tinymist
    libxml2
    nix-init
    unstable.go
    unstable.superfile
    # inputs.zen-browser.packages.${pkgs.system}.default
    unstable.libpqxx
    unstable.libpq
    unstable.postgresql
    unstable.g-ls
    unstable.fontpreview
    unstable.impression
    unstable.typescript-language-server
    unstable.nil
    unstable.hyprls
    unstable.nixfmt-rfc-style
    unstable.ags
    unstable.astal.io
    unstable.astal.gjs
    # unstable.astal.tray
    unstable.astal.cava
    unstable.astal.auth
    unstable.astal.apps
    unstable.astal.river
    unstable.astal.mpris
    unstable.astal.greet
    unstable.astal.source
    unstable.astal.notifd
    unstable.astal.astal4
    unstable.astal.astal3
    unstable.astal.wireplumber
    unstable.astal.powerprofiles
    unstable.astal.network
    unstable.astal.hyprland
    unstable.astal.bluetooth
    unstable.astal.battery
    unstable.vscode-langservers-extracted
    unstable.taplo
    unstable.nodejs
    unstable.whatsie
    unstable.zapzap
    unstable.nchat
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        myriad-dreamin.tinymist
        reditorsupport.r
      ];
    })
  ];


  environment.extraOutputsToInstall = [
    "dev"
  ];


  # programs.libxml2 = {
  #   enable = true;
  #   meta.outputsToInstall = [ "dev"];
  # };

  # programs.vscode = {
  #   enable = true;
  #   package = pkgs.vscodium;
  #   extensions = with pkgs.vscode-extensions; [
  #     myriad-dreamin.tinymist
  #     reditorsupport.r
  #   ];
  # };

  environment.sessionVariables.NIXOS_OZONE_WL ="1";

  environment.variables = {
    NIXOS_OZONE_WL="1";
    MOZ_ENABLE_WAYLAND="1";
  };

  services.keyd = {
    enable = true;
  };

    
  environment.etc."keyd/default.conf".text = ''
  [ids]
  *

  [main]
  capslock = overload(control, esc)
  # capsock = esc

  [control:C]

  1 = f1
  2 = f2
  3 = f3
  4 = f4
  5 = f5
  6 = f6
  7 = f7
  8 = f8
  9 = f9
  0 = f10
  -  = f11
  = = f12
  
  '';
 
  users.defaultUserShell = pkgs.zsh;

  programs.tmux = {
    enable = true;
    newSession = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
  };



  environment.etc."greetd/environments".text = ''
  labwc
  sway
  hyprland
  '';
  
  programs.hyprland = {
    enable = true;
    xwayland .enable = true;
    withUWSM = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  programs.uwsm = {
    enable = true;
  };
  
   
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  programs.git = {
    enable = true;
    # lfs.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
      ];
    };
    autosuggestions = {
      enable = true;
      async = true;
    };
    vteIntegration = true;
    enableGlobalCompInit = true;
  };

  # users.defaultUserShell = pkgs.zsh;

  environment.pathsToLink = [
    "share/foot"
  ];

  programs.foot = {
    enable = true;
    enableZshIntegration = true;
    theme = "catpuccin-mocha";
  };

  #Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerdfonts
      geist-font
      font-awesome
      helvetica-neue-lt-std
      liberation_ttf
      inter
      aileron
      helvetica-neue-lt-std
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Liberation Serif" ];
      	sansSerif = [ "Geist" ];
      	monospace = [ "JetBrainsMono" ];
      };
    };
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.flatpak= {
    enable = true;
  };

   systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };


  services.gnome.gnome-keyring.enable = true;

  
  services.pcscd.enable = true;

  services.onedrive = {
    enable = true;
  };


services.syncthing = {
    enable = true;
    group = "users";
    user = "jordi";
    dataDir = "${config.users.users.jordi.home}/sync";
    configDir = "${config.users.users.jordi.home}/.config/syncthing";
    overrideDevices = true;
    overrideFolders = true;
    openDefaultPorts = true;
    settings = {
      devices = {
        "oneplus" = { id = "QNHUVLY-D5GTXSA-BBC3XTZ-CQTPY2Y-UK3HXWK-N62NOJC-4PJJTFH-WDE3DQ6"; };
      };
      folders = {
       "passkeys" = {
        path = "/home/jordi/sync";
        devices = [ "oneplus" ];
         };
       };
    };
  };

  services.hypridle = {
    enable = true;
  };

  security.polkit = {
    enable = true;
  };
  
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --greeting 'Hello there!'  --remember --width 60 --greet-align left --asterisks --cmd labwc";
      user = "jordi";
      };
      default_session = initial_session;
    };
  };

    # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

