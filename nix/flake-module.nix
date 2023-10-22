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
            default = [ ] ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
              webkitgtk_4_1
            ]) ++ lib.optionals pkgs.stdenv.isDarwin (
              with pkgs.darwin.apple_sdk.frameworks; [
                IOKit
                Carbon
                WebKit
                Security
                Cocoa
              ]
            );
            description = "(Runtime) buildInputs for the cargo package";
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
              targets = [ "x86_64-pc-windows-msvc" ];
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
                ] ++ config.dioxus-desktop.rustBuildInputs;
                nativeBuildInputs = with pkgs;[
                  self'.packages.cargo-xwin
                  pkg-config
                  makeWrapper
                  tailwindcss
                  dioxus-cli
                ];
                # glib-sys fails to build on linux without this
                # cf. https://github.com/ipetkov/crane/issues/411#issuecomment-1747533532
                strictDeps = true;
              };
              cargoArtifacts = craneLib.buildDepsOnly args;
              buildArgs = args // {
                inherit cargoArtifacts;
              };
              buildArgs-windows = args // {
                inherit cargoArtifacts;
                # By setting HOME to the TMPDIR (build directory), `dirs` crate will
                # use the TMPDIR as the cache directory
                # This is a workaround, check here: https://github.com/srid/dioxus-desktop-template/pull/12#issuecomment-1774194986
                HOME = "$TMPDIR";
                buildPhaseCargoCommand = ''
                  cargo xwin build --release --target $CARGO_BUILD_TARGET
                '';
                installPhaseCommand = ''
                  mkdir -p $out/bin
                  mv target/$CARGO_BUILD_TARGET/release/${name}.exe $out/bin/${name}.exe
                '';
              };
              package = (craneLib.buildPackage (buildArgs // config.dioxus-desktop.overrideCraneArgs buildArgs)).overrideAttrs (oa: {
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
                    wrapProgram $out/bin/${name} \
                      --chdir $out/bin
                  '';
              });
              package-windows = (craneLib.buildPackage (buildArgs-windows // config.dioxus-desktop.overrideCraneArgs buildArgs-windows)).overrideAttrs (oa: {
                CARGO_BUILD_TARGET = "x86_64-pc-windows-msvc";
                doCheck = false;

                depsBuildBuild = with pkgs; [
                  pkgsCross.mingwW64.stdenv.cc
                  pkgsCross.mingwW64.windows.pthreads
                ];
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
            packages."${name}-windows" = craneBuild.package-windows;
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

