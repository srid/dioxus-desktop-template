{ self, lib, inputs, flake-parts-lib, ... }:

let
  inherit (flake-parts-lib)
    mkPerSystemOption;
in
{
  options = {
    perSystem = mkPerSystemOption
      ({ config, self', inputs', pkgs, system, ... }: {
        options = {
          dioxus-desktop.overrideCraneArgs = lib.mkOption {
            type = lib.types.functionTo lib.types.attrs;
            default = _: { };
            description = "Override crane args for the dioxus-desktop package";
          };

          dioxus-desktop.rustBuildInputs = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = with pkgs; [
              pkg-config
            ] ++ lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [
              IOKit
              Carbon
              WebKit
              Security
              Cocoa
            ]);
            description = "Build inputs for building the cargo package";
          };

          dioxus-desktop.rustToolchain = lib.mkOption {
            type = lib.types.package;
            description = "Rust toolchain to use for the dioxus-desktop package";
            default = (pkgs.rust-bin.fromRustupToolchainFile (self + /rust-toolchain.toml)).override {
              extensions = [
                "rust-src"
                "rust-analyzer"
                "clippy"
              ];
            };
          };

          dioxus-desktop.craneLib = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = (inputs.crane.mkLib pkgs).overrideToolchain config.dioxus-desktop.rustToolchain;
          };

          dioxus-desktop.src = lib.mkOption {
            type = lib.types.path;
            description = "Source directory for the dioxus-desktop package";
            # When filtering sources, we want to allow assets other than .rs files
            # TODO: Don't hardcode these!
            default = lib.cleanSourceWith {
              src = self; # The original, unfiltered source
              filter = path: type:
                (lib.hasSuffix "\.html" path) ||
                (lib.hasSuffix "tailwind.config.js" path) ||
                # Example of a folder for images, icons, etc
                (lib.hasInfix "/assets/" path) ||
                (lib.hasInfix "/css/" path) ||
                # Default filter from crane (allow .rs files)
                (config.dioxus-desktop.craneLib.filterCargoSources path type)
              ;
            };
          };
        };
        config =
          let
            cargoToml = builtins.fromTOML (builtins.readFile (self + /Cargo.toml));
            inherit (cargoToml.package) name version;
            inherit (config.dioxus-desktop) rustToolchain craneLib src;

            # Crane builder for Dioxus projects projects
            craneBuild = rec {
              args = {
                inherit src;
                pname = name;
                version = version;
                buildInputs = [
                  pkgs.dioxus-cli
                  tailwindcss
                ] ++ config.dioxus-desktop.rustBuildInputs;
              };
              cargoArtifacts = craneLib.buildDepsOnly args;
              buildArgs = args // {
                inherit cargoArtifacts;
                # buildPhaseCargoCommand = "cargo leptos build --release -vvv";
                # cargoTestCommand = "cargo leptos test --release -vvv";
                # nativeBuildInputs = [
                #   pkgs.makeWrapper
                # ];
              };
              package = (craneLib.buildPackage (buildArgs // config.dioxus-desktop.overrideCraneArgs buildArgs)).overrideAttrs (oa: {
                # Copy over assets for the desktop app to access
                installPhase =
                  (oa.installPhase or "") + ''
                    cp -r ${self}/assets/* $out/bin/
                  '';
              });

              check = craneLib.cargoClippy (args // {
                inherit cargoArtifacts;
                cargoClippyExtraArgs = "--all-targets --all-features -- --deny warnings";
              });

              doc = craneLib.cargoDoc (args // {
                inherit cargoArtifacts;
              });
            };

            rustDevShell = pkgs.mkShell {
              shellHook = ''
                # For rust-analyzer 'hover' tooltips to work.
                export RUST_SRC_PATH="${rustToolchain}/lib/rustlib/src/rust/library";
              '';
              buildInputs = [
                pkgs.libiconv
              ] ++ config.dioxus-desktop.rustBuildInputs;
              nativeBuildInputs = [
                rustToolchain
              ];
            };

            tailwindcss = pkgs.nodePackages.tailwindcss.overrideAttrs
              (oa: {
                plugins = [
                  pkgs.nodePackages."@tailwindcss/aspect-ratio"
                  pkgs.nodePackages."@tailwindcss/forms"
                  pkgs.nodePackages."@tailwindcss/language-server"
                  pkgs.nodePackages."@tailwindcss/line-clamp"
                  pkgs.nodePackages."@tailwindcss/typography"
                ];
              });
          in
          {
            # Rust package
            packages.${name} = craneBuild.package;
            packages."${name}-doc" = craneBuild.doc;

            checks."${name}-clippy" = craneBuild.check;

            # Rust dev environment
            devShells.${name} = pkgs.mkShell {
              inputsFrom = [
                rustDevShell
              ];
              nativeBuildInputs = with pkgs; [
                tailwindcss
                dioxus-cli
              ];
            };
          };
      });
  };
}

