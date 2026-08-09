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

## License

This fork retains the upstream BSD-3-Clause license in `LICENSE`.
