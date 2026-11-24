# Home Manager entry point: shared options plus every discovered role.
{ inputs, roles }:
{ lib, ... }:
{
  imports = [ inputs.lazyvim.homeManagerModules.default ] ++ builtins.attrValues roles.modules;

  options.opinionated.unfreePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = ''
      Unfree packages (by `lib.getName`) needed by the enabled roles. On NixOS
      they are collected into the system-level `opinionated.unfreePackages`.
    '';
  };

  options.opinionated.nixLd.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Whether the enabled roles run generic (non-Nix) Linux binaries, such as
      the VS Code server. On NixOS, `programs.nix-ld` is enabled when any user
      requests it.
    '';
  };

  config._module.args.opinionatedInputs = inputs;
}
