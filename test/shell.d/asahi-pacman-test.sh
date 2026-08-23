#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

for channel in stable rc edge; do
  conf="$ROOT/default/pacman/pacman-$channel-aarch64.conf"
  [[ -f $conf ]] || fail "pacman-$channel-aarch64.conf exists"

  grep -q '^Architecture = aarch64' "$conf" ||
    fail "pacman-$channel-aarch64.conf sets Architecture = aarch64"
  grep -q '^\[asahi-alarm\]' "$conf" ||
    fail "pacman-$channel-aarch64.conf offers the asahi-alarm repo"
  grep -q '^\[omarchy-aarch64\]' "$conf" ||
    fail "pacman-$channel-aarch64.conf offers the omarchy-aarch64 repo"
  ! grep -q '^\[multilib\]' "$conf" ||
    fail "pacman-$channel-aarch64.conf has no x86 multilib repo"
done
pass "aarch64 pacman channel configs target Asahi Alarm"

grep -q 'github.com/asahi-alarm/asahi-alarm/releases/download/\$arch' \
  "$ROOT/default/pacman/mirrorlist.asahi-alarm" ||
  fail "asahi-alarm mirrorlist points at the Asahi Alarm repo"
pass "asahi-alarm mirrorlist points at the Asahi Alarm repo"

grep -q 'uname -m' "$ROOT/bin/omarchy-refresh-pacman" ||
  fail "omarchy-refresh-pacman selects the aarch64 overlay"
grep -q 'pacman-\$channel-aarch64.conf' "$ROOT/bin/omarchy-refresh-pacman" ||
  fail "omarchy-refresh-pacman copies the aarch64 pacman conf"
pass "omarchy-refresh-pacman selects the aarch64 overlay"

# x86 configs stay x86: finishing the Asahi port must not rewrite the ISO path.
grep -q '^Architecture = auto' "$ROOT/default/pacman/pacman-stable.conf" ||
  fail "x86 pacman-stable.conf keeps Architecture = auto"
grep -q '^\[omarchy\]' "$ROOT/default/pacman/pacman-stable.conf" ||
  fail "x86 pacman-stable.conf still offers pkgs.omarchy.org"
! grep -q '^Architecture = aarch64' "$ROOT/default/pacman/pacman-stable.conf" ||
  fail "x86 pacman-stable.conf is not the ARM overlay"
pass "x86 pacman configs are unchanged"
