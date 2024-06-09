{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
  ];

  # grafana
  services.grafana = {
    enable = true;
    settings = {
      server = {
        # Listening Address
        http_addr = "128.140.36.120";
        # and Port
        http_port = 3001;
        # Grafana needs to know on which domain and URL it's running
        domain = "grafana.hagenest.dev";
        root_url =
          "https://grafana.hagenest.dev/"; # Not needed if it is `https://your.domain/`
      };
    };
  };

  # nginx reverse proxy
  services.nginx.virtualHosts."${config.services.grafana.settings.server.domain}" =
    {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://${
            toString config.services.grafana.settings.server.http_addr
          }:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };

    services.prometheus.exporters.node = {
    enable = true;
    port = 9000;
    # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
    enabledCollectors = [ "systemd" ];
    # /nix/store/zgsw0yx18v10xa58psanfabmg95nl2bb-node_exporter-1.8.1/bin/node_exporter  --help
    extraFlags = [ "--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" ];
  };

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "3s"; # "1m"
    scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [{
        targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
      }];
    }
    ];
  };

  services.invidious = {
    enable = true;
    address = "invidious.hagenest.dev";
    nginx.enable = true;
  };

  services.nginx.enable = true;

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@hagenest.dev";
  };

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 80 443 3001 ];
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "giraffe";
  networking.domain = "giraffe.hagenest.dev";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBaV5uQf63sCfXZIT0lt61sOhEYuJHLNNpNQ0ppXFo+/"
  ];
  system.stateVersion = "23.11";
}
