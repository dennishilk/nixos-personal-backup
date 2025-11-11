#!/usr/bin/env bash
# -----------------------------------------------------------
# nixos-maintain.sh – Safe one-command maintenance for NixOS
# -----------------------------------------------------------
# Tasks:
#   1) Update Nix channels
#   2) Rebuild system with latest packages
#   3) Clean unreferenced store paths (>7d)
#   4) Optimize /nix/store
#   5) Vacuum systemd journals
#   6) Keep pinned generation safe
#
# Usage:
#   sudo ./nixos-maintain.sh
#   sudo ./nixos-maintain.sh --dry-run
#   sudo ./nixos-maintain.sh --days 14 --journal 2G
# -----------------------------------------------------------

set -euo pipefail

DAYS="7d"
JOURNAL_CAP="1G"
DRY_RUN=0
PINNED_PROFILE="/nix/var/nix/profiles/system-stable"
SYSTEM_PROFILE="/nix/var/nix/profiles/system"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --days) DAYS="${2:-}"; shift 2 ;;
    --journal) JOURNAL_CAP="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help)
      echo "Usage: sudo ./nixos-maintain.sh [--days N] [--journal SIZE] [--dry-run]"
      exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY-RUN: $*"
  else
    eval "$@"
  fi
}

echo "=== 🧠 NixOS Maintenance Tool ==="
echo "Keep threshold : $DAYS"
echo "Journal cap    : $JOURNAL_CAP"
echo "Dry-run        : $([[ $DRY_RUN -eq 1 ]] && echo YES || echo NO)"
echo

# Step 1 – Update channels
echo "1️⃣  Updating Nix channels..."
run "sudo nix-channel --update"
echo

# Step 2 – Rebuild system
echo "2️⃣  Rebuilding system with latest packages..."
run "sudo nixos-rebuild switch --upgrade"
echo

# Step 3 – Clean old generations
echo "3️⃣  Removing old system generations..."
run "sudo nix-env --delete-generations old --profile $SYSTEM_PROFILE"
echo

# Step 4 – Garbage collect
echo "4️⃣  Cleaning unreferenced store paths older than $DAYS..."
run "sudo nix-collect-garbage --delete-older-than $DAYS"
echo

# Step 5 – Optimize nix store
echo "5️⃣  Optimizing /nix/store..."
if command -v nix >/dev/null 2>&1; then
  run "sudo nix store optimise || sudo nix-store --optimise"
else
  run "sudo nix-store --optimise"
fi
echo

# Step 6 – Vacuum journals
echo "6️⃣  Vacuuming systemd journal to $JOURNAL_CAP..."
run "sudo journalctl --vacuum-size=$JOURNAL_CAP"
echo

# Step 7 – Confirm pinned system is safe
if [[ -L "$PINNED_PROFILE" ]]; then
  echo "📌 Pinned generation detected: $(readlink -f "$PINNED_PROFILE")"
else
  echo "⚠️  No pinned generation found. Consider running 'sudo ./pin-system.sh'"
fi
echo

# Step 8 – Refresh boot entries
echo "7️⃣  Refreshing boot entries..."
run "sudo /run/current-system/bin/switch-to-configuration boot"
echo

echo "✅ Maintenance complete. System is up-to-date and clean."
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "This was a dry-run. Re-run without --dry-run to apply changes."
fi
