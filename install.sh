#!/usr/bin/env bash
# One-command installer for this Neovim config.
#
#   curl -fsSL https://raw.githubusercontent.com/FranciscoAz1/neovim/main/install.sh | bash
#
# Supported: apt-based systems (Debian, Raspberry Pi OS, Ubuntu) and Oracle
# Linux 9, on x86-64 and arm64. Safe to re-run: each step first checks what is
# already in place.
#
# The system-wide parts (packages, /opt/nvim, /usr/local/bin) need root, so
# sudo asks for your password once at the start. `... | sudo bash` works too:
# the config and plugins still go to the user who called sudo, not to root.
#
# Environment overrides (put them before `bash`, e.g. `... | SKIP_PACKAGES=1 bash`,
# or after `sudo`: `... | sudo SKIP_PACKAGES=1 bash`):
#   NVIM_VERSION         Neovim release tag            (default v0.12.4)
#   TREE_SITTER_VERSION  tree-sitter CLI release tag   (default v0.25.10)
#   NODEJS_STREAM        Oracle Linux nodejs module    (default 22)
#   NVIM_CONFIG_REPO     git URL the config is cloned from
#   NVIM_CONFIG_BRANCH   branch to check out           (default: the repo's default)
#   SKIP_PACKAGES=1      leave the system package manager alone
#   SKIP_BOOTSTRAP=1     don't start Neovim to install plugins and formatters

set -euo pipefail

NVIM_VERSION="${NVIM_VERSION:-v0.12.4}"
# v0.26+ needs glibc 2.39; Debian 12 has 2.36 and Oracle Linux 9 has 2.34.
TREE_SITTER_VERSION="${TREE_SITTER_VERSION:-v0.25.10}"
NODEJS_STREAM="${NODEJS_STREAM:-22}"
NVIM_CONFIG_REPO="${NVIM_CONFIG_REPO:-https://github.com/FranciscoAz1/neovim}"
NVIM_CONFIG_BRANCH="${NVIM_CONFIG_BRANCH:-}"
NVIM_PREFIX=/opt/nvim
BIN_DIR=/usr/local/bin

say() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

as_root() {
  if [ "$(id -u)" -eq 0 ]; then "$@"; else sudo "$@"; fi
}

# Run a command as the person the config is for. That is the current user,
# except under `sudo bash`, where it is whoever called sudo: their config must
# not end up in /root, nor be left owned by root in their home.
as_user() {
  if [ -n "$TARGET_USER" ]; then
    # sudo resets PATH (on Oracle Linux to one without /usr/local/bin), so
    # hand ours over; start in their home, since ours may be unreadable to them.
    sudo -H -u "$TARGET_USER" env "PATH=$PATH" sh -c 'cd "$HOME" && exec "$@"' sh "$@"
  else
    "$@"
  fi
}

need() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "'$cmd' is required but not installed."
  done
}

# "https://github.com/Owner/Repo.git" and "git@github.com:owner/repo" → "owner/repo"
repo_slug() {
  local url="${1%/}"
  url="${url%.git}"
  url="${url//://}"
  printf '%s\n' "$url" | awk -F/ '{ print tolower($(NF-1) "/" $NF) }'
}

# Prints the Node.js packages to request from the package manager: nothing
# when node and npm are already here. A node from somewhere else (NodeSource,
# nvm, ...) brings its own npm, and the distro's npm package then cannot be
# installed next to it — it depends on the distro's own nodejs version.
node_packages() {
  local major
  if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
    say "Node.js $(node --version 2>/dev/null) with npm is already installed — leaving it alone" >&2
    [ "$major" -ge 18 ] ||
      warn "That Node.js is older than 18; some language servers Mason installs may not run on it."
    return
  fi
  echo "nodejs npm"
}

install_packages_apt() {
  local node_pkgs
  node_pkgs="$(node_packages)"

  say "Installing system packages (apt)"
  as_root apt-get update
  # shellcheck disable=SC2086  # node_pkgs is deliberately split into words
  as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git build-essential curl unzip ripgrep python3-venv tmux $node_pkgs
}

