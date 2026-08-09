# Orbital Greeter

Orbital Greeter is a Wayland-native Qt 6 login greeter for `greetd`. It keeps
the greetd, session discovery, power, battery, and Layer Shell backend from
its upstream foundation while providing a fully custom orbital interface.

## Development

```bash
meson setup build --wipe --buildtype=debug
meson compile -C build
./build/orbital-greeter --config ./config/orbital-greeter.conf.example
```

When `GREETD_SOCK` is not set, the greeter uses its built-in mock
authentication flow. Enter `fail` to exercise the failed-authentication UI;
any other response exercises a successful mock login.

## Requirements

- Qt 6: Core, Quick, Quick Controls, Wayland Client, and DBus
- greetd
- Wayland with the `wlr-layer-shell-unstable-v1` protocol
- Meson, a C++17 compiler, and `wayland-scanner`

Use `config/orbital-greeter.conf.example` as the basis for the system
configuration at `/etc/orbital-greeter/orbital-greeter.conf`.

See `INSTALL.md` for Arch packaging, greetd configuration, a safe migration
from SDDM, and rollback instructions.

## Local Arch Package

`packaging/arch/PKGBUILD` builds a local Arch package from the currently
checked-out repository. It does not fetch Git updates and is not an AUR
package.

```bash
cd packaging/arch
makepkg -f
sudo pacman -U orbital-greeter-0.1.0-1-x86_64.pkg.tar.zst
```

To update a local installation, pull the repository changes, rebuild, and
install the resulting package again:

```bash
git pull
cd packaging/arch
makepkg -f
sudo pacman -U orbital-greeter-0.1.0-1-x86_64.pkg.tar.zst
```

Update `pkgver` or `pkgrel` in `packaging/arch/PKGBUILD` for each released
build. Package signing is optional and requires local `makepkg` signing
configuration.

## License

This fork retains the upstream BSD-3-Clause license in `LICENSE`.
