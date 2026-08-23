# Omarchy on...

### Apple M1/M2 chips

Do not flash the Omarchy ISO. It is x86_64 and will not boot Apple Silicon.

Install [Asahi Alarm](https://asahi-alarm.org/) (Arch for M1/M2, built on [Asahi Linux](https://asahilinux.org/)) from macOS, then layer Omarchy on top. Keep macOS — the Asahi installer shrinks APFS; a wipe is not required and makes firmware updates harder.

From macOS Terminal:

```bash
curl https://asahi-alarm.org/installer-bootstrap.sh | sh
```

Choose **Asahi Alarm Minimal (BTRFS)** and give Linux at least 50 GB (100 GB is more comfortable). Boot into Arch, log in as root, get Wi-Fi up with `nmtui`, then:

```bash
curl -fsSL https://raw.githubusercontent.com/basecamp/omarchy/quattro/bin/omarchy-mac-setup | bash
```

That moves `/boot` onto the EFI partition, optionally encrypts the root, and installs Omarchy. Reboots happen in between; the script resumes itself on tty1. Pass `--no-encrypt` to skip encryption, or `--repo`/`--ref` to install from a fork.

To install from a local checkout of this tree instead of cloning GitHub (the way to try the port before it is on origin):

```bash
sudo OMARCHY_SETUP_SRC=/path/to/omarchy bash /path/to/omarchy/bin/omarchy-mac-setup
```

Some default packages have no aarch64 build (OBS, Pinta, gpu-screen-recorder). The installer skips those and uses substitutes where they exist (mise instead of mise-bin, wf-recorder instead of gpu-screen-recorder, Obsidian's AppImage). USB-C / Thunderbolt displays and Touch ID are still Asahi limitations, not Omarchy ones.

See also [docs/btrfs.md](../docs/btrfs.md) for the snapshot and encryption layout on Apple Silicon.

### Apple Virtual Machine

You can also install Omarchy inside a Parallels VM. Quite the cumbersome process, but there's [a user-driven guide](https://github.com/basecamp/omarchy/discussions/452) for that too.

### VirtualBox

VirtualBox is a popular VM runner. [You can run Omarchy inside that too](https://github.com/basecamp/omarchy/discussions/176). But performance probably won't be great.

### VMware Workstation on Windows 11

Another popular VM runner for Windows. [Omarchy has been setup inside of that as well](https://github.com/basecamp/omarchy/discussions/572).

### Steam Deck

The Steam Deck runs on Arch, which means you can run Omarchy on your Steam Deck. Altynbek Orumbayev has [a full setup script and explanation on how to do it](https://github.com/aorumbayev/deckarchy). How cool is that!

### NixOS

Omarchy is really Arch + Hyprland, but Henry Sipp has [ported the essence of the setup to NixOS](https://github.com/henrysipp/omarchy-nix). So if you've been nix-pilled, here's a good starting point. It may or may not stay up-to-date with the latest Omarchy changes, but it's pretty cool none the less!

### Something else!

If you're trying to get Omarchy running on a configuration that isn't the default, you should join the #omarchy-on-other channel on [our community Discord](https://discord.gg/tXFUdasqhY).