install_packages_ol() {
  local major="${VERSION_ID%%.*}" node_pkgs
  [ "$major" = 9 ] || warn "Only Oracle Linux 9 has been checked; this is $VERSION_ID."
  node_pkgs="$(node_packages)"

  say "Installing system packages (dnf)"
  # ripgrep is only in EPEL
  as_root dnf install -y "oracle-epel-release-el${major}"
  # The default nodejs is 16, too old for the language servers Mason installs.
  # Leave an existing node alone: switching module streams under it would fail.
  if [ -n "$node_pkgs" ] && ! command -v node >/dev/null 2>&1; then
    as_root dnf module enable -y "nodejs:${NODEJS_STREAM}" ||
      warn "Could not enable the nodejs:${NODEJS_STREAM} module; using whichever stream is active."
  fi
  # curl is left out on purpose: minimal images ship curl-minimal, which
  # conflicts with the full package. python3 already includes venv.
  # shellcheck disable=SC2086  # node_pkgs is deliberately split into words
  as_root dnf install -y \
    git gcc gcc-c++ make unzip tar gzip ripgrep python3 python3-pip tmux $node_pkgs
}

install_packages() {
  if [ -n "${SKIP_PACKAGES:-}" ]; then
    say "Skipping system packages (SKIP_PACKAGES is set)"
    return
  fi
  [ -r /etc/os-release ] || die "Cannot identify this system: /etc/os-release is missing."
  # shellcheck disable=SC1091
  . /etc/os-release
  case " ${ID:-} ${ID_LIKE:-} " in
    *" debian "* | *" ubuntu "*) install_packages_apt ;;
    *" ol "*) install_packages_ol ;;
    *)
      die "Unsupported distribution '${ID:-unknown}'. Install the packages listed in the README by hand, then re-run with SKIP_PACKAGES=1."
      ;;
  esac
}

install_neovim() {
  local want="${NVIM_VERSION#v}" have="" url
  if command -v nvim >/dev/null 2>&1; then
    have="$(nvim --version 2>/dev/null | sed -n '1s/^NVIM v//p' || true)"
  fi
  if [ "$have" = "$want" ]; then
    say "Neovim $NVIM_VERSION is already installed"
    NVIM_BIN="$(command -v nvim)"
    return
  fi

  say "Installing Neovim $NVIM_VERSION to $NVIM_PREFIX${have:+ (found $have)}"
  url="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz"
  curl -fSL --progress-bar -o "$TMP/nvim.tar.gz" "$url"

  # Prove the binary runs here before replacing anything
  mkdir "$TMP/nvim"
  tar -C "$TMP/nvim" --strip-components=1 -xzf "$TMP/nvim.tar.gz"
  "$TMP/nvim/bin/nvim" --version >/dev/null ||
    die "The Neovim $NVIM_VERSION build does not run on this system (glibc too old?)."

  as_root rm -rf "$NVIM_PREFIX"
  as_root mkdir -p "$NVIM_PREFIX" "$BIN_DIR"
  as_root tar -C "$NVIM_PREFIX" --strip-components=1 --no-same-owner -xzf "$TMP/nvim.tar.gz"
  as_root ln -sfn "$NVIM_PREFIX/bin/nvim" "$BIN_DIR/nvim"
  NVIM_BIN="$BIN_DIR/nvim"
}

install_tree_sitter() {
  local want="${TREE_SITTER_VERSION#v}" have="" url
  if command -v tree-sitter >/dev/null 2>&1; then
    have="$(tree-sitter --version 2>/dev/null || true)"
  fi
  case "$have" in
    *"$want"*)
      say "tree-sitter CLI $TREE_SITTER_VERSION is already installed"
      return
      ;;
  esac

  say "Installing tree-sitter CLI $TREE_SITTER_VERSION to $BIN_DIR"
  url="https://github.com/tree-sitter/tree-sitter/releases/download/${TREE_SITTER_VERSION}/tree-sitter-linux-${TS_ARCH}.gz"
  curl -fsSL "$url" | gunzip >"$TMP/tree-sitter"
  chmod +x "$TMP/tree-sitter"
  "$TMP/tree-sitter" --version >/dev/null ||
    die "tree-sitter $TREE_SITTER_VERSION does not run on this system (glibc too old?)."
  as_root mkdir -p "$BIN_DIR"
  as_root install -m 0755 "$TMP/tree-sitter" "$BIN_DIR/tree-sitter"
}

