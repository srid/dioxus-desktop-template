default:
    @just --list

# Auto-format the source tree
fmt:
    treefmt
    dx fmt -f src/main.rs

# Run the project locally
watch $RUST_BACKTRACE="1":
    dx serve

tw:
    tailwind -i ./css/input.css -o ./assets/tailwind.css --watch
 