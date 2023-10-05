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
  - We use `dioxus-signals` which is unreleased, thus we depend on Dioxus from Git.

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
  - In the top `App` component, use [`use_shared_state_provider`](https://dioxuslabs.com/learn/0.4/guide/state#state) to initialize the application state.
  - In inner components, use `use_shared_state::<T>`, followed by a `.read()` on it, to access the current state value.
  - The state can be changed to a new value, but not mutated. There is no per-field granularity.
- [x] Shared state, that can be modified (from *anywhere* in the component tree)
  - We use [dioxus-signals](https://github.com/DioxusLabs/dioxus/blob/master/packages/signals/README.md) (requires Dioxus from Git) to provide fine-grained mutation and component rerendering.
  - In the top `App` component, use `use_context_provider(cx, || Signal::new(AppState::new()));`
  - In inner components, use `let state: Signal<AppState> = *use_context(cx).unwrap();` to access the current state value.
  - Use `state.with_mut` to mutate the state in place.
  - Use `state.read().<field>` to render a component based on a field
    - Use `dioxus_signals::use_selector` to produce a derived signal
- [x] Component re-renders when only relevant subset of the state changes
- [ ] State modification that relies on a long-running blocking task
