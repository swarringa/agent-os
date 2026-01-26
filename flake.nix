{
  description = "Agent OS - Agents that build the way you would";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
      scriptDir = ./. + "/scripts"; # Path to scripts folder
      scriptNames = builtins.attrNames (builtins.readDir scriptDir);
      
      # Create a script wrapper for each file in scripts/
      scriptBinaries = builtins.listToAttrs (map (name: {
        name = name;
        value = pkgs.writeShellScriptBin name ''
          ${builtins.readFile (scriptDir + ("/" + name))}
        '';
      }) scriptNames);
    in {
      packages.agent-os = pkgs.symlinkJoin {
        name = "agent-os";
        paths = builtins.attrValues scriptBinaries;
        buildInputs = [ pkgs.makeWrapper ];
      };

      # Optional: make it the default package
      defaultPackage = self.packages.${system}.agent-os;
    });
}   
