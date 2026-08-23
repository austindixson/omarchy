#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

rewrite() {
  bash -c '
    source "$1"
    rewrite_esp_mountpoint
  ' -- "$ROOT/bin/omarchy-system-boot-to-esp"
}

fstab=$(cat <<'EOF'
# comment stays
UUID=root / btrfs rw,noatime,subvol=@ 0 0
UUID=esp /boot/efi vfat defaults 0 2
UUID=home /home btrfs rw,noatime,subvol=@home 0 0
EOF
)

rewritten=$(printf '%s\n' "$fstab" | rewrite)

grep -q '^UUID=esp /boot vfat' <<<"$rewritten" ||
  fail "ESP mount point becomes /boot" "$rewritten"
pass "ESP mount point becomes /boot"

grep -q '^# comment stays' <<<"$rewritten" ||
  fail "comments are left alone" "$rewritten"
pass "comments are left alone"

! grep -q '/boot/efi' <<<"$rewritten" ||
  fail "no leftover /boot/efi mount" "$rewritten"
pass "no leftover /boot/efi mount"

grep -q 'subvol=@home' <<<"$rewritten" ||
  fail "other fstab lines are unchanged" "$rewritten"
pass "other fstab lines are unchanged"
