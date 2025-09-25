# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
_: {
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            start = "1MiB";
            size = "512MiB";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            type = "8300";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "subvol=@root"
                    "compress=zstd"
                    "noatime"
                    "ssd"
                  ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "subvol=@home"
                    "compress=zstd"
                    "noatime"
                    "ssd"
                  ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "subvol=@nix"
                    "compress=zstd"
                    "noatime"
                    "ssd"
                  ];
                };
                "@persist" = {
                  mountpoint = "/persist";
                  mountOptions = [
                    "subvol=@persist"
                    "compress=zstd"
                    "noatime"
                    "ssd"
                  ];
                };
                "@swap" = {
                  mountpoint = "/swap";
                  mountOptions = [
                    "subvol=@swap"
                    "noatime"
                    "ssd"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      priority = 0;
    }
  ];

  system.activationScripts."prepare-swap".text = ''
    if [ ! -f /swap/swapfile ]; then
      mkdir -p /swap
      chattr +C /swap || true
      fallocate -l 16G /swap/swapfile
      chmod 600 /swap/swapfile
      btrfs property set /swap/swapfile compression none || true
      mkswap /swap/swapfile
    fi
  '';
}
