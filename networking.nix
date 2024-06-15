{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers =
      [ "2a01:4ff:ff00::add:1" "2a01:4ff:ff00::add:2" "185.12.64.2" ];
    defaultGateway = "172.31.1.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [{
          address = "128.140.36.120";
          prefixLength = 32;
        }];
        ipv6.addresses = [
          {
            address = "2a01:4f8:1c1b:7ea4::1";
            prefixLength = 64;
          }
          {
            address = "fe80::9400:3ff:fe64:b351";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [{
          address = "172.31.1.1";
          prefixLength = 32;
        }];
        ipv6.routes = [{
          address = "fe80::1";
          prefixLength = 128;
        }];
      };

    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="96:00:03:64:b3:51", NAME="eth0"

  '';
}
