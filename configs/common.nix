{ pkgs, ... }: {
  # Nix
  nix = {
    package = pkgs.nixUnstable;

    settings = {
      trustedUsers = [ "@wheel" ];
      substituters = [
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      auto-optimise-store = true;
    };

    gc = {
      automatic = true;

    };

    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  # We like one timezone to rule them all, might as well be mine
  time.timeZone = "America/Los_Angeles";

  # Just the basics
  environment.systemPackages = with pkgs; [ vim wget git ];
}
