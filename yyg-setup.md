# Arch Linux / GNOME YYG System Setup & Configuration Guide (`yyg-setup.md`)

This document is designed to **install and configure** YYG's development environment, Zsh shell, terminal theme, fonts, GNOME shortcuts, and Git/SSH configuration in a fresh Arch Linux + GNOME system in **a single run**.

The document can be used in two different ways:

1. **With an AI coding agent / CLI:** You can give this `.md` file to any AI coding agent to execute the steps below.
2. **Manually:** You can directly run the commands in the document in your terminal.

Additionally, the automated shell script version `yyg-setup.sh` can be used. **`yyg-setup.md` does not depend on the `yyg-setup.sh` file and is sufficient on its own.**

> [!TIP]
> On a new computer or a fresh installation, simply provide this file to the AI coding CLI tool you are using and tell it to **"execute the setup in the yyg-setup.md guide"**.

---

# AI Agent Instructions

If you are executing this document as an AI coding agent, follow the rules below.

### 1. This document can be executed standalone

Even if `yyg-setup.sh` is not available, perform the entire setup using the commands in this document.

If `yyg-setup.sh` is available, you may run it; however, the script is not required for the `.md` file to work.

### 2. Check the current system first

Before starting the installation:

* Verify that the operating system is Arch Linux-based.
* Check if the required programs are already installed.
* Check the current Zsh configuration.
* Check the current Git configuration.
* Check the current SSH keys.
* Check if the GNOME session is active.

Do not unnecessarily reinstall packages that are already installed.

### 3. Preserve existing configurations

Do not directly delete the following files:

```text
~/.zshrc
~/.bashrc
~/.gitconfig
~/.ssh/
```

Take a backup before making changes.

### 4. Request required information from the user

For Git configuration, ask the user for:

* Git username
* Git email address

### 5. Do not overwrite the SSH key

If `~/.ssh/id_ed25519` exists, definitely do not generate a new key.

### 6. Apply GNOME shortcuts

The GNOME shortcuts in this document are part of YYG's personal system configuration and are **not optional.**

### 7. Do not hide errors

If an installation step fails, report the error to the user and fix the problem if possible.

Do not send a success message until the installation is complete.

---

# All Installations and Settings Included in the Guide

## 1. Node.js & Backend Environment

* **NVM** (Node Version Manager)
* **Node.js LTS**
* **NPM**
* Global **NestJS CLI** (`@nestjs/cli`)
* NVM default Node version → LTS

---

## 2. Python & Development Packages

* **Python 3**
* **python-pip**
* **base-devel**
* **Git**
* **curl**
* **unzip**
* **gnome-terminal**

---

## 3. Terminal & Shell Customizations

* **Zsh**
* **Fastfetch**
* **Oh My Zsh**
* **zsh-autosuggestions**
* **zsh-syntax-highlighting**
* **Powerlevel10k**
* Powerlevel10k instant prompt warnings disabled
* Automatic switch to Zsh when Interactive Bash is opened
* Zsh as default login shell
* `neofetch` → `fastfetch` alias

---

## 4. Fonts

* **JetBrains Mono Nerd Font**
* Font cache (`fc-cache`) update
* GNOME Terminal font setting
* Font size: `11`

---

## 5. GNOME Desktop Keyboard Shortcuts

| Shortcut      | Action                         |
| ------------- | ------------------------------ |
| **Super + C** | VS Code (`code`)               |
| **Super + T** | GNOME Terminal (`gnome-terminal`) |
| **Super + E** | File Manager (`nautilus`)      |
| **Super + W** | Firefox (`firefox`)            |
| **Super + M** | YouTube Music (`youtubemusic`) |
| **Super + V** | Notification tray              |
| **Super + Q** | Close active window            |
| **Super + F** | Fullscreen                     |
| **Super + G** | Toggle maximize                |

### Dock shortcuts

Application shortcuts on the dock:

```text
Super + 1
Super + 2
Super + 3
...
Super + 9
```

are disabled.

---

## 6. Git & GitHub Configuration

During installation, you will interactively be asked for:

* Git username
* Git email address

Settings:

```text
user.name
user.email
init.defaultBranch = main
```

---

## 7. SSH

