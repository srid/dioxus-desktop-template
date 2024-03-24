default:
    @just --list

# Auto-format the source tree
fmt:
    dx fmt -f src/main.rs
    # Run treefmt *after* 'dx fmt' because the latter rewrites the former!
    treefmt

# Build the dioxus-cli (using same version as in Cargo.toml)
dioxus-cli:
    cargo build -r -p dioxus-cli

# Run the project locally
watch $RUST_BACKTRACE="1": dioxus-cli 
    ./target/release/dx serve

# CI=true for https://github.com/tauri-apps/tauri/issues/3055#issuecomment-1624389208)
bundle $CI="true": dioxus-cli 
    # HACK (change PWD): Until https://github.com/DioxusLabs/dioxus/issues/1283
    cd assets && dx bundle 
    nix run nixpkgs#lsd -- --tree ./dist/bundle/macos/dioxus-desktop-template.app
