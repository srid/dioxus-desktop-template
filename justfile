default:
    @just --list

# Auto-format the source tree
fmt:
    treefmt

# Run the project locally
watch $RUST_BACKTRACE="1":
    dx serve

tw:
    tailwind -i ./css/input.css -o ./assets/tailwind.css --watch
 