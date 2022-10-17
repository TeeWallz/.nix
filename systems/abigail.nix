{ config, pkgs, ... }:

{
  imports = [
    ./bundles/sys-1-sat-32.nix
    ./modules/fossil.nix
  ];

  # General
  system.stateVersion = "22.05";

  networking.hostName = "abigail";
  networking.hostId = "a9a768fa";
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  # Secrets
  age.secrets.vaultwarden.file = ../secrets/vaultwarden.age;

  # Nginx
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "admin@null.pub";

  services.nginx = {
    enable = true;

    virtualHosts = {
      "abigail.null.pub" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www/abigail.null.pub";
          extraConfig = "autoindex on;";
        };
      };

      "code.null.pub" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          extraConfig = ''
            include ${pkgs.nginx}/conf/scgi_params;
            scgi_pass 127.0.0.1:${toString config.services.fossil.port};
            scgi_param HTTPS "on";
            scgi_param SCRIPT_NAME "";
          '';
        };
      };

      "vault.null.pub" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8000";
        };
        locations."/notifications/hub" = {
          proxyPass = "http://127.0.0.1:3012";
          proxyWebsockets = true;
        };
      };

      "net.null.pub" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/metrics" = {
            proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
            extraConfig = ''
              allow 100.64.0.0/16;
              deny all;
            '';
            priority = 2;
          };

          "/" = {
            proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
            extraConfig = ''
              keepalive_requests          100000;
              keepalive_timeout           160s;
              proxy_buffering             off;
              proxy_connect_timeout       75;
              proxy_ignore_client_abort   on;
              proxy_read_timeout          900s;
              proxy_send_timeout          600;
              send_timeout                600;
            '';
            priority = 99;
          };
        };
      };
    };
  };
  
  # Fossil
  services.fossil = {
    enable = true;
    repolist = true;
    scgi = true;
    git = pkgs.git;
  };

  # Headscale
  environment.systemPackages = with pkgs; [ headscale ];

  services.headscale = {
    enable = true;
    serverUrl = "https://net.null.pub";

    dns = {
      magicDns = true;
      nameservers = [ "1.1.1.1" ];
      domains = [ "rou.st" ];
      base_domain = "rou.st";
    };
  };

  # Provides a private bitwarden server
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vault.null.pub";
      WEBSOCKET_ENABLED = "true";
      SIGNUPS_ALLOWED = "false";
    };
    environmentFile = config.age.secrets.vaultwarden.path;
  };
}
