#!/usr/bin/env bash
# =========================================================
# Dennis Hilk – NixOS Local Backup Script (Encrypted + Clean)
# Version: 1.0 (with password confirmation & cleanup)
# =========================================================
# Secure local backup for:
#   /etc/nixos  (System configuration)
#   ~/.config   (User configuration)
#   ~/.zshrc, ~/.bashrc, etc.
# =========================================================

set -e

BACKUP_DIR="$HOME/backup"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="nixos-backup-$DATE.tar.gz"
ENCRYPTED_ARCHIVE="$BACKUP_DIR/$ARCHIVE_NAME.enc"

echo "🧩 Starting NixOS Backup: $DATE"
mkdir -p "$BACKUP_DIR/system" "$BACKUP_DIR/userconfig" "$BACKUP_DIR/homefiles"

# 1️⃣ Backup system configuration (/etc/nixos)
echo "📦 Backing up system configuration..."
sudo rsync -a --delete /etc/nixos/ "$BACKUP_DIR/system/"
sudo chown -R "$USER":users "$BACKUP_DIR/system"

# ---------------------------------------------------------
# 2️⃣ Backup user configuration (~/.config)
# ---------------------------------------------------------
echo "🧠 Backing up user configuration..."
rsync -a --delete \
  --exclude "BraveSoftware/" \
  --exclude "chromium/" \
  --exclude "google-chrome/" \
  --exclude "Google/" \
  --exclude "mozilla/" \
  --exclude "firefox/" \
  --exclude "vivaldi/" \
  --exclude "discord/" \
  --exclude "obsidian/" \
  --exclude "teams/" \
  --exclude "thunderbird/" \
  --exclude ".cache/" \
  --exclude "Code/" \
  "$HOME/.config/" "$BACKUP_DIR/userconfig/"

# ---------------------------------------------------------
# 3️⃣ Backup essential home files
# ---------------------------------------------------------
echo "🧾 Backing up essential home files..."
for file in .bashrc .zshrc .profile .gitconfig .bash_profile .p10k.zsh; do
  [ -f "$HOME/$file" ] && cp "$HOME/$file" "$BACKUP_DIR/homefiles/"
done

# ---------------------------------------------------------
# 4️⃣ Add README if not present
# ---------------------------------------------------------
if [[ ! -f "$BACKUP_DIR/README.md" ]]; then
cat > "$BACKUP_DIR/README.md" <<'EOF'
# 🐧 Dennis Hilk – NixOS Local Backup

This folder contains a **local manual backup** of my NixOS setup.

## Structure
- `system/` → /etc/nixos (system configuration)
- `userconfig/` → ~/.config (user applications, themes, Fastfetch, Kitty, etc.)
- `homefiles/` → .zshrc, .bashrc, .gitconfig, etc.

## Privacy Notice
Browser data (Firefox, Chrome, Brave, etc.), cache folders, and application secrets are **automatically excluded**.

> Manual backup only – not intended for public use.
EOF
fi

# ---------------------------------------------------------
# 5️⃣ Create archive
# ---------------------------------------------------------
echo "🗜️ Creating compressed archive..."
cd "$BACKUP_DIR"
tar -czf "$ARCHIVE_NAME" system userconfig homefiles README.md

# ---------------------------------------------------------
# 6️⃣ Encrypt with password confirmation
# ---------------------------------------------------------
echo "🔒 Encrypting archive with AES-256..."
while true; do
  echo -n "Enter encryption password: "
  read -s pass1
  echo
  echo -n "Confirm password: "
  read -s pass2
  echo
  if [[ "$pass1" == "$pass2" && -n "$pass1" ]]; then
    echo "✅ Password confirmed."
    break
  else
    echo "❌ Passwords do not match. Please try again."
  fi
done

# Encrypt with AES-256 and PBKDF2 for safety
echo "$pass1" | openssl enc -aes-256-cbc -salt -pbkdf2 \
  -in "$ARCHIVE_NAME" -out "$ENCRYPTED_ARCHIVE" -pass stdin

# Verify encryption success
if [ -f "$ENCRYPTED_ARCHIVE" ]; then
  echo "🧪 Verifying encrypted archive integrity..."
  if openssl enc -aes-256-cbc -d -pbkdf2 -in "$ENCRYPTED_ARCHIVE" -pass pass:"$pass1" -out /dev/null 2>/dev/null; then
    echo "✅ Encryption verified successfully."
  else
    echo "⚠️ Warning: Encryption test failed. Please recheck manually."
  fi

  # Remove unencrypted archive securely
  shred -u "$ARCHIVE_NAME"

  # ---------------------------------------------------------
  # 7️⃣ Cleanup temporary files
  # ---------------------------------------------------------
  echo "🧹 Cleaning up temporary unencrypted backup folders..."
  rm -rf "$BACKUP_DIR/system" "$BACKUP_DIR/userconfig" "$BACKUP_DIR/homefiles"
  echo "✅ Cleanup completed."
else
  echo "❌ Encryption failed or archive missing. Keeping temporary folders for safety."
fi

# ---------------------------------------------------------
# 8️⃣ Done
# ---------------------------------------------------------
echo "✅ Backup completed and encrypted successfully!"
echo "📁 Encrypted file saved as:"
echo "   $ENCRYPTED_ARCHIVE"
