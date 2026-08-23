#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

base="$ROOT/install/omarchy-base.packages"
unavailable="$ROOT/install/omarchy-aarch64-unavailable.packages"

[[ -f $unavailable ]] || fail "aarch64 unavailable list exists"
pass "aarch64 unavailable list exists"

while read -r package; do
  [[ -n $package ]] || continue
  grep -qx "$package" "$base" ||
    fail "$package is in the unavailable list but not in omarchy-base.packages"
done < <(grep -vE '^[[:space:]]*(#|$)' "$unavailable")
pass "every unavailable package is in the base set"

for package in obs-studio gpu-screen-recorder pinta obsidian dotnet-runtime; do
  grep -qx "$package" "$unavailable" ||
    fail "$package is skipped on aarch64"
done
pass "expensive or x86-only packages are skipped on aarch64"

grep -q 'mise-bin' "$ROOT/install.sh" ||
  fail "install.sh remaps mise-bin for aarch64"
pass "install.sh remaps mise-bin for aarch64"

grep -q 'wf-recorder' "$ROOT/install/hardware/asahi.sh" ||
  fail "Asahi hardware setup installs wf-recorder"
pass "Asahi hardware setup installs wf-recorder"

grep -q 'select_recorder_backend' "$ROOT/bin/omarchy-capture-screenrecording" ||
  fail "screen recording selects a backend"
grep -q 'unknown gpu vendor' "$ROOT/bin/omarchy-capture-screenrecording" ||
  fail "screen recording documents the Asahi GPU fallback"
pass "screen recording falls back to wf-recorder on Asahi"

grep -q 'apple/enable-notch.sh' "$ROOT/install/hardware/all.sh" ||
  fail "notch enable runs during hardware setup"
grep -q 'apple/audio.sh' "$ROOT/install/hardware/all.sh" ||
  fail "Asahi audio runs during hardware setup"
grep -q 'hardware/asahi.sh' "$ROOT/install/hardware/all.sh" ||
  fail "Asahi pacman overlay runs during hardware setup"
pass "Asahi hardware leaves are wired into setup"

grep -q 'apple/obsidian.sh' "$ROOT/install/user/all.sh" ||
  fail "Obsidian AppImage install runs during user setup"
grep -q 'apple/share-picker.sh' "$ROOT/install/user/all.sh" ||
  fail "share-picker git fallback runs during user setup"
pass "Asahi user leaves are wired into setup"
