# 🐧 Dennis Hilk – NixOS System Backup (`cthulhu`)

![NixOS](https://img.shields.io/badge/NixOS-25.05-blue?logo=nixos&logoColor=white)
![Desktop](https://img.shields.io/badge/Desktop-XFCE-orange?logo=xfce&logoColor=white)
![Theme](https://img.shields.io/badge/Theme-Gruvbox-8ec07c?logo=artstation&logoColor=white)
![GPU](https://img.shields.io/badge/NVIDIA-RTX_3060_Ti-76b900?logo=nvidia&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Zsh+Powerlevel10k-1abc9c?logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/Use-At_Your_Own_Risk-red)
![Status](https://img.shields.io/badge/System-cthulhu-success?logo=linux&logoColor=white)


> ⚠️ **Hinweis / Note:**  
> Dies ist **mein persönliches System-Backup** für meinen NixOS-Rechner **"cthulhu"**.  
> Es dient ausschließlich als Referenz und Sicherung meiner eigenen Konfiguration.  
> Andere Nutzer*innen können sich gern inspirieren lassen,  
> aber diese Dateien sind **nicht für die direkte Installation gedacht**.

---

## 🇩🇪 **Über dieses Repository**

Dieses Repository enthält meine aktuelle **NixOS-Konfiguration**  
für mein System **"cthulhu"** (Workstation, Desktop).  
Es spiegelt exakt meinen laufenden Zustand wieder – inklusive:

- 🧠 **Desktop Environment:** XFCE + Picom (GLX)
- 🎨 **Theme:** Gruvbox GTK + Nerd Fonts
- 🧰 **Shell:** Zsh mit Powerlevel10k
- 🧩 **System:** NixOS 25.05 (Warbler)
- ⚙️ **GPU:** NVIDIA RTX 3060 Ti (open module)
- 🧮 **CPU:** AMD Ryzen 7 5800X3D
- 🖥️ **Monitore:** 3440×1440 + 1920×1080
- 🧊 **Kernel:** Linux 6.17+
- 🕹️ **Ziel:** Gaming + Entwicklung + Linux-Optimierung

Dieses Setup ist darauf ausgelegt, **optisch minimalistisch**, **technisch stabil**  
und **leicht reproduzierbar** zu sein – ideal für den Alltag mit NixOS.

---

## 🇬🇧 **About this Repository**

This repository contains my **personal NixOS configuration**
for my workstation **"cthulhu"**.

It represents my actual running setup, including:

- 🧠 **Desktop Environment:** XFCE + Picom (GLX)
- 🎨 **Theme:** Gruvbox GTK + Nerd Fonts
- 🧰 **Shell:** Zsh with Powerlevel10k
- 🧩 **System:** NixOS 25.05 (Warbler)
- ⚙️ **GPU:** NVIDIA RTX 3060 Ti (open driver)
- 🧮 **CPU:** AMD Ryzen 7 5800X3D
- 🖥️ **Monitors:** 3440×1440 + 1920×1080
- 🧊 **Kernel:** Linux 6.17+
- 🕹️ **Purpose:** Gaming, development and desktop optimization

It’s designed to be **clean**, **stable**, and **fully reproducible** –  
perfect for everyday use and testing under NixOS.

### 🔧 Backup Script
The included script `nixos-backup-local.sh` securely creates an encrypted snapshot of your system configuration.

**Features:**
- Copies `/etc/nixos`, `~/.config`, and important home files  
- Automatically excludes browsers, cache, and secrets  
- Compresses everything into a single `.tar.gz`  
- Encrypts the archive with **AES-256** and a **password prompt (with confirmation)**  
- Securely deletes the unencrypted archive after encryption

## 🧱 Required tools

Ensure these are installed (via your configuration.nix):

environment.systemPackages = with pkgs; [
  rsync
  gnutar
  gzip
  openssl
];

### 🧩 Run the backup
```bash
~/nixos-backup-local.sh

## 🧷 License / Usage

This repository does not contain software,
only my personal configuration files.
Feel free to explore or adapt parts of it — at your own risk.

---

## 🐙 Git & Backup

All configuration files are versioned and automatically synchronized with GitHub  
using a daily `systemd` timer (`/usr/local/bin/nixos-backup.sh`).

Manual sync:
```bash
cd /etc/nixos
sudo git add .
sudo git commit -m "Update: new tweaks or packages"
sudo git push
