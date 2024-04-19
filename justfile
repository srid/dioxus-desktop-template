default:
    @just --list

# Auto-format the source tree
fmt:
    dx fmt -f src/main.rs
    # Run treefmt *after* 'dx fmt' because the latter rewrites the former!
    treefmt

# Run the project locally
watch $RUST_BACKTRACE="1" $CARGO_PROFILE_DEV_BUILD_OVERRIDE_DEBUG="true":
    dx serve

# CI=true for https://github.com/tauri-apps/tauri/issues/3055#issuecomment-1624389208)
bundle $CI="true":
    # HACK (change PWD): Until https://github.com/DioxusLabs/dioxus/issues/1283
    cd assets && dx bundle 
    nix run nixpkgs#lsd -- --tree ./dist/bundle/macos/dioxus-desktop-template.app