install_config() {
  local dir="$CONFIG_HOME/nvim" origin backup

  if [ -d "$dir/.git" ]; then
    origin="$(as_user git -C "$dir" remote get-url origin 2>/dev/null || true)"
    if [ -n "$origin" ] && [ "$(repo_slug "$origin")" = "$(repo_slug "$NVIM_CONFIG_REPO")" ]; then
      say "Config already cloned at $dir — updating"
      as_user git -C "$dir" pull --ff-only ||
        warn "Could not fast-forward $dir (local changes?). Left as it is."
      return
    fi
  fi

  if [ -e "$dir" ] || [ -L "$dir" ]; then
    backup="$dir.bak.$(date +%Y%m%d-%H%M%S)"
    say "Moving the existing config to $backup"
    as_user mv "$dir" "$backup"
  fi

  say "Cloning the config to $dir"
  as_user mkdir -p "$(dirname "$dir")"
  if [ -n "$NVIM_CONFIG_BRANCH" ]; then
    as_user git clone --branch "$NVIM_CONFIG_BRANCH" "$NVIM_CONFIG_REPO" "$dir"
  else
    as_user git clone "$NVIM_CONFIG_REPO" "$dir"
  fi
}

bootstrap() {
  if [ -n "${SKIP_BOOTSTRAP:-}" ]; then
    say "Skipping plugin install (SKIP_BOOTSTRAP is set)"
    return
  fi

  # A failure in here is reported and skipped rather than fatal: everything
  # these steps do can be repeated from inside Neovim.
  local status

  say "Installing plugins at the commits pinned in lazy-lock.json"
  status=0
  as_user "$NVIM_BIN" --headless "+Lazy! restore" +qa || status=$?
  echo # headless Neovim does not end its output with a newline
  [ "$status" -eq 0 ] || warn "Plugin install did not finish cleanly — run :Lazy inside Neovim."

  # Language servers are in the config's ensure_installed; formatters are not.
  say "Installing formatters (prettier, stylua, ruff)"
  status=0
  as_user "$NVIM_BIN" --headless "+Lazy! load mason.nvim" "+MasonInstall prettier stylua ruff" +qa || status=$?
  echo
  [ "$status" -eq 0 ] ||
    warn "Formatter install did not finish cleanly — run :MasonInstall prettier stylua ruff inside Neovim."
}

main() {
  [ "$(uname -s)" = Linux ] || die "This installer only supports Linux."

  case "$(uname -m)" in
    x86_64 | amd64)
      NVIM_ARCH=x86_64
      TS_ARCH=x64
      ;;
    aarch64 | arm64)
      NVIM_ARCH=arm64
      TS_ARCH=arm64
      ;;
    *) die "Unsupported CPU architecture '$(uname -m)': Neovim publishes no release build for it." ;;
  esac

  # Who the config is for, and where it goes
  local target_home
  TARGET_USER=""
  CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
  if [ "$(id -u)" -ne 0 ]; then
    need sudo
    say "Root is needed for the system packages, $NVIM_PREFIX and $BIN_DIR — sudo may ask for your password"
    sudo -v || die "Could not get root through sudo. Is $(id -un) allowed to use it?"
  elif [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != root ]; then
    # Started as `sudo bash`: root for the system parts, the caller for the rest
    TARGET_USER="$SUDO_USER"
    target_home="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
    [ -n "$target_home" ] || die "Cannot find the home directory of '$TARGET_USER'."
    CONFIG_HOME="$target_home/.config"
    say "Running under sudo: the config and plugins are installed for $TARGET_USER"
  fi

  # A root shell's PATH can lack $BIN_DIR (sudo's secure_path on Oracle Linux
  # does), which would hide the nvim and tree-sitter this script installs.
  case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) PATH="$BIN_DIR:$PATH" ;;
  esac
  export PATH

  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT

  install_packages
  need curl git tar gunzip
  install_neovim
  install_tree_sitter
  install_config
  bootstrap

  say "Done"
  [ -z "$TARGET_USER" ] || echo "Installed for $TARGET_USER, in $CONFIG_HOME/nvim."
  cat <<'EOF'
Start it with:  nvim

Still to happen on that first interactive launch:
  - tree-sitter parsers compile in the background (several minutes on a Pi)
  - language servers install the first time you open a file — watch :Mason

Not installed by this script: lazygit (<leader>gg), the claude CLI
(<leader>cc), a Nerd Font and ~/.tmux.conf. See the README.
EOF
}

# Nothing runs until the whole file has been read, so a download that is cut
# off part-way cannot execute half a script. stdin is detached so no command
# can swallow the rest of the script when it arrives through a pipe.
main "$@" </dev/null
