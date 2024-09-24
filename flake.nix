{
  description = "Base WSL NixOS Configuration Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, nixos-wsl, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
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
                  bat
                  btop
                  eza
                  fzf
                  git
                  home-manager
                  nixpkgs-fmt
                  wget
                  zoxide
                ];
                shells = with pkgs; [
                  zsh
                ];
              };
              programs = {
                fzf = {
                  fuzzyCompletion = true;
                };
                neovim = {
                  enable = true;
                  defaultEditor = true;
                  viAlias = true;
                  withPython3 = true;
                };
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
                    theme = "risto";
                    plugins = [
                      "git"
                      "history"
                      "zoxide"
                    ];
                  };
                };
              };
              users.defaultUserShell = pkgs.zsh;
              virtualisation = {
                podman = {
                  enable = true;

                  # Create a `docker` alias for podman, to use it as a drop-in replacement
                  dockerCompat = true;

                  # Required for containers under podman-compose to be able to talk to each other.
                  defaultNetwork.settings.dns_enabled = true;
                };
              };
            })
          ];
        };
      };
      homeConfigurations.nixos = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          {
            programs = {
              bat = {
                enable = true;
                extraPackages = with pkgs.bat-extras; [
                  batdiff
                  batgrep
                  batman
                  batpipe
                  batwatch
                  prettybat
                ];
              };
              eza = {
                enable = true;
                enableZshIntegration = true;
                icons = true;
                git = true;
              };
              fzf = {
                enable = true;
              };
              zoxide = {
                enable = true;
                options = [
                  "--cmd cd"
                ];
              };
              zsh = {
                enable = true;
                autosuggestion.enable = true;
                syntaxHighlighting.enable = true;
                oh-my-zsh = {
                  enable = true;
                  theme = "risto";
                  plugins = [
                    "git"
                    "history"
                    "zoxide"
                  ];
                };
              };
            };
          }
        ];
      };
    };
}
