#!/usr/bin/env bash
# =========================================================
# Dennis Hilk – NixOS Restore Script (for Encrypted Backup)
# Version: 1.0
# =========================================================
# Restores an encrypted backup created by nixos-backup.sh
# Decrypts with AES-256 and extracts safely to ~/restore-<date>
# =========================================================

set -e

WORKDIR="$(pwd)"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
RESTORE_DIR="$WORKDIR/restore-$DATE"

mkdir -p "$RESTORE_DIR"

echo "🔍 Searching for encrypted backup in:"
echo "   $WORKDIR"
echo

LATEST_BACKUP=$(ls -t nixos-backup-*.tar.gz.enc 2>/dev/null | head -n 1 || true)

if [[ -z "$LATEST_BACKUP" ]]; then
  echo "❌ No encrypted backup (*.enc) found in this folder."
  exit 1
fi

echo "📦 Found backup file: $LATEST_BACKUP"
echo

# ---------------------------------------------------------
# 1️⃣ Ask for password
# ---------------------------------------------------------
echo -n "Enter decryption password: "
read -s password
echo

# ---------------------------------------------------------
# 2️⃣ Decrypt archive
# ---------------------------------------------------------
echo "🔓 Decrypting archive..."
if ! echo "$password" | openssl enc -aes-256-cbc -d -pbkdf2 \
    -in "$LATEST_BACKUP" -out "$RESTORE_DIR/nixos-backup.tar.gz" -pass stdin 2>/dev/null; then
  echo "❌ Decryption failed. Wrong password or corrupt file."
  rm -rf "$RESTORE_DIR"
  exit 1
fi

# ---------------------------------------------------------
# 3️⃣ Extract safely
# ---------------------------------------------------------
echo "🗜️ Extracting archive to: $RESTORE_DIR"
tar -xzf "$RESTORE_DIR/nixos-backup.tar.gz" -C "$RESTORE_DIR"
rm "$RESTORE_DIR/nixos-backup.tar.gz"

# ---------------------------------------------------------
# 4️⃣ Show summary
# ---------------------------------------------------------
echo "✅ Restore completed successfully!"
echo "📁 Files extracted to:"
echo "   $RESTORE_DIR"
echo
echo "Contents:"
ls -l "$RESTORE_DIR"

# ---------------------------------------------------------
# 5️⃣ Optional info
# ---------------------------------------------------------
echo
echo "💡 Tip: To restore your configuration:"
echo "  sudo cp -r $RESTORE_DIR/system/* /etc/nixos/"
echo "  cp -r $RESTORE_DIR/userconfig/* ~/.config/"
echo "  cp -r $RESTORE_DIR/homefiles/* ~/"

echo
echo "🧩 Done!"