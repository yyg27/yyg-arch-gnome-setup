#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# YYG ENDEAVOUROS / ARCH LINUX SYSTEM SETUP
# ============================================================

readonly SCRIPT_NAME="YYG System Setup"
readonly NVM_INSTALLER_VERSION="v0.40.3"

readonly STEPS=(
    system
    packages
    aur
    node
    shell
    font
    terminal
    gnome
    extensions
    nautilus
    git
    ssh
)

readonly PACKAGES=(
    base-devel
    git
    curl
    unzip
    zsh
    fastfetch
    python
    python-pip
    openssh
    gnome-terminal
)

readonly KEYBINDINGS_SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
readonly KEYBINDING_SCHEMA="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
readonly KEYBINDING_BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# id | name | command | binding
readonly CUSTOM_SHORTCUTS=(
    "yyg-vscode|VS Code|code|<Super>c"
    "yyg-terminal|GNOME Terminal|gnome-terminal|<Super>t"
    "yyg-files|File Manager|nautilus|<Super>e"
    "yyg-firefox|Firefox|firefox|<Super>w"
    "yyg-music|Youtube Music|youtubemusic|<Super>m"
)

# schema | key | value
readonly SYSTEM_SHORTCUTS=(
    "org.gnome.shell.keybindings|toggle-message-tray|['<Super>v']"
    "org.gnome.desktop.wm.keybindings|close|['<Super>q', '<Alt>F4']"
    "org.gnome.desktop.wm.keybindings|toggle-fullscreen|['<Super>f', 'F11']"
    "org.gnome.desktop.wm.keybindings|toggle-maximized|['<Super>g', '<Super>Up', '<Alt>F10']"
)

