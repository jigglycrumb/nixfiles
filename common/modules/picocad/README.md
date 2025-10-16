# picoCAD home-manager module

This module enables using [picoCAD](https://picocad.net/) and the picoCAD Toolbox with Nix [home-manager](https://nix-community.github.io/home-manager/).

## Installation

### Download

Download this folder.

### Enable and configure the module

In your home manager config (usually `home.nix`), add the following:

```nix
  import = [
    <path-to>/picocad/picocad.nnix
  ];

  modules.picocad.username = ""; # Required. Your system username.
  modules.picocad.app-path = ""; # Optional. Relative to ~. Default: `Applications/picocad`
```

### Install picoCAD

Buy picoCAD. Then, extract the downloaded zip file to the `app-path` (default: `Applications/picocad`).

## Running

Start picoCAD via your app launcher or with `picocad` in your terminal.
Start picoCAD Toolbox via your app launcher or with `picocad-toolbox` in your terminal.
