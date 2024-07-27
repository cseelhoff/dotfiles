{
  description = "Base WSL NixOS Configuration Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-wsl, ... }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.05";
            wsl = {
              enable = true;
              startMenuLaunchers = true;
              extraBin = with pkgs; [
                { src = "${pkgs.coreutils}/bin/mkdir"; }
                { src = "${pkgs.coreutils}/bin/cat"; }
                { src = "${pkgs.coreutils}/bin/whoami"; }
                { src = "${pkgs.coreutils}/bin/ls"; }
                { src = "${pkgs.coreutils}/bin/mv"; }
                { src = "${pkgs.coreutils}/bin/id"; }
                { src = "${pkgs.coreutils}/bin/uname"; }
                { src = "${pkgs.busybox}/bin/addgroup"; }
                { src = "${pkgs.su}/bin/groupadd"; }
                { src = "${pkgs.su}/bin/usermod"; }
                { src = "${pkgs.podman}/bin/podman"; }
              ];
            };
          }
          ./configuration.nix
          ({ pkgs, ... }: {
            environment = {
              systemPackages = with pkgs; [
                git
                nixpkgs-fmt
                wget
              ];
              shells = with pkgs; [
                zsh
              ];
            };
            programs = {
              nix-ld = {
                enable = true;
                package = pkgs.nix-ld-rs;
              };
              zsh = {
                enable = true;
                autosuggestions.enable = true;
                syntaxHighlighting.enable = true;
                ohMyZsh = {
                  enable = true;
                  theme = "robbyrussell";
                  plugins = [
                    "git"
                    "history"
                  ];
                };
              };
            };
            users.defaultUserShell = pkgs.zsh;
            virtualisation.podman.enable = true;
          })
        ];
      };
    };
  };
}
