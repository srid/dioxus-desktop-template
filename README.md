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
    - [ ] Simple `nix build` / `nix run`
    - [ ] Nix package containing macOS app bundle
- [x] Tailwind
- [ ] macOS bundling
- [x] Routes & navigation
- [ ] Application state

## Getting Starred

In the `nix develop` shell, run:

```
just watch
```

We do not have Nix builds yet; see tasks above.