* Ed25519 SSH key
* Existing key is preserved
* If no key exists, a new one is generated
* Public key is displayed at the end of the installation

---

# Installation Steps

## 0. Update System

```bash
sudo pacman -Syu --noconfirm
```

---

# 1. Install Required System Packages

```bash
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
```

---

# 1.5. Yay and Yayy (AUR Helper) Installation

First, install the standard `yay` package manager:

```bash
rm -rf /tmp/yay-bin
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin
makepkg -si --noconfirm
rm -rf /tmp/yay-bin
```

Then install the custom `yayy` CLI tool:

```bash
curl -sL https://raw.githubusercontent.com/yyg27/yayy/main/install.sh -o /tmp/yayy-install.sh
bash /tmp/yayy-install.sh
rm -f /tmp/yayy-install.sh
```

---

# 2. Install NVM

If NVM is not available:

```bash
curl -o- \
    https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh \
    | bash
```

Then:

```bash
export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \
    source "$NVM_DIR/nvm.sh"
```

---

# 3. Install Node.js LTS

```bash
nvm install --lts
nvm alias default 'lts/*'
nvm use --lts
```

Check:

```bash
node --version
npm --version
```

---

# 4. Install NestJS CLI

```bash
npm install -g @nestjs/cli
```

Check:

```bash
nest --version
```

---

# 5. Install Oh My Zsh

```bash
git clone \
    https://github.com/ohmyzsh/ohmyzsh.git \
    "$HOME/.oh-my-zsh"
```

Do not clone again if already installed.

---

# 6. Install Zsh Plugins

### zsh-autosuggestions

```bash
git clone \
    https://github.com/zsh-users/zsh-autosuggestions \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
```

### zsh-syntax-highlighting

```bash
git clone \
    https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
```

---

# 7. Install Powerlevel10k

```bash
git clone --depth=1 \
    https://github.com/romkatv/powerlevel10k.git \
    "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
```

---

# 8. Install JetBrains Mono Nerd Font

Create the font directory:

```bash
mkdir -p "$HOME/.local/share/fonts/JetBrainsMono"
```

Download the font:

```bash
curl -fL \
    -o /tmp/JetBrainsMono.zip \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
```

Extract:

```bash
unzip -o \
    /tmp/JetBrainsMono.zip \
    -d "$HOME/.local/share/fonts/JetBrainsMono"
```

Delete the temporary file:

```bash
rm -f /tmp/JetBrainsMono.zip
```

Refresh font cache:

```bash
fc-cache -f
```

---

# 9. Configure `.zshrc`

After backing up the existing file, `~/.zshrc` should use the following configuration:

```zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

export PATH="$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
fi

if [[ -s "$NVM_DIR/bash_completion" ]]; then
    source "$NVM_DIR/bash_completion"
fi

alias neofetch='fastfetch'

[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi
```

---

# 10. Bash → Zsh Transition

The following block should be added into `~/.bashrc`:

```bash
# YYG: Automatically switch interactive Bash sessions to Zsh
if [[ $- == *i* ]] &&
   command -v zsh >/dev/null 2>&1 &&
   [[ "$SHELL" != */zsh ]]; then
    export SHELL="$(command -v zsh)"
    exec zsh
fi
```

Do not add this block again if it was added previously.

---

# 11. Set GNOME Terminal Font

Find the default GNOME Terminal profile:

```bash
PROFILE=$(gsettings get \
    org.gnome.Terminal.ProfilesList default \
    2>/dev/null | tr -d "'")
```

If profile exists:

```bash
PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE}/"

gsettings set \
    "$PROFILE_PATH" \
    use-system-font false

gsettings set \
    "$PROFILE_PATH" \
    font 'JetBrainsMono Nerd Font 11'
```

---

# 12. Set GNOME Shortcuts

## Super + C → VS Code

```bash
P1="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P1" \
    name 'VS Code'

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P1" \
    command 'code'

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P1" \
    binding '<Super>c'
```

## Super + T → GNOME Terminal

```bash
P2="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P2" \
    name 'GNOME Terminal'

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P2" \
    command 'gnome-terminal'

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P2" \
    binding '<Super>t'
```

## Super + E → File Manager

