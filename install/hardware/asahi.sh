# Apple Silicon (Asahi Alarm) system setup that has no analogue on x86.
# Intel Macs take the T2/SPI/Broadcom path instead and must not land here.

omarchy-hw-asahi || return 0

echo "Detected Apple Silicon (Asahi)"

# The community aarch64 package repo carries prebuilt Omarchy packages that
# otherwise compile for hours and then fail an architecture check (herdr's
# zig0.15 is the usual one). Official pkgs.omarchy.org is x86_64 only.
if [[ ! -f /etc/pacman.d/mirrorlist.asahi-alarm ]]; then
  sudo cp -f "$OMARCHY_PATH/default/pacman/mirrorlist.asahi-alarm" /etc/pacman.d/mirrorlist.asahi-alarm
fi

if ! grep -q '^\[asahi-alarm\]' /etc/pacman.conf; then
  cat >> /etc/pacman.conf <<'EOF'

[asahi-alarm]
Include = /etc/pacman.d/mirrorlist.asahi-alarm
EOF
fi

if ! grep -q '^\[omarchy-aarch64\]' /etc/pacman.conf; then
  cat >> /etc/pacman.conf <<'EOF'

[omarchy-aarch64]
SigLevel = Optional TrustAll
Server = https://github.com/omarchy-mac/omarchy-pkgs-aarch64/releases/download/edge
EOF
  sudo pacman -Sy --noconfirm >/dev/null 2>&1 ||
    echo "Warning: could not refresh package databases after adding the ARM repo."
fi

# gpu-screen-recorder cannot initialize on the Asahi GPU. Recording falls back
# to wf-recorder (see omarchy-capture-screenrecording).
if omarchy-pkg-missing wf-recorder; then
  omarchy-pkg-add wf-recorder ||
    echo "Warning: wf-recorder could not be installed; screen recording will not work."
fi
