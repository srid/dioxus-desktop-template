{
  description = "A starter template for Dioxus Desktop apps w/ Tailwind & Nix";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";

    rust-flake.url = "github:juspay/rust-flake";
    rust-flake.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    cargo-doc-live.url = "github:srid/cargo-doc-live";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.rust-flake.flakeModules.default
        inputs.rust-flake.flakeModules.nixpkgs
        inputs.treefmt-nix.flakeModule
        inputs.process-compose-flake.flakeModule
        inputs.cargo-doc-live.flakeModule
      ];

      flake = {
        nix-health.default = {
          nix-version.min-required = "2.16.0";
          direnv.required = true;
        };
      };

      perSystem = { config, self', pkgs, lib, system, ... }: {
        # Add your auto-formatters here.
        # cf. https://numtide.github.io/treefmt/
        treefmt.config = {
          projectRootFile = "flake.nix";
          programs = {
            nixpkgs-fmt.enable = true;
            rustfmt.enable = true;
          };
        };

        nixpkgs.overlays = [
          # Configure tailwind to enable all relevant plugins
          (self: super: {
            tailwindcss = super.tailwindcss.overrideAttrs
              (oa: {
                plugins = [
                  pkgs.nodePackages."@tailwindcss/aspect-ratio"
                  pkgs.nodePackages."@tailwindcss/forms"
                  pkgs.nodePackages."@tailwindcss/language-server"
                  pkgs.nodePackages."@tailwindcss/line-clamp"
                  pkgs.nodePackages."@tailwindcss/typography"
                ];
              });
          })
        ];

        rust-project = {
          crates."dioxus-desktop-template".crane.args = {
            meta.description = "A starter template for Dioxus Desktop apps w/ Tailwind & Nix";
            buildInputs = lib.optionals pkgs.stdenv.isLinux
              (with pkgs; [
                webkitgtk_4_1
                xdotool
              ]) ++ lib.optionals pkgs.stdenv.isDarwin (
              with pkgs.darwin.apple_sdk.frameworks; [
                IOKit
                Carbon
                WebKit
                Security
                Cocoa
              ]
            );
            nativeBuildInputs = with pkgs;[
              pkg-config
              makeWrapper
              tailwindcss
              dioxus-cli
            ];
          };
          src = lib.cleanSourceWith {
            src = inputs.self; # The original, unfiltered source
            filter = path: type:
              (lib.hasSuffix "\.html" path) ||
              (lib.hasSuffix "tailwind.config.js" path) ||
              # Example of a folder for images, icons, etc
              (lib.hasInfix "/assets/" path) ||
              (lib.hasInfix "/css/" path) ||
              # Default filter from crane (allow .rs files)
              (config.rust-project.crane-lib.filterCargoSources path type)
            ;
          };
        };

        packages.default = self'.packages.dioxus-desktop-template.overrideAttrs (oa: {
          # Copy over assets for the desktop app to access
          installPhase =
            (oa.installPhase or "") + ''
              cp -r ./assets/* $out/bin/
            '';
          postFixup =
            (oa.postFixup or "") + ''
              # HACK: The Linux desktop app is unable to locate the assets
              # directory, but it does look into the current directory.
              # So, `cd` to the directory containing assets (which is
              # `bin/`, per the installPhase above) before launching the
              # app.
              wrapProgram $out/bin/${oa.pname} \
                --chdir $out/bin
            '';
        });

        devShells.default = pkgs.mkShell {
          name = "dioxus-desktop-template";
          inputsFrom = [
            config.treefmt.build.devShell
            self'.devShells.rust
          ];
          packages = with pkgs; [
            just
          ];
          shellHook = ''
            echo
            echo "🍎🍎 Run 'just <recipe>' to get started"
            just
          '';
        };
      };
    };
}
