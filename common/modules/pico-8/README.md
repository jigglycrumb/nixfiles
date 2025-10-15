# PICO-8 home-manager module

This module enables using [PICO-8](https://www.lexaloffle.com/pico-8.php) with Nix [home-manager](https://nix-community.github.io/home-manager/).

## Installation

### Download

Download this folder.

### Enable and configure the module

In your home manager config (usually `home.nix`), add the following:

```nix
  imports = [
    <path-to>/pico-8/pico-8.nix
  ];

  modules.pico-8.username = "<your username>"; # required
  modules.pico-8.app-path = ""; # optional, default: `Applications/pico-8`
  modules.pico-8.cart-path = ""; # optional, default: `.lexaloffle/pico-8/carts`
```

### Install PICO-8

Buy PICO-8. Then, extract the downloaded zip file to the `app-path` (default: `Applications/pico-8`).

## Running

Start PICO-8 via your app launcher or with `pico8` in your terminal.