```bash
P3="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P3" \
    name 'File Manager'

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P3" \
    command 'nautilus'

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P3" \
    binding '<Super>e'
```

## Super + W → Firefox

```bash
P4="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P4" \
    name 'Firefox'

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P4" \
    command 'firefox'

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P4" \
    binding '<Super>w'
```

## Super + M → YouTube Music

```bash
P5="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P5" \
    name 'Youtube Music'

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P5" \
    command 'youtubemusic'

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P5" \
    binding '<Super>m'
```

Enable custom keybinding list:

```bash
gsettings set \
    org.gnome.settings-daemon.plugins.media-keys \
    custom-keybindings \
    "['$P1', '$P2', '$P3', '$P4', '$P5']"
```

---

# 13. Set System Shortcuts

### Super + V → Notification Tray

```bash
gsettings set \
    org.gnome.shell.keybindings \
    toggle-message-tray \
    "['<Super>v']"
```

### Super + Q → Close Active Window

```bash
gsettings set \
    org.gnome.desktop.wm.keybindings \
    close \
    "['<Super>q', '<Alt>F4']"
```

### Super + F → Fullscreen

```bash
gsettings set \
    org.gnome.desktop.wm.keybindings \
    toggle-fullscreen \
    "['<Super>f', 'F11']"
```

### Super + G → Toggle Maximize

```bash
gsettings set \
    org.gnome.desktop.wm.keybindings \
    toggle-maximized \
    "['<Super>g', '<Super>Up', '<Alt>F10']"
```

---

# 14. Disable Dock Application Shortcuts

```bash
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
```

Dash-to-Dock:

```bash
gsettings set \
    org.gnome.shell.extensions.dash-to-dock \
    hot-keys false \
    2>/dev/null || true
```

Ubuntu Dock:

```bash
gsettings set \
    org.gnome.shell.extensions.ubuntu-dock \
    hot-keys false \
    2>/dev/null || true
```

---

# 15. Git Configuration

Git username:

```bash
read -r -p \
    "Enter your Git Username (e.g. yyg27): " \
    GIT_USERNAME < /dev/tty
```

Git email:

```bash
read -r -p \
    "Enter your Git Email Address: " \
    GIT_EMAIL < /dev/tty
```

Configure:

```bash
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch "main"
```

Check:

```bash
git config --global --list
```

---

# 16. Ed25519 SSH Key

Create SSH folder:

```bash
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
```

Check existing key:

```bash
ls -la "$HOME/.ssh/id_ed25519"*
```

If key doesn't exist:

```bash
ssh-keygen \
    -t ed25519 \
    -C "$GIT_EMAIL" \
    -f "$HOME/.ssh/id_ed25519" \
    -N ""
```

**Do not overwrite existing `id_ed25519` key.**

Public key:

```bash
cat "$HOME/.ssh/id_ed25519.pub"
```

---

# 17. Set Zsh as Default Shell

```bash
chsh -s "$(command -v zsh)"
```

Current shell:

```bash
echo "$SHELL"
```

---

# 18. Verify Installation

The following commands should run successfully:

```bash
node --version
npm --version
python --version
git --version
zsh --version
nvm --version
nest --version
fastfetch --version
```

Shell:

```bash
echo "$SHELL"
```

Expected:

```text
/bin/zsh
```

or the Zsh path in the system.

---

# Installation Completed

After the installation is complete, close and reopen the terminal.

The following environment should be ready on the new system:

* Node.js LTS
* NPM
* NVM
* NestJS CLI
* Python 3
* pip
* Git
* Zsh
* Oh My Zsh
* Powerlevel10k
* zsh-autosuggestions
* zsh-syntax-highlighting
* Fastfetch
* JetBrains Mono Nerd Font
* GNOME Terminal font setting
* YYG GNOME keyboard shortcuts
* Git global configuration
* Ed25519 SSH key
* Zsh default shell

---

## `yyg-setup.sh`

This is the automated shell script version of this document.

For those who want to download and use the script separately:

```bash
chmod +x yyg-setup.sh
./yyg-setup.sh
```

You can execute the installation directly with these commands.

**Using `yyg-setup.sh` is not mandatory. `yyg-setup.md` is sufficient on its own.**
