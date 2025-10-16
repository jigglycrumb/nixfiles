# voxatron home-manager module

This module enables using [voxatron](https://www.lexaloffle.com/voxatron.php) with Nix [home-manager](https://nix-community.github.io/home-manager/).

## Installation

### Download

Download this folder.

### Enable and configure the module

In your home manager config (usually `home.nix`), add the following:

```nix
  import = [
    <path-to>/voxatron/voxatron.nix
  ];

  modules.voxatron.username = ""; # Required. Your system username.
  modules.voxatron.app-path = ""; # Optional. Relative to ~. Default: `Applications/voxatron`
```

### Install voxatron

Buy voxatron. Then, extract the downloaded zip file to the `app-path` (default: `Applications/voxatron`).

## Running

Start voxatron via your app launcher or with `voxatron` in your terminal.
