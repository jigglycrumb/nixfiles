# Infocom games home-manager module

This module installs an emulator for Infocom games, a small launcher script and cool-retro-term for CRT vibes.

## Installation

### Download

Download this folder.

### Enable and configure the module

In your home manager config (usually `home.nix`), add the following:

```nix
  imports = [
    <path-to>/infocom/infocom.nix
  ];

  modules.infocom.username = ""; # Required. Your system username.
  modules.infocom.games-path = ""; # Optional. Relative to ~. Default: `Games/Infocom/Games`
```

