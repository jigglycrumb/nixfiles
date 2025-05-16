{ pkgs ? import <nixpkgs> { } }:
let
  fhs = pkgs.buildFHSEnv {
    name = "voxatron";
    targetPkgs = pkgs: (with pkgs; [
      udev
      libGL
    ]);
    runScript = "bash -c ./vox";
  };
in
pkgs.stdenv.mkDerivation {
  name = "voxatron-shell";
  nativeBuildInputs = [ fhs ];
  shellHook = ''
    export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"
    exec voxatron
  '';
}
