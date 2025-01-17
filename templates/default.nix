inputs: {
  templates = rec {
    # Simple nix flake with a stdenv.devShell and flake-utils
    simple = {
      path = ./simple;
      description = "nix flake new -t github:baetheus/.nix#simple .";
    };
    # Simple nix flake with numtide devShell and flake-utils
    devshell = {
      path = ./devshell;
      description = "nix flake new -t github:baetheus/.nix#devshell .";
    };
  };
}
