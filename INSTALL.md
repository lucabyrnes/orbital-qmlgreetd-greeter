# System Installation

Orbital Greeter is a graphical login program. Keep a working TTY login and
leave SDDM installed until greetd has completed several successful login and
logout cycles.

## Build

Install the runtime compositor and build dependencies:

```bash
sudo pacman -S --needed cage greetd meson ninja qt6-base qt6-declarative qt6-quick3d qt6-wayland wayland
```

Build and install the local Arch package from the repository root:

```bash
cd packaging/arch
makepkg -si
```

This installs the binary at `/usr/bin/orbital-greeter` and the default
configuration at `/etc/orbital-greeter/orbital-greeter.conf`.

## Greetd Setup

Back up the existing greetd configuration before replacing it:

```bash
sudo install -d -m 700 /etc/greetd/orbital-greeter-backup
sudo cp -a /etc/greetd/config.toml /etc/greetd/orbital-greeter-backup/config.toml
sudo install -m 644 config/greetd-config.toml.example /etc/greetd/config.toml
```

The example starts Orbital Greeter through Cage on VT1. Cage is a dedicated
greeter compositor; it does not start the normal Hyprland desktop session.

## Migration

From a TTY or after closing all work, prepare the service switch for the next
boot:

```bash
sudo systemctl disable sddm.service
sudo systemctl enable greetd.service
sudo reboot
```

Do not run `systemctl stop sddm` from the graphical session unless an
immediate logout is intended.

## Rollback

Use a TTY if the graphical greeter fails:

```bash
sudo cp -a /etc/greetd/orbital-greeter-backup/config.toml /etc/greetd/config.toml
sudo systemctl disable greetd.service
sudo systemctl enable sddm.service
sudo reboot
```
