# Picotron home-manager module

This module enables using [Picotron](https://www.lexaloffle.com/picotron.php) with Nix [home-manager](https://nix-community.github.io/home-manager/).

## Installation

### Download

Download this folder.

### Enable and configure the module

In your home manager config (usually `home.nix`), add the following:

```nix
  imports = [
    <path-to>/picotron/picotron.nix
  ];

  modules.picotron.username = ""; # Required. Your system username.
  modules.picotron.app-path = ""; # Optional. Relative to ~. Default: `Applications/picotron`
```

### Install Picotron

Buy Picotron. Then, extract the downloaded zip file to the `app-path` (default: `Applications/picotron`).

## Running

Start Picotron via your app launcher or with `picotron` in your terminal.
