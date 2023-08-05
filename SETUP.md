
1. Boot into NixOS
2. In the machine
   1. `passwd`
   2. `ip addr` - find the IP
  #ssh
  services.openssh.enable = true;
1. ssh nixos@ip
2. `nixos-rebuild switch --flake github:TeeWallz/.nix#zamorak`