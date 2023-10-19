{ pkgs, ... }:


{

  hardware = {
    opengl.enable = true;
    nvidia = {
		modesetting.enable = true;
		nvidiaSettings = true;
	  	forceFullCompositionPipeline = true;
	  	powerManagement.enable = true;
	};
  };

  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

	videoDrivers = [ "nvidia" ];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    enableNvidiaPatches = true;
  };

  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    });
  };

  environment.systemPackages = with pkgs; [
    swaybg
    mako
    libnotify
    swaylock
    wl-clipboard
    wl-clip-persist
    # Pulseaudio to expose pactl
    pulseaudio
	xwaylandvideobridge
    (lutris.override {
      extraLibraries =  pkgs: [
        # List library dependencies here
      ];
    })
	wineWowPackages.staging
	wineWowPackages.stable
	wineWowPackages.waylandFull

	xdg-desktop-portal-hyprland
	wireplumber

  gnome.seahorse
  ];

  # Fix locking problem
  security.pam.services.swaylock = { };

  # Keyring
  # services.gnome.gnome-keyring.enable = true;
  programs.ssh.startAgent = false;
  # programs.seahorse.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  virtualisation.docker.rootless = {
	  enable = true;
	  setSocketVariable = true;
	};

  services.udisks2.enable = true;

  services.pcscd.enable = true;
}
