
# Arch Linux / GNOME YYG Sistem Kurulum & Yapılandırma Rehberi (`yyg-setup.md`)

Bu doküman, yeni bir Arch Linux + GNOME sisteminde YYG'nin geliştirme ortamını, Zsh kabuğunu, terminal temasını, fontlarını, GNOME kısayollarını ve Git/SSH yapılandırmasını **tek seferde kurmak ve yapılandırmak** için hazırlanmıştır.

Doküman iki farklı şekilde kullanılabilir:

1. **AI coding agent / CLI ile:** Bu `.md` dosyasını herhangi bir AI coding agent'a vererek aşağıdaki adımları uygulatabilirsin.
2. **Manuel olarak:** Dokümandaki komutları doğrudan terminalde çalıştırabilirsin.

Ayrıca aynı kurulumun otomatikleştirilmiş hali olan `yyg-setup.sh` dosyası da kullanılabilir. **`yyg-setup.md`, `yyg-setup.sh` dosyasına bağımlı değildir ve tek başına yeterlidir.**

> [!TIP]
> Yeni bir bilgisayarda veya sıfır kurulumda bu dosyayı kullandığın AI coding CLI aracına verip **"yyg-setup.md rehberindeki kurulumları gerçekleştir"** demen yeterlidir.

---

# AI Agent Talimatları

Bu dokümanı bir AI coding agent olarak uyguluyorsan aşağıdaki kurallara uy.

### 1. Bu doküman tek başına uygulanabilir

`yyg-setup.sh` mevcut değilse bile kurulumun tamamını bu dokümandaki komutları kullanarak gerçekleştir.

`yyg-setup.sh` mevcutsa, istersen onu çalıştırabilirsin; ancak `.md` dosyasının çalışması için script gerekli değildir.

### 2. Önce mevcut sistemi kontrol et

Kuruluma başlamadan önce:

* İşletim sisteminin Arch Linux tabanlı olduğunu kontrol et.
* Gerekli programların kurulu olup olmadığını kontrol et.
* Mevcut Zsh yapılandırmasını kontrol et.
* Mevcut Git yapılandırmasını kontrol et.
* Mevcut SSH anahtarlarını kontrol et.
* GNOME oturumunun aktif olup olmadığını kontrol et.

Zaten kurulu olan paketleri gereksiz yere yeniden kurma.

### 3. Mevcut yapılandırmaları koru

Aşağıdaki dosyaları doğrudan silme:

```text
~/.zshrc
~/.bashrc
~/.gitconfig
~/.ssh/
```

Değişiklik yapmadan önce backup al.

### 4. Kullanıcıdan gerekli bilgileri iste

Git yapılandırması için:

* Git kullanıcı adı
* Git e-posta adresi

bilgilerini kullanıcıdan iste.

### 5. SSH anahtarının üzerine yazma

`~/.ssh/id_ed25519` mevcutsa kesinlikle yeni anahtar oluşturma.

### 6. GNOME kısayollarını uygula

Bu dokümandaki GNOME kısayolları YYG'nin kişisel sistem yapılandırmasının bir parçasıdır ve **opsiyonel değildir.**

### 7. Hataları gizleme

Bir kurulum adımı başarısız olursa hatayı kullanıcıya bildir ve mümkünse problemi düzelt.

Kurulum tamamlanmadan başarı mesajı verme.

---

#  Rehberde Yer Alan Tüm Kurulum ve Ayarlar

## 1. Node.js & Backend Ortamı

* **NVM** (Node Version Manager)
* **Node.js LTS**
* **NPM**
* Global **NestJS CLI** (`@nestjs/cli`)
* NVM default Node sürümü → LTS

---

## 2. Python & Geliştirme Paketleri

* **Python 3**
* **python-pip**
* **base-devel**
* **Git**
* **curl**
* **unzip**

---

## 3. Terminal & Kabuk Özelleştirmeleri

* **Zsh**
* **Fastfetch**
* **Oh My Zsh**
* **zsh-autosuggestions**
* **zsh-syntax-highlighting**
* **Powerlevel10k**
* Powerlevel10k instant prompt uyarıları kapalı
* Interactive Bash açıldığında otomatik Zsh'e geçiş
* Zsh varsayılan login shell
* `neofetch` → `fastfetch` alias'ı