# extensions.gnome.org UUIDs
readonly GNOME_EXTENSIONS=(
    dash-to-dock@micxgx.gmail.com
    user-theme@gnome-shell-extensions.gcampax.github.com
    appindicatorsupport@rgcjonas.gmail.com
    blur-my-shell@aunetx
    caffeine@patapon.info
    just-perfection-desktop@just-perfection
    gsconnect@andyholmes.github.io
    ding@rastersoft.com
    lockkeys@vaina.lt
    Vitals@CoreCoding.com
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly EXTENSIONS_DCONF="$SCRIPT_DIR/gnome-extensions.dconf"

readonly ZSHRC_MARKER="# YYG ZSH CONFIGURATION"
readonly BASH_MARKER="# YYG: Automatically switch interactive Bash sessions to Zsh"

BACKUP_DIR="$HOME/.yyg-setup-backups/$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$BACKUP_DIR/setup.log"

DRY_RUN=false
ONLY=""
SKIP=""
GIT_USERNAME=""
GIT_EMAIL=""
SUDO_KEEPALIVE_PID=""
HAS_GSETTINGS=false

# ============================================================
# Helpers
# ============================================================

log() {
    echo
    echo "==> $1"
}

success() {
    echo "    ✓ $1"
}

warning() {
    echo "    ! $1"
}

fail() {
    echo "    ✗ $1" >&2
    exit 1
}

# Runs a command, or only prints it in dry-run mode.
run() {
    if $DRY_RUN; then
        echo "    [dry-run] $*"
    else
        "$@"
    fi
}

# Writes stdin to a file, or only reports it in dry-run mode.
write_file() {
    if $DRY_RUN; then
        cat >/dev/null
        echo "    [dry-run] write $1"
    else
        cat >"$1"
    fi
}

append_file() {
    if $DRY_RUN; then
        cat >/dev/null
        echo "    [dry-run] append to $1"
    else
        cat >>"$1"
    fi
}

in_dir() {
    local dir="$1"
    shift
    (cd "$dir" && "$@")
}

download() {
    run curl -fsSL -o "$2" "$1"
}

clone_repo() {
    local url="$1" dest="$2" name="$3"

    if [[ -d "$dest" ]]; then
        success "$name is already installed."
    else
        run git clone --depth=1 "$url" "$dest"
        success "$name installed."
    fi
}

backup_file() {
    if [[ -f "$1" ]]; then
        run mkdir -p "$BACKUP_DIR"
        run cp "$1" "$BACKUP_DIR/"
        success "$(basename "$1") backed up."
    fi
}

# Prints the items of a gsettings string list, one per line.
gsettings_list() {
    local raw

    raw="$(gsettings get "$1" "$2")"
    raw="${raw#@as }"
    raw="${raw//[\[\]\' ]/}"

    tr ',' '\n' <<<"$raw" | sed '/^$/d'
}

# Formats the arguments as a GVariant string list.
to_gvariant_list() {
    local list

    [[ $# -gt 0 ]] || { echo "@as []"; return; }

    list="$(printf "'%s', " "$@")"
    echo "[${list%, }]"
}

contains() {
    [[ ",$1," == *",$2,"* ]]
}

should_run() {
    if [[ -n "$ONLY" ]]; then
        contains "$ONLY" "$1"
    elif contains "$SKIP" "$1"; then
        return 1
    fi
}

validate_steps() {
    local step

    for step in ${1//,/ }; do
        contains "$(IFS=,; echo "${STEPS[*]}")" "$step" ||
            fail "Unknown step: $step (available: ${STEPS[*]})"
    done
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --dry-run          Show what would be done without changing anything
  --only <steps>     Run only the given comma-separated steps
  --skip <steps>     Skip the given comma-separated steps
  -h, --help         Show this help

Steps: ${STEPS[*]}

Examples:
  $(basename "$0") --dry-run
  $(basename "$0") --only shell,font
  $(basename "$0") --skip node,aur
EOF
}

start_sudo_keepalive() {
    sudo -v

    while true; do
        sudo -n true
        sleep 50
        kill -0 "$$" 2>/dev/null || exit
    done 2>/dev/null &

    SUDO_KEEPALIVE_PID=$!
}

cleanup() {
    if [[ -n "$SUDO_KEEPALIVE_PID" ]]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    fi
}

trap cleanup EXIT
trap 'echo; echo "✗ An error occurred during setup."; echo "  Line: $LINENO"; echo "  Command: $BASH_COMMAND"; exit 1' ERR

# ============================================================
# Arguments
# ============================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            ;;
        --only)
            [[ $# -ge 2 ]] || fail "--only requires a value."
            ONLY="$2"
            shift
            ;;
        --skip)
            [[ $# -ge 2 ]] || fail "--skip requires a value."
            SKIP="$2"
            shift
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            fail "Unknown option: $1"
            ;;
    esac
    shift
done

if [[ -n "$ONLY" && -n "$SKIP" ]]; then
    fail "--only and --skip cannot be used together."
fi

validate_steps "$ONLY"
validate_steps "$SKIP"

# ============================================================
# Header
# ============================================================

if ! $DRY_RUN; then
    mkdir -p "$BACKUP_DIR"
    exec > >(tee -a "$LOG_FILE") 2>&1
fi

echo
echo "=========================================="
echo " $SCRIPT_NAME"
if $DRY_RUN; then
    echo " (dry-run: nothing will be changed)"
fi
echo "=========================================="

# ============================================================
# 0. Pre-flight
# ============================================================

log "Checking system..."

if [[ $EUID -eq 0 ]]; then
    fail "Do not run this script as root. It uses sudo when needed."
fi

if [[ ! -f /etc/os-release ]]; then
    fail "/etc/os-release not found."
fi

# shellcheck source=/dev/null
source /etc/os-release

if [[ "${ID:-}" != "arch" && "${ID_LIKE:-}" != *"arch"* ]]; then
    fail "This script is designed only for Arch Linux / EndeavourOS systems."
fi

success "Arch-based system: ${PRETTY_NAME:-Unknown}"

if command -v gsettings >/dev/null 2>&1; then
    HAS_GSETTINGS=true
else
    warning "gsettings not found. GNOME steps will be skipped."
fi

if should_run git; then

    if command -v git >/dev/null 2>&1; then
        GIT_USERNAME="$(git config --global user.name || true)"
        GIT_EMAIL="$(git config --global user.email || true)"
    fi

    if [[ -n "$GIT_USERNAME" && -n "$GIT_EMAIL" ]]; then

        success "Existing Git identity: $GIT_USERNAME <$GIT_EMAIL>"

    elif $DRY_RUN; then

        GIT_USERNAME="${GIT_USERNAME:-<username>}"
        GIT_EMAIL="${GIT_EMAIL:-<email>}"

    else

        echo
        read -r -p "Enter your Git Username (e.g. yyg27): " GIT_USERNAME </dev/tty
        read -r -p "Enter your Git Email Address: " GIT_EMAIL </dev/tty

        [[ -n "$GIT_USERNAME" ]] || fail "Git username cannot be empty."
        [[ -n "$GIT_EMAIL" ]] || fail "Git email address cannot be empty."

    fi

fi

if ! $DRY_RUN && { should_run system || should_run packages || should_run aur || should_run shell; }; then
    log "Requesting sudo access..."
    start_sudo_keepalive
    success "sudo access granted."
fi

# ============================================================
# 1. System Update
# ============================================================

if should_run system; then

    log "Updating system..."

    run sudo pacman -Syu --noconfirm

    success "System updated."

fi

# ============================================================
# 2. Required System Packages
# ============================================================

if should_run packages; then

    log "Installing required system packages..."

    run sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

    success "Base packages ready."

fi

# ============================================================
# 3. Yay & Yayy
# ============================================================

if should_run aur; then

    log "Preparing Yay and Yayy..."

    TMP_DIR="$(mktemp -d)"

    if ! command -v yay >/dev/null 2>&1; then
        run git clone https://aur.archlinux.org/yay-bin.git "$TMP_DIR/yay-bin"
        run in_dir "$TMP_DIR/yay-bin" makepkg -si --noconfirm
        success "Yay installed."
    else
        success "Yay is already installed."
    fi

    download https://raw.githubusercontent.com/yyg27/yayy/main/install.sh "$TMP_DIR/yayy-install.sh"
    run bash "$TMP_DIR/yayy-install.sh"
    success "Yayy CLI installed."

    rm -rf "$TMP_DIR"

fi

# ============================================================
# 4. NVM, Node.js LTS & NestJS CLI
# ============================================================

if should_run node; then

    log "Preparing NVM..."

    export NVM_DIR="$HOME/.nvm"

    if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
        echo "    NVM not found, installing..."
        TMP_FILE="$(mktemp)"
        download "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_INSTALLER_VERSION}/install.sh" "$TMP_FILE"
        run bash "$TMP_FILE"
        rm -f "$TMP_FILE"
    else
        success "NVM is already installed."
    fi

    if [[ -s "$NVM_DIR/nvm.sh" ]]; then

        # NVM is not compatible with nounset.
        set +u
        # shellcheck source=/dev/null
        source "$NVM_DIR/nvm.sh"

        success "NVM: $(nvm --version)"

        log "Preparing Node.js LTS..."

        run nvm install --lts
        run nvm alias default 'lts/*'
        run nvm use --lts

        log "Checking NestJS CLI..."

        if command -v nest >/dev/null 2>&1; then
            success "NestJS CLI is already installed: $(nest --version)"
        else
            run npm install -g @nestjs/cli
            success "NestJS CLI installed."
        fi

        set -u

    elif $DRY_RUN; then
        warning "NVM is not installed yet, skipping Node.js steps in dry-run."
    else
        fail "NVM installation failed."
    fi

fi

# ============================================================
# 5. Zsh, Oh My Zsh & Powerlevel10k
# ============================================================

if should_run shell; then

    log "Preparing Oh My Zsh, plugins and Powerlevel10k..."

    ZSH_DIR="$HOME/.oh-my-zsh"

    clone_repo https://github.com/ohmyzsh/ohmyzsh.git \
        "$ZSH_DIR" "Oh My Zsh"
    clone_repo https://github.com/zsh-users/zsh-autosuggestions.git \
        "$ZSH_DIR/custom/plugins/zsh-autosuggestions" "zsh-autosuggestions"
    clone_repo https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_DIR/custom/plugins/zsh-syntax-highlighting" "zsh-syntax-highlighting"
    clone_repo https://github.com/romkatv/powerlevel10k.git \
        "$ZSH_DIR/custom/themes/powerlevel10k" "Powerlevel10k"

    # --------------------------------------------------------
    # .zshrc
    # --------------------------------------------------------

    log "Configuring ~/.zshrc..."

    backup_file "$HOME/.zshrc"

    write_file "$HOME/.zshrc" <<EOF
$ZSHRC_MARKER
# ============================================================
# This file is managed by yyg-setup.sh and is overwritten on
# every run. Put personal changes in ~/.zshrc.local instead.
# ============================================================
EOF
    append_file "$HOME/.zshrc" <<'EOF'

# Disable Powerlevel10k instant prompt.
# This allows Fastfetch / startup output without warnings.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
fi

if [[ -s "$NVM_DIR/bash_completion" ]]; then
    source "$NVM_DIR/bash_completion"
fi

# Compatibility alias
alias neofetch='fastfetch'

# Powerlevel10k configuration
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# Personal configuration
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Fastfetch
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi
EOF

    success ".zshrc created."

    if [[ ! -f "$HOME/.zshrc.local" ]]; then
        write_file "$HOME/.zshrc.local" <<'EOF'
# Personal Zsh configuration.
# This file is sourced by ~/.zshrc and is never touched by yyg-setup.sh.
EOF
        success ".zshrc.local created."
    else
        success ".zshrc.local preserved."
    fi

    # --------------------------------------------------------
    # Bash → Zsh
    # --------------------------------------------------------

    log "Checking ~/.bashrc..."

    if ! grep -Fq "$BASH_MARKER" "$HOME/.bashrc" 2>/dev/null; then

        backup_file "$HOME/.bashrc"

        append_file "$HOME/.bashrc" <<EOF

$BASH_MARKER
EOF
        append_file "$HOME/.bashrc" <<'EOF'
if [[ $- == *i* ]] &&
   command -v zsh >/dev/null 2>&1 &&
   [[ "$SHELL" != */zsh ]]; then
    export SHELL="$(command -v zsh)"
    exec zsh
fi
EOF

        success ".bashrc fallback added."

    else

        success ".bashrc fallback already exists."

    fi

    # --------------------------------------------------------
    # Default shell
    # --------------------------------------------------------

    log "Setting Zsh as default shell..."

    ZSH_PATH="$(command -v zsh || echo /usr/bin/zsh)"
    CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

    if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
        run sudo chsh -s "$ZSH_PATH" "$USER"
        success "Default shell: $ZSH_PATH"
    else
        success "Zsh is already the default shell."
    fi

fi

# ============================================================
# 6. JetBrains Mono Nerd Font
# ============================================================

if should_run font; then

    log "Preparing JetBrains Mono Nerd Font..."

    FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
    FONT_FILE="$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf"

    if [[ ! -f "$FONT_FILE" ]]; then

        TMP_ZIP="$(mktemp --suffix=.zip)"

        download \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
            "$TMP_ZIP"

        run mkdir -p "$FONT_DIR"
        run unzip -oq "$TMP_ZIP" -d "$FONT_DIR"
        run fc-cache -f

        rm -f "$TMP_ZIP"

        success "JetBrains Mono Nerd Font installed."

    else

        success "JetBrains Mono Nerd Font is already installed."

    fi

fi

# ============================================================
# 7. GNOME Terminal Font
# ============================================================

if should_run terminal; then

    log "Setting GNOME Terminal font..."

    if $HAS_GSETTINGS &&
       gsettings list-schemas 2>/dev/null | grep -q '^org.gnome.Terminal'; then

        PROFILE="$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")" || PROFILE=""

        if [[ -n "$PROFILE" ]]; then

            PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/"

            run gsettings set "$PROFILE_PATH" use-system-font false
            run gsettings set "$PROFILE_PATH" font 'JetBrainsMono Nerd Font 11'

            success "GNOME Terminal font set."

        else

            warning "GNOME Terminal profile not found."

        fi

    else

        warning "GNOME Terminal not found, skipping."

    fi

fi

# ============================================================
# 8. GNOME Keyboard Shortcuts
# ============================================================

if should_run gnome; then

    log "Setting GNOME keyboard shortcuts..."

    if $HAS_GSETTINGS; then

        # ----------------------------------------------------
        # Custom shortcuts
        # ----------------------------------------------------

        # Read the existing custom shortcut list so that the
        # user's own shortcuts are preserved.
        mapfile -t EXISTING_PATHS < <(gsettings_list "$KEYBINDINGS_SCHEMA" custom-keybindings)

        YYG_PATHS=()
        YYG_ENTRIES=()

        for shortcut in "${CUSTOM_SHORTCUTS[@]}"; do

            IFS='|' read -r id name command binding <<<"$shortcut"

            path="$KEYBINDING_BASE/$id/"

            run gsettings set "$KEYBINDING_SCHEMA:$path" name "$name"
            run gsettings set "$KEYBINDING_SCHEMA:$path" command "$command"
            run gsettings set "$KEYBINDING_SCHEMA:$path" binding "$binding"

            YYG_PATHS+=("$path")
            YYG_ENTRIES+=("'$command'|'$binding'")

        done

        NEW_PATHS=()

        for path in "${EXISTING_PATHS[@]}"; do

            [[ "$path" == "$KEYBINDING_BASE/yyg-"* ]] && continue

            # Drop shortcuts created by older versions of this
            # script (custom0..custom4) to avoid duplicates.
            entry="$(gsettings get "$KEYBINDING_SCHEMA:$path" command)|$(gsettings get "$KEYBINDING_SCHEMA:$path" binding)"

            if contains "$(IFS=,; echo "${YYG_ENTRIES[*]}")" "$entry"; then
                warning "Replacing old shortcut: $path"
                continue
            fi

            NEW_PATHS+=("$path")

        done

        NEW_PATHS+=("${YYG_PATHS[@]}")

        run gsettings set "$KEYBINDINGS_SCHEMA" custom-keybindings "$(to_gvariant_list "${NEW_PATHS[@]}")"

        # ----------------------------------------------------
        # System shortcuts
        # ----------------------------------------------------

        for shortcut in "${SYSTEM_SHORTCUTS[@]}"; do
            IFS='|' read -r schema key value <<<"$shortcut"
            run gsettings set "$schema" "$key" "$value"
        done

        # ----------------------------------------------------
        # Disable Super + 1..9
        # ----------------------------------------------------

        for i in {1..9}; do
            run gsettings set org.gnome.shell.keybindings "switch-to-application-$i" "@as []" 2>/dev/null || true
            run gsettings set org.gnome.shell.keybindings "open-new-window-application-$i" "@as []" 2>/dev/null || true
        done

        # Dash-to-Dock / Ubuntu Dock
        run gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false 2>/dev/null || true
        run gsettings set org.gnome.shell.extensions.ubuntu-dock hot-keys false 2>/dev/null || true

        success "GNOME shortcuts set."

    else

        warning "gsettings not found, skipping."

    fi

fi

# ============================================================
# 8.5. GNOME Shell Extensions
# ============================================================

if should_run extensions; then

    log "Installing GNOME Shell extensions..."

    if $HAS_GSETTINGS && command -v gnome-extensions >/dev/null 2>&1; then

        SHELL_VERSION="$(gnome-shell --version | grep -oE '[0-9]+' | head -n 1)"
        mapfile -t INSTALLED_EXTENSIONS < <(gnome-extensions list)

        TMP_DIR="$(mktemp -d)"

        for uuid in "${GNOME_EXTENSIONS[@]}"; do

            if contains "$(IFS=,; echo "${INSTALLED_EXTENSIONS[*]}")" "$uuid"; then
                success "$uuid is already installed."
                continue
            fi

            INFO="$(curl -fsS "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$SHELL_VERSION" || true)"
            DOWNLOAD_PATH="$(grep -oE '"download_url": *"[^"]+"' <<<"$INFO" | cut -d'"' -f4 || true)"

            if [[ -z "$DOWNLOAD_PATH" ]]; then
                warning "$uuid is not available for GNOME Shell $SHELL_VERSION, skipping."
                continue
            fi

            download "https://extensions.gnome.org$DOWNLOAD_PATH" "$TMP_DIR/$uuid.zip"
            run gnome-extensions install --force "$TMP_DIR/$uuid.zip"

            success "$uuid installed."

        done

        rm -rf "$TMP_DIR"

        # ----------------------------------------------------
        # Enable
        # ----------------------------------------------------

        # Newly installed extensions are only picked up by GNOME
        # Shell after logging out, so they are enabled through
        # gsettings instead of `gnome-extensions enable`.
        mapfile -t ENABLED < <(gsettings_list org.gnome.shell enabled-extensions)

        for uuid in "${GNOME_EXTENSIONS[@]}"; do
            if ! contains "$(IFS=,; echo "${ENABLED[*]}")" "$uuid"; then
                ENABLED+=("$uuid")
            fi
        done

        run gsettings set org.gnome.shell disable-user-extensions false
        run gsettings set org.gnome.shell enabled-extensions "$(to_gvariant_list "${ENABLED[@]}")"

        success "Extensions enabled."

        # ----------------------------------------------------
        # Settings
        # ----------------------------------------------------

        if [[ -f "$EXTENSIONS_DCONF" ]]; then

            if $DRY_RUN; then
                echo "    [dry-run] dconf load /org/gnome/shell/extensions/ < $EXTENSIONS_DCONF"
            else
                dconf dump /org/gnome/shell/extensions/ >"$BACKUP_DIR/gnome-extensions.dconf"
                dconf load /org/gnome/shell/extensions/ <"$EXTENSIONS_DCONF"
            fi

            success "Extension settings applied (previous settings backed up)."

        else

            warning "gnome-extensions.dconf not found next to the script, skipping settings."

        fi

        warning "Log out and back in to activate new extensions."

    else

        warning "GNOME Shell not found, skipping."

    fi

fi

# ============================================================
# 9. Nautilus VS Code Script
# ============================================================

if should_run nautilus; then

    log "Adding Nautilus VS Code context menu script..."

    NAUTILUS_SCRIPT="$HOME/.local/share/nautilus/scripts/Open in VS Code"

    run mkdir -p "$(dirname "$NAUTILUS_SCRIPT")"

    write_file "$NAUTILUS_SCRIPT" <<'EOF'
#!/bin/sh
if [ "$#" -eq 0 ]; then
    code .
else
    code "$@"
fi
EOF

    run chmod +x "$NAUTILUS_SCRIPT"

    success "Nautilus script added."

fi

# ============================================================
# 10. Git Configuration
# ============================================================

if should_run git; then

    log "Configuring Git..."

    if command -v git >/dev/null 2>&1 || $DRY_RUN; then

        run git config --global user.name "$GIT_USERNAME"
        run git config --global user.email "$GIT_EMAIL"
        run git config --global init.defaultBranch main

        success "Git username: $GIT_USERNAME"
        success "Git email: $GIT_EMAIL"
        success "Default branch: main"

    else

        warning "git not found, skipping. Run the 'packages' step first."

    fi

fi

# ============================================================
# 11. SSH Ed25519 Key
# ============================================================

if should_run ssh; then

    log "Checking SSH key..."

    SSH_DIR="$HOME/.ssh"
    SSH_KEY="$SSH_DIR/id_ed25519"
    SSH_COMMENT="${GIT_EMAIL:-$(git config --global user.email 2>/dev/null || echo "$USER@$(uname -n)")}"

    run mkdir -p "$SSH_DIR"
    run chmod 700 "$SSH_DIR"

    if [[ -f "$SSH_KEY" ]]; then

        success "Existing Ed25519 SSH key found and preserved."

    else

        echo "    Ed25519 SSH key not found, generating..."

        # Empty passphrase by design.
        run ssh-keygen -t ed25519 -C "$SSH_COMMENT" -f "$SSH_KEY" -N ""

        run chmod 600 "$SSH_KEY"
        run chmod 644 "$SSH_KEY.pub"

        success "New Ed25519 SSH key generated."

    fi

    if [[ -f "$SSH_KEY.pub" ]]; then
        echo
        echo "SSH Public Key:"
        echo "--------------------------------------------------"
        cat "$SSH_KEY.pub"
        echo "--------------------------------------------------"
    fi

fi

# ============================================================
# 12. Verification
# ============================================================

log "Verifying installation..."

check_version() {
    local label="$1"
    shift

    if command -v "$1" >/dev/null 2>&1; then
        printf '    %-12s %s\n' "$label" "$("$@" 2>&1 | head -n 1)"
    else
        printf '    %-12s %s\n' "$label" "not installed"
    fi
}

set +u
if [[ -s "$HOME/.nvm/nvm.sh" ]] && ! command -v nvm >/dev/null 2>&1; then
    # shellcheck source=/dev/null
    source "$HOME/.nvm/nvm.sh"
fi
check_version "Node.js" node --version
check_version "NPM" npm --version
check_version "NVM" nvm --version
check_version "NestJS" nest --version
set -u
check_version "Python" python --version
check_version "Git" git --version
check_version "Zsh" zsh --version
check_version "Fastfetch" fastfetch --version
printf '    %-12s %s\n' "Shell" "$(getent passwd "$USER" | cut -d: -f7)"

# ============================================================
# DONE
# ============================================================

COMPLETED=()

for step in "${STEPS[@]}"; do
    if should_run "$step"; then
        COMPLETED+=("$step")
    fi
done

echo
echo "=========================================="
echo " $SCRIPT_NAME Completed!"
echo "=========================================="
echo
echo "Steps: ${COMPLETED[*]}"

if ! $DRY_RUN; then
    echo
    echo "Backups and log:"
    echo "  $BACKUP_DIR"
fi

echo
echo "To activate new shell settings,"
echo "close and reopen the terminal."
echo
echo "YYG setup completed. 🚀"
