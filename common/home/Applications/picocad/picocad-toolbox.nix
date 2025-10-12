{ pkgs ? import <nixpkgs> { } }:
let
  fhs = pkgs.buildFHSEnv {
    name = "picocad-toolbox";
    targetPkgs = pkgs: (with pkgs; [
      xorg.libX11
      xorg.libXext
      xorg.libXcursor
      xorg.libXinerama
      xorg.libXi
      xorg.libXrandr
      xorg.libXScrnSaver
      xorg.libXxf86vm
      xorg.libxcb
      xorg.libXrender
      xorg.libXfixes
      xorg.libXau
      xorg.libXdmcp
      alsa-lib
      udev
      SDL2
    ]);
    runScript = "bash -c ./toolbox/toolbox";
  };
in
pkgs.stdenv.mkDerivation {
  name = "picocad-toolbox-shell";
  nativeBuildInputs = [ fhs ];
  shellHook = ''
    exec picocad-toolbox
  '';
}
