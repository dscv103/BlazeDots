# SOPS-nix Setup for `dscv103/BlazeDots`

This guide combines the upstream [`sops-nix`](https://github.com/Mic92/sops-nix) instructions with the layout that already
exists in this repository. Follow the steps below to add encrypted secrets safely for the `blazar` NixOS host, and optionally
for Home Manager.

---

## 0. What the repository already provides

- The `flake.nix` input set includes `Mic92/sops-nix`, and the `blazar` host imports the module. You do **not** need to add the
  input again—just configure it.
- The install documentation already specifies where to place the host AGE key: `/var/lib/sops-nix/key.txt`. This guide continues
  to use that path.

> **TL;DR:** Inputs and module imports are already in place; you only need to provide keys, a `.sops.yaml` policy, and the
> appropriate `sops.*` option blocks.

---

## 1. Install the editing tooling and generate an AGE key

Install [`sops`](https://github.com/getsops/sops) and [`age`](https://github.com/FiloSottile/age) on your workstation. Then
create a personal editing key (AGE is recommended):

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

Alternative conversions (only if necessary):

```bash
# Convert an existing SSH ed25519 key to an age key
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"

# Generate a traditional GPG key instead of age
# gpg --full-generate-key
```

Display (or copy) the public key from the generated file—this is the value that starts with `age1`:

```bash
grep -m1 "public key" ~/.config/sops/age/keys.txt || true
# Alternatively, open the file directly and copy the public key printed by age-keygen
```

---

## 2. Install the decryption key on the host

The machine needs a local copy of the age key so it can decrypt secrets when you build or switch the system. Copy the key to the
location that the existing module expects:

```bash
sudo install -Dvm600 ~/.config/sops/age/keys.txt /var/lib/sops-nix/key.txt
```

If you employ impermanence, make sure the parent directory is persisted so the key is available early during boot (see §6).

---

## 3. Declare the repository SOPS policy (`.sops.yaml`)

Create `.sops.yaml` at the repository root. The policy should include the host key and your personal key so both parties can
decrypt.

```yaml
# .sops.yaml
creation_rules:
  - path_regex: secrets(\.ya?ml|\.json|\.env|\.ini|\.bin)?$
    # Allow this machine's age key and your personal editing key
    age: >-
      age1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX,
      age1YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
```

- Replace the first key with the host's **public** key (derived from `/var/lib/sops-nix/key.txt`).
- Replace the second key with your personal **public** key (copied in §1).

Only encrypted files (not plaintext secrets) should be committed to Git.

---

## 4. Create and encrypt your first secrets file

Start with YAML for clarity (SOPS also supports JSON, INI, dotenv, and binary formats):

```bash
sops secrets/secrets.yaml
```

> Create the `secrets/` directory if it does not already exist—this path matches the default defined in
> [`modules/core/common/sops.nix`](../modules/core/common/sops.nix).

Inside the editor opened by SOPS, insert the keys you need, such as:

```yaml
# secrets/secrets.yaml (SOPS appends its own metadata under `sops:`)
github:
  token: "temporary-value"
postgres:
  password: "temporary-value"
```

Save and exit. SOPS encrypts the file automatically based on `.sops.yaml`.

To mount an entire file rather than a single key, set `key = ""` in the Nix configuration (see §5.2).

---

## 5. Wire secrets into NixOS (system-wide)

The repository already imports the sops-nix module for `blazar`. Add your configuration in a file that is part of the `blazar`
host (for example, `hosts/blazar/default.nix` or a module imported from there).

### 5.1 Define individual secrets

```nix
{ config, lib, pkgs, ... }:
{
  # Point sops-nix to the machine's key file.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # Use the repo-local secrets file by default.
  sops.defaultSopsFile = ./secrets/secrets.yaml;

  # Declare each secret to materialize under /run/secrets.
  sops.secrets."github_token" = {
    # Optional: override file or format per secret (defaults to `defaultSopsFile` / YAML).
    # sopsFile = ./secrets/secrets.yaml;
    # format = "yaml";
    mode = "0400"; # Adjust owner/group as needed.
  };

  # Ensure consumer services start after secrets are decrypted.
  systemd.services."my-service".after = [ "sops-nix.service" ];
}
```

The decrypted files appear on `/run/secrets/<name>` (a tmpfs). Any services that need the secret should depend on
`sops-nix.service`.

### 5.2 Mount the entire encrypted document

```nix
{
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.secrets."my-config" = {
    format = "yaml";
    sopsFile = ./secrets/my-config.yaml; # encrypted via `sops secrets/my-config.yaml`
    key = "";                            # Empty string => take the entire document
  };
}
```

This creates `/run/secrets/my-config` containing the fully decrypted file.

### 5.3 Provide a secret for a user password

NixOS creates users before regular secrets are available. Mark such secrets with `neededForUsers = true` so they are decrypted to
`/run/secrets-for-users` in time.

```nix
{
  sops.secrets."dscv_password".neededForUsers = true;

  users.users.dscv = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."dscv_password".path;
  };
}
```

Generate the hashed password with `mkpasswd`:

```bash
echo "new-password" | mkpasswd -s
# Copy the resulting $y$j9T$... string into your secrets file.
```

---

## 6. Impermanence considerations

If you use impermanence, persist the key path so it is available during boot. For example:

```nix
{
  sops.age.keyFile = "/nix/persist/var/lib/sops-nix/key.txt";
}
```

Alternatively, if you rely on SSH host keys for decryption, ensure `/etc/ssh` is marked `neededForBoot`:

```nix
{
  fileSystems."/etc/ssh".neededForBoot = true;
}
```

The existing module already creates `/var/lib/sops-nix` with suitable permissions (see
[`modules/core/common/sops.nix`](../modules/core/common/sops.nix)).

---

## 7. Optional: Home Manager secrets

If you also want per-user secrets, import the Home Manager sops module and configure it under the user’s Home Manager
configuration:

```nix
{
  # When using Home Manager as a NixOS module:
  home-manager.sharedModules = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  # In `homes/<user>/home.nix`:
  sops = {
    age.keyFile = "/home/dscv/.age-key.txt"; # Must be unencrypted (no password)
    defaultSopsFile = ./secrets/home-secrets.yaml;

    secrets."imap_password".path = "%r/imap_pass.txt"; # Lands under $XDG_RUNTIME_DIR
  };
}
```

Home Manager decrypts to `$XDG_RUNTIME_DIR/secrets.d` and symlinks into `$HOME/.config/sops-nix/secrets`. Make sure
`home.homeDirectory` is defined so the evaluation knows the path, and order user services after the Home Manager
`sops-nix.service`.

---

## 8. Build, verify, and switch

Evaluate the flake and run a smoke build before switching:

```bash
nix flake metadata
sudo nixos-rebuild build --flake .#blazar
sudo nixos-rebuild switch --flake .#blazar
```

These commands match the installation workflow documented in the repository.

---

## 9. CI and commit hygiene

- Never commit plaintext secrets. Only encrypted files (e.g., `secrets/secrets.yaml`) and `.sops.yaml` should enter version control.
- When adding remote sources with `lib.fakeSha256`, replace the placeholder with a real hash:

  ```bash
  nix store prefetch-file "<URL>" --json | jq -r '.hash'
  ```

---

## 10. Quick checklist

Copy this list into your workflow as needed:

1. ✅ Generate an age key and copy its public key.
2. ✅ Copy the private key to `/var/lib/sops-nix/key.txt` on the host (permissions `600`).
3. ✅ Add `.sops.yaml` with both the host and personal age public keys.
4. ✅ Run `sops secrets/secrets.yaml`, add secret values, and save (they are encrypted automatically).
5. ✅ In the `blazar` configuration, set:
   - `sops.age.keyFile = "/var/lib/sops-nix/key.txt";`
   - `sops.defaultSopsFile = ./secrets/secrets.yaml;`
   - `sops.secrets."<name>" = { ... };`
6. ✅ For user passwords, mark the secret `neededForUsers = true` and set `users.users.<name>.hashedPasswordFile` to
   `config.sops.secrets."<name>".path`. Generate the hash with `mkpasswd`.
7. ✅ If impermanence is active, persist the key path (e.g., `/nix/persist/var/lib/sops-nix/key.txt`).
8. ✅ Run `sudo nixos-rebuild build --flake .#blazar`, then switch once the build succeeds.

---

## Notes and gotchas

- **System vs Home Manager:** system secrets live in `/run/secrets`, while Home Manager secrets live under
  `$XDG_RUNTIME_DIR/secrets.d` and symlink into `$HOME/.config/sops-nix/secrets`. Order dependent services after the respective
  `sops-nix.service` (systemd or systemd-user).
- **Whole-file mounts:** set `key = ""` to obtain the entire decrypted document.
- **Formats:** YAML, JSON, INI, dotenv, and binary files are supported.
