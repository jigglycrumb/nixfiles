{ pkgs ? import <nixpkgs> { } }:
let
  fhs = pkgs.buildFHSEnv {
    name = "picotron";
    targetPkgs = pkgs: (with pkgs; [
      xorg.libXrandr # for renderer
      libGL # for renderer
      alsa-lib # for audio
      udev # for gamepads
      curl # for cart downloads
    ]);
    runScript = "bash -c ./picotron";
  };
in
pkgs.stdenv.mkDerivation {
  name = "picotron-shell";
  nativeBuildInputs = [ fhs ];
  shellHook = ''
    exec picotron
  '';
}