---

## 4. Fontlar

* **JetBrains Mono Nerd Font**
* Font cache (`fc-cache`) güncellemesi
* GNOME Terminal font ayarı
* Font boyutu: `11`

---

## 5. GNOME Masaüstü Klavye Kısayolları

| Kısayol       | İşlev                          |
| ------------- | ------------------------------ |
| **Super + C** | VS Code (`code`)               |
| **Super + T** | GNOME Console (`kgx`)          |
| **Super + E** | Dosya Yöneticisi (`nautilus`)  |
| **Super + W** | Firefox (`firefox`)            |
| **Super + M** | YouTube Music (`youtubemusic`) |
| **Super + V** | Bildirim tepsisi               |
| **Super + Q** | Aktif pencereyi kapat          |
| **Super + F** | Tam ekran                      |
| **Super + G** | Pencereyi büyüt/küçült         |

### Dock kısayolları

Dock üzerindeki:

```text
Super + 1
Super + 2
Super + 3
...
Super + 9
```

uygulama kısayolları devre dışı bırakılır.

---

## 6. Git & GitHub Yapılandırması

Kurulum sırasında interaktif olarak:

* Git kullanıcı adı
* Git e-posta adresi

sorulur.

Ayarlar:

```text
user.name
user.email
init.defaultBranch = main
```

---

## 7. SSH

* Ed25519 SSH key
* Mevcut key korunur
* Key yoksa yeni key oluşturulur
* Public key kurulum sonunda gösterilir

---

#  Kurulum Adımları

## 0. Sistemi Güncelle

```bash
sudo pacman -Syu --noconfirm
```

---

# 1. Gerekli Sistem Paketlerini Kur

```bash
sudo pacman -S --needed --noconfirm \
    base-devel \
    git \
    curl \
    unzip \
    zsh \
    fastfetch \
    python \
    python-pip
```

---

# 2. NVM Kur

NVM mevcut değilse:

```bash
curl -o- \
    https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh \
    | bash
```

Ardından:

```bash
export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \
    source "$NVM_DIR/nvm.sh"
```

---

# 3. Node.js LTS Kur

```bash
nvm install --lts
nvm alias default 'lts/*'
nvm use --lts
```

Kontrol:

```bash
node --version
npm --version
```

---

# 4. NestJS CLI Kur

```bash
npm install -g @nestjs/cli
```

Kontrol:

```bash
nest --version
```

---

# 5. Oh My Zsh Kur

```bash
git clone \
    https://github.com/ohmyzsh/ohmyzsh.git \
    "$HOME/.oh-my-zsh"
```

Zaten kuruluysa tekrar clone etme.

---

# 6. Zsh Eklentilerini Kur

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

# 7. Powerlevel10k Kur

```bash
git clone --depth=1 \
    https://github.com/romkatv/powerlevel10k.git \
    "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
```

---

# 8. JetBrains Mono Nerd Font Kur

Font klasörünü oluştur:

```bash
mkdir -p "$HOME/.local/share/fonts/JetBrainsMono"
```

Fontu indir:

```bash
curl -fL \
    -o /tmp/JetBrainsMono.zip \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
```

Çıkart:

```bash
unzip -o \
    /tmp/JetBrainsMono.zip \
    -d "$HOME/.local/share/fonts/JetBrainsMono"
```

Geçici dosyayı sil:

```bash
rm -f /tmp/JetBrainsMono.zip
```

Font cache'i yenile:

```bash
fc-cache -f
```

---

# 9. `.zshrc` Yapılandır

Mevcut dosyanın backup'ını aldıktan sonra `~/.zshrc` aşağıdaki yapılandırmayı kullanmalıdır:

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

# 10. Bash → Zsh Geçişi

`~/.bashrc` içerisine aşağıdaki yapı eklenmelidir:

```bash
# YYG: Automatically switch interactive Bash sessions to Zsh
if [[ $- == *i* ]] &&
   command -v zsh >/dev/null 2>&1 &&
   [[ "$SHELL" != */zsh ]]; then
    export SHELL="$(command -v zsh)"
    exec zsh
fi
```

