
# YYG Arch Linux + GNOME Setup

> Personal Arch Linux / GNOME workstation setup by **YYG**.

A personal setup guide for quickly preparing a fresh Arch Linux / GNOME installation with the development environment, shell, terminal, fonts, GNOME shortcuts, and Git/SSH configuration.

---

##  Contents

```text
.
├── README.md
├── yyg-setup.md
└── yyg-setup.sh
```

### `yyg-setup.md`

The **detailed installation documentation**.

It explains every setup step individually and can be given to any AI coding CLI or coding agent.

### `yyg-setup.sh`

The **automated shell script version** of the setup described in `yyg-setup.md`.

It can be executed directly from the terminal.

---

#  Quick Start

## Method 1 — Automated Setup

After obtaining the repository:

```bash
chmod +x yyg-setup.sh
./yyg-setup.sh
```

The script will:

* Update the system
* Install required Arch packages
* Install NVM
* Install Node.js LTS
* Install NestJS CLI
* Install Zsh
* Install Oh My Zsh
* Install Powerlevel10k
* Install Zsh plugins
* Configure Fastfetch
* Install JetBrains Mono Nerd Font
* Configure the GNOME Terminal font
* Configure GNOME keyboard shortcuts
* Configure Git
* Generate an Ed25519 SSH key
* Set Zsh as the default shell
* Verify the installation

---

#  Method 2 — AI Coding CLI

Give `yyg-setup.md` to your preferred AI coding CLI.

For example:

```text
Perform the setup described in yyg-setup.md.
```

The documentation is **not tied to any specific AI tool**.

It can be used with:

* Antigravity CLI
* Claude Code
* Gemini CLI
* Codex CLI
* Other coding agents

The AI agent does **not** have to execute the shell script.

`yyg-setup.md` is designed to work as a standalone setup guide.

---

#  Installed Environment

## Node.js & Backend

* NVM
* Node.js LTS
* NPM
* NestJS CLI

Check the installation:

```bash
node --version
npm --version
nvm --version
nest --version
```

---

## Python

* Python 3
* pip

Check the installation:

```bash
python --version
pip --version
```

---

##  Shell & Terminal

* Zsh
* Oh My Zsh
* Powerlevel10k
* zsh-autosuggestions
* zsh-syntax-highlighting
* Fastfetch

Zsh is configured as the default shell.

Check it with:

```bash
echo "$SHELL"
```

Expected:

```text
/bin/zsh
```

---

##  Font

Installed font:

**JetBrains Mono Nerd Font**

Font location:

```text
~/.local/share/fonts/JetBrainsMono
```

The font cache is automatically refreshed.

GNOME Terminal is configured to use:

```text
JetBrainsMono Nerd Font 11
```

---

#  GNOME Keyboard Shortcuts

The setup applies the following personal GNOME keyboard layout:

| Shortcut    | Action              |
| ----------- | ------------------- |
| `Super + C` | VS Code             |
| `Super + T` | GNOME Console       |
| `Super + E` | Nautilus            |
| `Super + W` | Firefox             |
| `Super + M` | YouTube Music       |
| `Super + V` | Notification tray   |
| `Super + Q` | Close active window |
| `Super + F` | Toggle fullscreen   |
| `Super + G` | Toggle maximize     |

The default application shortcuts using:

```text
Super + 1
Super + 2
...
Super + 9
```

are also disabled.

> These shortcuts are part of the personal YYG workstation configuration and are applied automatically by the setup script.

---

# Git & SSH

During setup, Git information is requested interactively:

```text
Git Username:
Git Email:
```

The following global Git configuration is then applied:

```bash
git config --global user.name
git config --global user.email
git config --global init.defaultBranch main
```

---

## SSH Key

The setup uses an **Ed25519 SSH key**:

```text
~/.ssh/id_ed25519
```

If an existing key is found, it is **never overwritten**.

If no key exists, a new Ed25519 key is generated.

This setup intentionally uses an **empty SSH passphrase** for convenience on a personal workstation.

The public key is displayed at the end of the installation:

```bash
cat ~/.ssh/id_ed25519.pub
```

The public key can then be added to your GitHub account.

---

# Backup

Before modifying existing shell configuration files, the script creates a backup.

Backup location:

```text
~/.yyg-setup-backups/
```

For example:

```text
~/.yyg-setup-backups/20260901-013000/
├── .bashrc
└── .zshrc
```

This makes it possible to restore the previous configuration if necessary.

---

#  Important Files

| File / Directory        | Description                 |
| ----------------------- | --------------------------- |
| `~/.zshrc`              | Zsh configuration           |
| `~/.bashrc`             | Bash → Zsh fallback         |
| `~/.p10k.zsh`           | Powerlevel10k configuration |
| `~/.gitconfig`          | Global Git configuration    |
| `~/.ssh/id_ed25519`     | SSH private key             |
| `~/.ssh/id_ed25519.pub` | SSH public key              |
| `~/.nvm/`               | NVM installation            |
| `~/.oh-my-zsh/`         | Oh My Zsh installation      |

---

#  Requirements

This setup is designed for:

* Arch Linux or any Arch-based distributions (EndeavourOS, CachyOS, etc.)
* GNOME


GNOME-specific features require:

* GNOME Shell
* `gsettings`


---

#  Running the Setup Again

The script is designed to be **idempotent where practical**.

Already-installed components such as:

* NVM
* Node.js
* NestJS CLI
* Oh My Zsh
* Zsh plugins
* Powerlevel10k
* Nerd Font
* SSH keys

are detected and reused where possible.

An existing SSH key at:

```text
~/.ssh/id_ed25519
```

is preserved.

---

#  What Is Not Installed?

This repository intentionally focuses on the core YYG workstation environment.

The following software is **not** installed by the setup:

* VS Code
* Firefox
* Nautilus
* GNOME Console
* YouTube Music
* Docker
* PostgreSQL
* Redis
* Kubernetes
* Steam
* Discord
* VS Code extensions
* Project-specific development dependencies

These can be installed separately when needed.

> The presence of VS Code, Firefox, Nautilus, GNOME Console, and YouTube Music in the GNOME shortcuts does **not** mean they are installed by this setup.

---

#  Documentation

Detailed setup instructions:

```text
yyg-setup.md
```

Automated installation:

```text
yyg-setup.sh
```

---

# YYG

Personal Linux workstation configuration by **YYG**.

A clean and reproducible Arch Linux + GNOME setup for development.

## License

Personal configuration.

Feel free to use, modify, and adapt it for your own system.


