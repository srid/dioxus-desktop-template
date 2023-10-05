# dioxus-desktop-template

WIP: A starter template for [Dioxus](https://dioxuslabs.com/) Desktop apps w/ Tailwind & Nix

## Goal

Act as starter project for writing new desktop apps using Dioxus, along with
- [Nix](https://zero-to-nix.com/) support
- Author's preferred tools
  - Tailwind

## Tasks

This repository is still a work-in-progress. Here's the current progress:

- [ ] Nix 
  - [x] Devshell
  - [ ] Nix package
    - [x] Simple `nix build` / `nix run`
    - [ ] Nix package containing macOS app bundle
    - [ ] Nix package for Linux
- [x] Tailwind
- [x] macOS bundling
- [x] Routes & navigation
- [ ] [Application state](#application-state)

Stretch goals:

- macOS Application menu entries

## Getting Starred

In the `nix develop` shell, run:

```
# Run these in two separate terminals
just tw     # Tailwind watcher
just watch  # Dioxus watcher
```

We do not have Nix builds yet; see tasks above.

### Creating macOS app bundle

```
just bundle
```

### Running via Nix

```
nix run github:srid/dioxus-desktop-template
# Or just `nix run` in the project directory
```

## Notes

### Application State

This repository began in large part to understand how to manage application state in Dioxus Desktop apps, and come up with some best demonstrable practices for it.

🚧

- [x] Shared read-only state
  - In the top `App` component, use `use_shared_state_provider` to initialize the application state.
  - In inner components, use `use_shared_state::<T>`, followed by a `.read()` on it, to access the current state value.
- [ ] Shared state, that can be modified
- [ ] Component that re-renders when only relevant subset of the state changes
