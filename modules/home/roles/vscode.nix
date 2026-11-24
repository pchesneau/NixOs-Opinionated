# VS Code role: tooling used by VS Code (Remote - WSL or native), and optionally
# the editor itself with declarative extensions.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.opinionated.roles.vscode;
in
{
  options.opinionated.roles.vscode = {
    enable = lib.mkEnableOption "the VS Code role (language servers, optional editor)";

    package.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to install VS Code and manage its extensions declaratively.
        Leave disabled on WSL when VS Code runs on Windows (Remote - WSL):
        only the language servers are then provided.
      '';
    };

    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.vscode-extensions.redhat.java ]";
      description = "Extensions installed when `package.enable` is set. Other roles append to this list.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        opinionated.nixLd.enable = true;
        # Language servers picked up by the editor from $PATH.
        home.packages = [
          pkgs.nil
          pkgs.nixfmt-rfc-style
          pkgs.jdt-language-server
        ];
        opinionated.roles.vscode.extensions = with pkgs.vscode-extensions; [
          jnoortheen.nix-ide
          redhat.java
          vscjava.vscode-java-debug
          vscjava.vscode-maven
        ];
      }
      (lib.mkIf cfg.package.enable {
        programs.vscode = {
          enable = true;
          profiles.default = {
            extensions = cfg.extensions;
            userSettings = {
              "editor.formatOnSave" = true;
              "nix.enableLanguageServer" = true;
              "nix.serverPath" = "nil";
            };
          };
        };
        opinionated.unfreePackages = [ "vscode" ];
      })
    ]
  );
}
