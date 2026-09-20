```bash
#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# YYG ENDEAVOUROS / ARCH LINUX SYSTEM SETUP
# ============================================================

readonly SCRIPT_NAME="YYG System Setup"
readonly NVM_VERSION="v0.40.3"

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

trap 'echo; echo "✗ An error occurred during setup."; echo "  Line: $LINENO"; echo "  Command: $BASH_COMMAND"; exit 1' ERR

# ============================================================
# Header
# ============================================================

echo
echo "=========================================="
echo " YYG EndeavourOS / Arch Linux Setup"
echo "=========================================="

# ============================================================
# 0. System Check
# ============================================================

log "Checking system..."

if [[ ! -f /etc/os-release ]]; then
    fail "/etc/os-release not found."
fi

source /etc/os-release

if [[ "${ID:-}" != "arch" && "${ID_LIKE:-}" != *"arch"* ]]; then
    fail "This script is designed only for Arch Linux / EndeavourOS systems."
fi

success "Arch-based system: ${PRETTY_NAME:-Unknown}"

# ============================================================
# 1. System Update
# ============================================================

log "Updating system..."

sudo pacman -Syu --noconfirm

success "System updated."

# ============================================================
# 2. Required System Packages
# ============================================================

log "Installing required system packages..."

sudo pacman -S --needed --noconfirm \
    base-devel \
    git \
    curl \
    unzip \
    zsh \
    fastfetch \
    python \
    python-pip \
    gnome-terminal

success "Base packages ready."

# ============================================================
# 2.5. Yay & Yayy
# ============================================================

log "Preparing Yay and Yayy..."

if ! command -v yay >/dev/null 2>&1; then
    rm -rf /tmp/yay-bin
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    (cd /tmp/yay-bin && makepkg -si --noconfirm)
    rm -rf /tmp/yay-bin
    success "Yay installed."
else
    success "Yay is already installed."
fi

curl -sL https://raw.githubusercontent.com/yyg27/yayy/main/install.sh -o /tmp/yayy-install.sh
bash /tmp/yayy-install.sh
rm -f /tmp/yayy-install.sh
success "Yayy CLI installed."

# ============================================================
# 3. NVM
# ============================================================

log "Checking NVM..."

export NVM_DIR="$HOME/.nvm"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then

    echo "    NVM not found, installing..."

    curl -o- \
        "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" \
        | bash

else

    success "NVM is already installed."

fi

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    fail "NVM installation failed."
fi

source "$NVM_DIR/nvm.sh"

success "NVM: $(nvm --version)"

# ============================================================
# 4. Node.js LTS
# ============================================================

log "Preparing Node.js LTS..."

nvm install --lts
nvm alias default 'lts/*'
nvm use --lts

success "Node.js: $(node --version)"
success "NPM: $(npm --version)"

# ============================================================
# 5. NestJS CLI
# ============================================================

log "Checking NestJS CLI..."

if command -v nest >/dev/null 2>&1; then

    success "NestJS CLI is already installed: $(nest --version)"

else

    npm install -g @nestjs/cli

    success "NestJS CLI installed: $(nest --version)"

fi

# ============================================================
# 6. Shell Configuration Backup
# ============================================================

log "Backing up current shell configurations..."

BACKUP_DIR="$HOME/.yyg-setup-backups/$(date +%Y%m%d-%H%M%S)"

if [[ -f "$HOME/.zshrc" ]]; then

    mkdir -p "$BACKUP_DIR"
    cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"

    success "Current .zshrc backed up."

fi

if [[ -f "$HOME/.bashrc" ]]; then

    mkdir -p "$BACKUP_DIR"
    cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc"

    success "Current .bashrc backed up."

fi

# ============================================================
# 7. Oh My Zsh
# ============================================================

log "Preparing Oh My Zsh..."

export ZSH="$HOME/.oh-my-zsh"

if [[ ! -d "$ZSH" ]]; then

    git clone \
        https://github.com/ohmyzsh/ohmyzsh.git \
        "$ZSH"

    success "Oh My Zsh installed."

else

    success "Oh My Zsh is already installed."

fi

# ============================================================
# 8. Zsh Plugins
# ============================================================

log "Preparing Zsh plugins..."

CUSTOM_PLUGIN_DIR="$ZSH/custom/plugins"
CUSTOM_THEME_DIR="$ZSH/custom/themes"

mkdir -p \
    "$CUSTOM_PLUGIN_DIR" \
    "$CUSTOM_THEME_DIR"

# ------------------------------------------------------------
# zsh-autosuggestions
# ------------------------------------------------------------

if [[ ! -d "$CUSTOM_PLUGIN_DIR/zsh-autosuggestions" ]]; then

    git clone \
        https://github.com/zsh-users/zsh-autosuggestions \
        "$CUSTOM_PLUGIN_DIR/zsh-autosuggestions"

    success "zsh-autosuggestions installed."

else

    success "zsh-autosuggestions is already installed."

fi

# ------------------------------------------------------------
# zsh-syntax-highlighting
# ------------------------------------------------------------

if [[ ! -d "$CUSTOM_PLUGIN_DIR/zsh-syntax-highlighting" ]]; then

    git clone \
        https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$CUSTOM_PLUGIN_DIR/zsh-syntax-highlighting"

    success "zsh-syntax-highlighting installed."

else

    success "zsh-syntax-highlighting is already installed."

fi

# ============================================================
# 9. Powerlevel10k
# ============================================================

log "Preparing Powerlevel10k..."

if [[ ! -d "$CUSTOM_THEME_DIR/powerlevel10k" ]]; then

    git clone --depth=1 \
        https://github.com/romkatv/powerlevel10k.git \
        "$CUSTOM_THEME_DIR/powerlevel10k"

    success "Powerlevel10k installed."

else

    success "Powerlevel10k is already installed."

fi

# ============================================================
# 10. JetBrains Mono Nerd Font
# ============================================================

log "Preparing JetBrains Mono Nerd Font..."

FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
FONT_FILE="$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf"
TEMP_ZIP="/tmp/JetBrainsMono.zip"

mkdir -p "$FONT_DIR"

if [[ ! -f "$FONT_FILE" ]]; then

    curl -fL \
        -o "$TEMP_ZIP" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

    unzip -o \
        "$TEMP_ZIP" \
        -d "$FONT_DIR" \
        >/dev/null

    rm -f "$TEMP_ZIP"

    fc-cache -f

    success "JetBrains Mono Nerd Font installed."

else

    success "JetBrains Mono Nerd Font is already installed."

fi

# ============================================================
# 11. GNOME Terminal Font
# ============================================================

log "Setting GNOME Terminal font..."

if command -v gsettings >/dev/null 2>&1 &&
   gsettings list-schemas 2>/dev/null |
   grep -q '^org.gnome.Terminal'; then

    PROFILE=$(
        gsettings get \
            org.gnome.Terminal.ProfilesList default \
            2>/dev/null |
        tr -d "'"
    ) || PROFILE=""

    if [[ -n "$PROFILE" ]]; then

        PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/"

        gsettings set \
            "$PROFILE_PATH" \
            use-system-font false

        gsettings set \
            "$PROFILE_PATH" \
            font 'JetBrainsMono Nerd Font 11'

        success "GNOME Terminal font set."

    else

        warning "GNOME Terminal profile not found."

    fi

else

    warning "GNOME Terminal not found."

fi

# ============================================================
# 12. .zshrc Configuration
# ============================================================

log "Configuring ~/.zshrc..."

cat > "$HOME/.zshrc" <<'EOF'
# ============================================================
# YYG ZSH CONFIGURATION
# ============================================================

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

# Fastfetch
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi
EOF

success ".zshrc created."

# ============================================================
# 13. Bash → Zsh
# ============================================================

log "Checking ~/.bashrc..."

BASH_MARKER="# YYG: Automatically switch interactive Bash sessions to Zsh"

if ! grep -Fq "$BASH_MARKER" "$HOME/.bashrc" 2>/dev/null; then

    cat >> "$HOME/.bashrc" <<'EOF'

# YYG: Automatically switch interactive Bash sessions to Zsh
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

# ============================================================
# 14. GNOME Keyboard Shortcuts
# ============================================================

log "Setting GNOME keyboard shortcuts..."

if ! command -v gsettings >/dev/null 2>&1; then
    fail "gsettings not found."
fi

# ------------------------------------------------------------
# Custom shortcut paths
# ------------------------------------------------------------

P1="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
P2="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
P3="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
P4="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
P5="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"

# ------------------------------------------------------------
# Super + C → VS Code
# ------------------------------------------------------------

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P1" \
    name 'VS Code'

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P1" \
    command 'code'

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P1" \
    binding '<Super>c'

# ------------------------------------------------------------
# Super + T → GNOME Terminal
# ------------------------------------------------------------

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P2" \
    name 'GNOME Terminal'

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P2" \
    command 'gnome-terminal'

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P2" \
    binding '<Super>t'

# ------------------------------------------------------------
# Super + E → Nautilus
# ------------------------------------------------------------

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P3" \
    name 'File Manager'

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P3" \
    command 'nautilus'

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P3" \
    binding '<Super>e'

# ------------------------------------------------------------
# Super + W → Firefox
# ------------------------------------------------------------

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P4" \
    name 'Firefox'

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P4" \
    command 'firefox'

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P4" \
    binding '<Super>w'

# ------------------------------------------------------------
# Super + M → YouTube Music
# ------------------------------------------------------------

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P5" \
    name 'Youtube Music'

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P5" \
    command 'youtubemusic'

gsettings set \
    "org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$P5" \
    binding '<Super>m'

# Enable custom shortcuts
gsettings set \
    org.gnome.settings-daemon.plugins.media-keys \
    custom-keybindings \
    "['$P1', '$P2', '$P3', '$P4', '$P5']"

# ============================================================
# 15. System Shortcuts
# ============================================================

# Super + V → Notification tray

gsettings set \
    org.gnome.shell.keybindings \
    toggle-message-tray \
    "['<Super>v']"

# Super + Q → Close active window

gsettings set \
    org.gnome.desktop.wm.keybindings \
    close \
    "['<Super>q', '<Alt>F4']"

# Super + F → Fullscreen

gsettings set \
    org.gnome.desktop.wm.keybindings \
    toggle-fullscreen \
    "['<Super>f', 'F11']"

# Super + G → Toggle maximize

gsettings set \
    org.gnome.desktop.wm.keybindings \
    toggle-maximized \
    "['<Super>g', '<Super>Up', '<Alt>F10']"

# ============================================================
# 16. Disable Super + 1..9
# ============================================================

log "Disabling Dock application shortcuts..."

for i in {1..9}; do

    gsettings set \
        org.gnome.shell.keybindings \
        "switch-to-application-$i" \
        "@as []" \
        2>/dev/null || true

    gsettings set \
        org.gnome.shell.keybindings \
        "open-new-window-application-$i" \
        "@as []" \
        2>/dev/null || true

done

# Dash-to-Dock
gsettings set \
    org.gnome.shell.extensions.dash-to-dock \
    hot-keys false \
    2>/dev/null || true

# Ubuntu Dock
gsettings set \
    org.gnome.shell.extensions.ubuntu-dock \
    hot-keys false \
    2>/dev/null || true

success "GNOME shortcuts set."

# ============================================================
# 17. Git Configuration
# ============================================================

log "Configuring Git..."

echo

read -r -p \
    "Enter your Git Username (e.g. yyg27): " \
    GIT_USERNAME < /dev/tty

read -r -p \
    "Enter your Git Email Address: " \
    GIT_EMAIL < /dev/tty

if [[ -z "$GIT_USERNAME" ]]; then
    fail "Git username cannot be empty."
fi

if [[ -z "$GIT_EMAIL" ]]; then
    fail "Git email address cannot be empty."
fi

git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch "main"

success "Git username: $GIT_USERNAME"
success "Git email: $GIT_EMAIL"
success "Default branch: main"

# ============================================================
# 18. SSH Ed25519 Key
# ============================================================

log "Checking SSH key..."

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"
SSH_PUBLIC_KEY="$SSH_KEY.pub"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [[ -f "$SSH_KEY" ]]; then

    success "Existing Ed25519 SSH key found."
    success "Existing key is preserved."

else

    echo "    Ed25519 SSH key not found."
    echo "    Generating new key..."

    # Empty passphrase by design.
    ssh-keygen \
        -t ed25519 \
        -C "$GIT_EMAIL" \
        -f "$SSH_KEY" \
        -N ""

    chmod 600 "$SSH_KEY"
    chmod 644 "$SSH_PUBLIC_KEY"

    success "New Ed25519 SSH key generated."

fi

echo
echo "SSH Public Key:"
echo "--------------------------------------------------"

if [[ -f "$SSH_PUBLIC_KEY" ]]; then
    cat "$SSH_PUBLIC_KEY"
else
    warning "SSH public key not found."
fi

echo "--------------------------------------------------"

# ============================================================
# 19. Default Shell
# ============================================================

log "Setting Zsh as default shell..."

ZSH_PATH="$(command -v zsh)"
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then

    chsh -s "$ZSH_PATH"

    success "Default shell: $ZSH_PATH"

else

    success "Zsh is already the default shell."

fi

# ============================================================
# 20. Final Verification
# ============================================================

log "Verifying installation..."

echo
echo "Node.js:"
node --version

echo
echo "NPM:"
npm --version

echo
echo "Python:"
python --version

echo
echo "Git:"
git --version

echo
echo "Zsh:"
zsh --version | head -n 1

echo
echo "NVM:"
nvm --version

echo
echo "NestJS:"
nest --version

echo
echo "Fastfetch:"
fastfetch --version | head -n 1

echo
echo "Default Shell:"
getent passwd "$USER" | cut -d: -f7

# ============================================================
# DONE
# ============================================================

echo
echo "=========================================="
echo " YYG System Setup Completed!"
echo "=========================================="

echo
echo "Installed / configured:"
echo "  ✓ Arch system packages"
echo "  ✓ Git"
echo "  ✓ Python + pip"
echo "  ✓ Zsh"
echo "  ✓ Oh My Zsh"
echo "  ✓ Powerlevel10k"
echo "  ✓ zsh-autosuggestions"
echo "  ✓ zsh-syntax-highlighting"
echo "  ✓ Fastfetch"
echo "  ✓ NVM"
echo "  ✓ Node.js LTS"
echo "  ✓ NPM"
echo "  ✓ NestJS CLI"
echo "  ✓ JetBrains Mono Nerd Font"
echo "  ✓ GNOME Terminal font"
echo "  ✓ GNOME keyboard shortcuts"
echo "  ✓ Git configuration"
echo "  ✓ Ed25519 SSH key"
echo "  ✓ Zsh default shell"

if [[ -d "$BACKUP_DIR" ]]; then
    echo
    echo "Old shell configurations:"
    echo "  $BACKUP_DIR"
fi

echo
echo "SSH public key is displayed above."
echo
echo "To activate new shell settings,"
echo "close and reopen the terminal."
echo
echo "YYG setup completed. 🚀"
```

