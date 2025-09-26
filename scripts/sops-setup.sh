#!/usr/bin/env bash
# sops-setup.sh — Setup SOPS + age keys and repo policy from a YAML config
# Usage:
#   sudo ./sops-setup.sh -c /path/to/sops-setup.config.yaml [--force] [--dry-run] [--verbose]
#
# Exit codes: 0 success, non‑zero on failure.
#
set -Eeuo pipefail

VERSION="1.0.0"

# ---- helpers ---------------------------------------------------------------
log() { printf "[-] %s\n" "$*" >&2; }
info() { printf "[INFO] %s\n" "$*" >&2; }
warn() { printf "[WARN] %s\n" "$*" >&2; }
die() { printf "[ERR ] %s\n" "$*" >&2; exit 1; }

need_root() { [ "${EUID:-$(id -u)}" -eq 0 ] || die "Run as root (sudo)."; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || return 1; }

# If yq/sops/age-keygen are missing, try to re-exec inside a nix shell
ensure_tools() {
  local missing=()
  for c in yq sops age-keygen; do
    if ! need_cmd "$c"; then missing+=("$c"); fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    if need_cmd nix; then
      info "Missing tools: ${missing[*]}; attempting to re-exec via 'nix shell' (nixpkgs#sops nixpkgs#age nixpkgs#yq-go)..."
      exec nix shell -j 6 nixpkgs#sops nixpkgs#age nixpkgs#yq-go --command bash -c             "'$(readlink -f "$0")' $*"
    else
      die "Required tools not found: ${missing[*]}. Install: yq (mikefarah), sops, age."
    fi
  fi
}

usage() {
  cat <<'USAGE'
sops-setup.sh v'"$VERSION"'

Required:
  -c, --config <file>   YAML config file (see sample sops-setup.config.yaml)

Optional:
  -n, --dry-run         Print actions without changing anything
  -f, --force           Overwrite existing .sops.yaml (backup by default)
  -v, --verbose         Verbose output
  -h, --help            Show this help

Example:
  sudo ./sops-setup.sh -c ./sops-setup.config.yaml
USAGE
}

# ---- defaults --------------------------------------------------------------
CFG=""
DRYRUN=0
FORCE=0
VERBOSE=0

# ---- parse args ------------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    -c|--config) CFG="${2:-}"; shift 2;;
    -n|--dry-run) DRYRUN=1; shift;;
    -f|--force) FORCE=1; shift;;
    -v|--verbose) VERBOSE=1; shift;;
    -h|--help) usage; exit 0;;
    *) die "Unknown argument: $1";;
  esac
done

[ -n "$CFG" ] || { usage; die "Missing --config <file>"; }
[ -f "$CFG" ] || die "Config not found: $CFG"

need_root
ensure_tools "$@"

umask 077

yq_get() { yq -r "$1 // empty" "$CFG"; }
yq_bool() { yq -r "$1 // false" "$CFG"; }
yq_array() { yq -r "$1 // [] | .[]" "$CFG"; }

# ---- read config -----------------------------------------------------------
REPO_ROOT="$(yq_get '.repo.root')"; REPO_ROOT="${REPO_ROOT:-.}"
DOT_SOPS_PATH="$(yq_get '.policy.dot_sops_path')"; DOT_SOPS_PATH="${DOT_SOPS_PATH:-.sops.yaml}"
KEY_FILE="$(yq_get '.age.key_file')"; KEY_FILE="${KEY_FILE:-/var/lib/sops-nix/key.txt}"
AGE_GENERATE="$(yq_bool '.age.generate')"
AGE_SRC="$(yq_get '.age.private_key_src')"

PERSIST_ENABLE="$(yq_bool '.age.persist.enable')"
PERSIST_PATH="$(yq_get '.age.persist.path')"

