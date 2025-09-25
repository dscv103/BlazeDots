# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
_: {
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/log"
    ];
    files = [
      "/etc/adjtime"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    users."dscv" = {
      directories = [
        "Documents"
        "Downloads"
        "Projects"
        "src"
        ".config/niri"
        ".config/sops"
        ".local/share/containers"
      ];
    };
  };
}
