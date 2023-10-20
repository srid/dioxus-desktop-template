default:
    @just --list

# Auto-format the source tree
fmt:
    dx fmt -f src/main.rs
    # Run treefmt *after* 'dx fmt' because the latter rewrites the former!
    treefmt

# Run the project locally
watch $RUST_BACKTRACE="1":
    dx serve

tw:
    tailwind -i ./css/input.css -o ./assets/tailwind.css --watch
 

# CI=true for https://github.com/tauri-apps/tauri/issues/3055#issuecomment-1624389208)
bundle $CI="true":
    # HACK (change PWD): Until https://github.com/DioxusLabs/dioxus/issues/1283
    cd assets && dx bundle 
    nix run nixpkgs#eza -- -T ./dist/bundle/macos/dioxus-desktop-template.app