mapfile -t ADD_RECIPS < <(yq_array '.additional_recipients[]?')
if [ ${#ADD_RECIPS[@]} -eq 0 ]; then
  warn "No additional_recipients provided; only the host key will be able to decrypt."
fi

# creation rule regexes
mapfile -t REGEXES < <(yq_array '.policy.path_regexes[]?')
if [ ${#REGEXES[@]} -eq 0 ]; then
  REGEXES=('secrets(\.ya?ml|\.json|\.env|\.ini|\.bin)?$')
fi

# bootstrap secrets
mapfile -t BS_PATHS < <(yq -r '.bootstrap_secrets[]?.path // empty' "$CFG")
mapfile -t BS_CREATE < <(yq -r '.bootstrap_secrets[]?.create // false' "$CFG")
mapfile -t BS_FORMAT < <(yq -r '.bootstrap_secrets[]?.format // ""' "$CFG")
mapfile -t BS_CONTENT < <(yq -r '.bootstrap_secrets[]?.content // ""' "$CFG")

# ---- functions -------------------------------------------------------------
do_run() {
  if [ "$DRYRUN" -eq 1 ]; then
    printf "[DRY] %s\n" "$*"
  else
    [ "$VERBOSE" -eq 1 ] && info "$*"
    eval "$@"
  fi
}

ensure_parent() {
  local p="$1"; local d; d="$(dirname "$p")"
  [ -d "$d" ] || do_run "install -d -m 755 '$d'"
}

# Generate or install age key; return recipient in HOST_RECIP
setup_age_key() {
  local target="$1"
  ensure_parent "$target"

  if [ -n "$AGE_SRC" ] && [ -f "$AGE_SRC" ]; then
    info "Copying provided age private key --> $target"
    do_run "install -m 600 -o root -g root -D '$AGE_SRC' '$target'"
  elif [ "$AGE_GENERATE" = "true" ] || [ ! -f "$target" ]; then
    info "Generating new age key at $target"
    ensure_parent "$target"
    if [ "$DRYRUN" -eq 1 ]; then
      HOST_RECIP="age1PLACEHOLDERGENERATEDKEY0000000000000000000000000"
      warn "Dry-run recipient is a placeholder; run without --dry-run to generate a real key."
    else
      # age-keygen prints the recipient to stderr; we capture and also write the private key
      local tmpkey; tmpkey="$(mktemp)"
      age-keygen -o "$tmpkey" 2> >(tee >(grep -m1 'public key:' | awk '{print $3}') >/tmp/.age_pubkey) 1>/dev/null
      do_run "install -m 600 -o root -g root -D '$tmpkey' '$target'"
      HOST_RECIP="$(cat /tmp/.age_pubkey)"
      rm -f "$tmpkey" /tmp/.age_pubkey
    fi
  else
    info "Existing age key found at $target; deriving recipient"
    if [ "$DRYRUN" -eq 1 ]; then
      HOST_RECIP="age1PLACEHOLDEREXISTINGKEYYYYYYYYYYYYYYYYYYYYYYYYYY"
    else
      HOST_RECIP="$(age-keygen -y "$target" | awk '/^public key:/{print $3}')"
    fi
  fi

  [ -n "${HOST_RECIP:-}" ] || die "Failed to derive host age public key"
  info "Host recipient: $HOST_RECIP"
}

write_dot_sops_yaml() {
  local dst="$1"
  local backup=""

  if [ -e "$dst" ] && [ "$FORCE" -ne 1 ]; then
    backup="${dst}.bak.$(date +%Y%m%d-%H%M%S)"
    warn "$dst exists; creating backup: $backup"
    do_run "cp -a '$dst' '$backup'"
  fi

  local tmp; tmp="$(mktemp)"
  {
    echo "creation_rules:"
    for re in "${REGEXES[@]}"; do
      echo "  - path_regex: "$re""
      echo "    age:"
      echo "      - "$HOST_RECIP""
      for r in "${ADD_RECIPS[@]}"; do
        [ -n "$r" ] && echo "      - "$r""
      done
    done
  } > "$tmp"

  do_run "install -D -m 644 '$tmp' '$dst'"
  rm -f "$tmp"
  info "Wrote $dst"
}

persist_key_if_needed() {
  if [ "$PERSIST_ENABLE" = "true" ] && [ -n "$PERSIST_PATH" ] && [ "$PERSIST_PATH" != "$KEY_FILE" ]; then
    info "Persisting key to $PERSIST_PATH (and keeping original path valid by symlink)"
    ensure_parent "$PERSIST_PATH"
    do_run "install -m 600 -o root -g root -D '$KEY_FILE' '$PERSIST_PATH'"
    do_run "rm -f '$KEY_FILE'"
    do_run "ln -s '$PERSIST_PATH' '$KEY_FILE'"
  fi
}

bootstrap_secret_files() {
  local count="${#BS_PATHS[@]}"
  [ "$count" -gt 0 ] || return 0

  for i in $(seq 0 $((count-1))); do
    local rel="${BS_PATHS[$i]}"
    [ -n "$rel" ] || continue
    local create="${BS_CREATE[$i]:-false}"
    local fmt="${BS_FORMAT[$i]:-}"
    local content="${BS_CONTENT[$i]:-}"
    local f="$REPO_ROOT/$rel"

    ensure_parent "$f"
    if [ ! -f "$f" ] && [ "$create" = "true" ]; then
      info "Creating bootstrap secret: $f"
      if [ -n "$content" ]; then
        if [ "$DRYRUN" -eq 1 ]; then
          printf "[DRY] write content -> %s\n" "$f"
        else
          printf "%s\n" "$content" > "$f"
        fi
      else
        # minimal YAML stub if format not specified
        if [ "$fmt" = "yaml" ] || [ -z "$fmt" ]; then
          [ "$DRYRUN" -eq 1 ] || printf "# placeholder secrets\n" > "$f"
        else
          [ "$DRYRUN" -eq 1 ] || : > "$f"
        fi
      fi
    fi

    if [ -f "$f" ]; then
      info "Encrypting (or refreshing recipients) for $f"
      if [ "$DRYRUN" -eq 1 ]; then
        printf "[DRY] SOPS_AGE_KEY_FILE='%s' sops --encrypt --in-place '%s'\n" "$KEY_FILE" "$f"
      else
        SOPS_AGE_KEY_FILE="$KEY_FILE" sops --encrypt --in-place "$f"
      fi
    else
      warn "Skipped $f (file missing and create=false)"
    fi
  done
}

# ---- main ------------------------------------------------------------------
info "Repo root  : $REPO_ROOT"
info ".sops.yaml : $DOT_SOPS_PATH"
info "Key file   : $KEY_FILE"

setup_age_key "$KEY_FILE"
persist_key_if_needed

# Render .sops.yaml at the repo root (or custom path if provided)
DOT_SOPS_ABS="$DOT_SOPS_PATH"
case "$DOT_SOPS_ABS" in
  /*) : ;;
  *) DOT_SOPS_ABS="$REPO_ROOT/$DOT_SOPS_PATH" ;;
esac
ensure_parent "$DOT_SOPS_ABS"
write_dot_sops_yaml "$DOT_SOPS_ABS"

bootstrap_secret_files

cat <<EOF
----------------------------------------------------------------
SOPS setup complete.
  • Key file     : $KEY_FILE
  • Host recip   : $HOST_RECIP
  • .sops.yaml   : $DOT_SOPS_ABS
  • Repo root    : $REPO_ROOT

Next steps:
  1) In your NixOS config, set:
       sops.age.keyFile = "${KEY_FILE}";
     and (optionally) sops.defaultSopsFile to one of your encrypted files.
  2) To edit a secret file:
       SOPS_AGE_KEY_FILE="${KEY_FILE}" sops <file>
  3) If using impermanence, ensure the key path persists and is available early at boot.
----------------------------------------------------------------
EOF