Bu blok daha önce eklenmişse tekrar ekleme.

---

# 11. GNOME Terminal Fontunu Ayarla

Default GNOME Terminal profilini bul:

```bash
PROFILE=$(gsettings get \
    org.gnome.Terminal.ProfilesList default \
    2>/dev/null | tr -d "'")
```

Profil mevcutsa:

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

# 12. GNOME Kısayollarını Ayarla

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

## Super + T → GNOME Console

```bash
P2="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P2" \
    name 'GNOME Console'

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P2" \
    command 'kgx'

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P2" \
    binding '<Super>t'
```

## Super + E → Dosya Yöneticisi

```bash
P3="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"

gsettings set \
    org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$P3" \
    name 'Dosya Yöneticisi'

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

Custom keybinding listesini etkinleştir:

```bash
gsettings set \
    org.gnome.settings-daemon.plugins.media-keys \
    custom-keybindings \
    "['$P1', '$P2', '$P3', '$P4', '$P5']"
```

---

# 13. Sistem Kısayollarını Ayarla

### Super + V → Bildirim Tepsisi

```bash
gsettings set \
    org.gnome.shell.keybindings \
    toggle-message-tray \
    "['<Super>v']"
```

### Super + Q → Aktif Pencereyi Kapat

```bash
gsettings set \
    org.gnome.desktop.wm.keybindings \
    close \
    "['<Super>q', '<Alt>F4']"
```

### Super + F → Tam Ekran

```bash
gsettings set \
    org.gnome.desktop.wm.keybindings \
    toggle-fullscreen \
    "['<Super>f', 'F11']"
```

### Super + G → Pencereyi Büyüt/Küçült

```bash
gsettings set \
    org.gnome.desktop.wm.keybindings \
    toggle-maximized \
    "['<Super>g', '<Super>Up', '<Alt>F10']"
```

---

# 14. Dock Uygulama Kısayollarını Kapat

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

# 15. Git Yapılandırması

Git kullanıcı adı:

```bash
read -r -p \
    "Git Kullanıcı Adınızı girin (ör: yyg27): " \
    GIT_USERNAME < /dev/tty
```

Git e-posta:

```bash
read -r -p \
    "Git E-posta Adresinizi girin: " \
    GIT_EMAIL < /dev/tty
```

Yapılandır:

```bash
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch "main"
```

Kontrol:

```bash
git config --global --list
```

---

# 16. Ed25519 SSH Anahtarı

SSH klasörünü oluştur:

```bash
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
```

Mevcut key'i kontrol et:

```bash
ls -la "$HOME/.ssh/id_ed25519"*
```

Key yoksa:

```bash
ssh-keygen \
    -t ed25519 \
    -C "$GIT_EMAIL" \
    -f "$HOME/.ssh/id_ed25519"
```

**Mevcut `id_ed25519` anahtarının üzerine yazma.**

Public key:

```bash
cat "$HOME/.ssh/id_ed25519.pub"
```

---

# 17. Zsh'i Varsayılan Shell Yap

```bash
chsh -s "$(command -v zsh)"
```

Mevcut shell:

```bash
echo "$SHELL"
```

---

# 18. Kurulumu Doğrula

Aşağıdaki komutlar başarıyla çalışmalıdır:

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

Beklenen:

```text
/bin/zsh
```

veya sistemdeki Zsh yolu.

---

#  Kurulum Tamamlandı

Kurulum tamamlandıktan sonra terminali kapatıp yeniden aç.

Yeni sistemde aşağıdaki ortam hazır olmalıdır:

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
* GNOME Terminal font ayarı
* YYG GNOME klavye kısayolları
* Git global configuration
* Ed25519 SSH key
* Zsh default shell

---

## `yyg-setup.sh`

Bu dokümanın otomatikleştirilmiş shell script versiyonudur.

Scripti ayrıca indirip kullanmak isteyenler:

```bash
chmod +x yyg-setup.sh
./yyg-setup.sh
```

komutlarıyla kurulumu doğrudan gerçekleştirebilir.

**`yyg-setup.sh` kullanmak zorunlu değildir. `yyg-setup.md` tek başına yeterlidir.**

