# dioxus-desktop-template

A starter template for [Dioxus](https://dioxuslabs.com/) Desktop apps w/ Tailwind & Nix

## Goal

Act as starter project for writing new desktop apps using Dioxus, along with
- [Nix](https://nixos.asia/en/nix-tutorial) support
- Author's preferred tools
  - Tailwind

## Tasks

This repository is still a work-in-progress. Here's the current progress:

- [ ] Nix 
  - [x] Devshell
  - [ ] Nix package
    - [x] Simple `nix build` / `nix run`
    - [ ] Nix package containing macOS app bundle
    - [x] Nix package for Linux
- [ ] Deployment
  - [x] macOS bundling
  - [ ] Linux bundling
- [x] Tailwind
- [x] Routes & navigation
- [x] [Application state](#application-state) (via `dioxus-signals` from 0.5)

Stretch goals:

- macOS Application menu entries

## Getting Starred

In the `nix develop` shell, run:

```
just watch 
```

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

- [x] Shared read-only state
  - In the top `App` component, use [`use_shared_state_provider`](https://dioxuslabs.com/learn/0.4/guide/state#state) to initialize the application state.
  - In inner components, use `use_shared_state::<T>`, followed by a `.read()` on it, to access the current state value.
  - The state can be changed to a new value, but not mutated. There is no per-field granularity.
- [x] Shared state, that can be modified (from *anywhere* in the component tree)
  - We use [dioxus-signals](https://github.com/DioxusLabs/dioxus/blob/master/packages/signals/README.md) (requires Dioxus from Git) to provide fine-grained mutation and component rerendering.
  - In the top `App` component, use `use_context_provider(cx, AppState::new());`
  - In inner components, use `let state: AppState = *use_context(cx).unwrap();` to access the current state value.
  - Make individual fields of the state struct a `Signal` type
    - The state struct should use `Signal` for its field types. Nested tree of `Signal`s is the idiom.
  - Use `state.<field>` to render a component based on a field signal
    - Use `dioxus_signals::use_selector` to produce a derived signal
- [x] Component re-renders when only relevant subset of the state changes
- [x] State modification that relies on a long-running blocking task
  - Write *async* modifier methods on the state struct, and have them update the field signals.
  - In the UI components, use `use_future` to invoke these async methods to update the state before the component is renderer (or upon an user event).

## Uses `rust-flake`

This project uses [rust-flake](https://github.com/juspay/rust-flake) to keep `flake.nix` minimal.

## FAQ

- Blank screen on Linux? See https://github.com/NixOS/nixpkgs/issues/32580
```
WEBKIT_DISABLE_COMPOSITING_MODE=1 nix run
```
