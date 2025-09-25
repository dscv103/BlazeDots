# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ lib, ... }:
{
  sops = {
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
    defaultSopsFile = lib.mkDefault "secrets/secrets.yaml";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/sops-nix 0750 root root -"
  ];
}
