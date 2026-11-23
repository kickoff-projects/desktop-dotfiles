# Proton VPN CLI reference

`protonvpn` 1.0.1 on this system. One sample per option and per setting value.
Run `protonvpn [command] --help` for the help text that this file comes from.

## Global options

| Option | Sample |
| --- | --- |
| `-v, --verbose` | `protonvpn -v connect --country US` |
| `-h, --help` | `protonvpn --help` |

There is no `--version` flag. It exits 2 with `Error: No such option:
--version`. The version number is in the banner of `protonvpn --help`.

## Account

```sh
protonvpn signin user@proton.me   # USERNAME is a positional argument
protonvpn signout                 # signs out and deletes the local credentials
protonvpn info                    # plan, username, tier
```

The `signin` usage line marks `USERNAME` as required, but the top-level help
examples also show the bare form `protonvpn signin`.

## Connect

`SERVER_NAME` is a positional argument. The option flags select a server
instead of naming one.

```sh
protonvpn connect                      # fastest server worldwide
protonvpn connect IT#23                # one named server
protonvpn connect --country US         # code or "United States"
protonvpn connect --city "New York"    # quote a multi-word city
protonvpn connect --p2p                # fastest P2P server
protonvpn connect -sc                  # --securecore, Secure Core routing
protonvpn connect --tor                # Tor over VPN
protonvpn connect --random             # random available server
```

Flags combine with a location:

```sh
protonvpn connect --country IT --p2p
```

## Disconnect and status

```sh
protonvpn disconnect   # stops the tunnel and restores the network configuration
protonvpn status       # server, load, protocol
```

## Discovery

```sh
protonvpn servers                      # prints the protonvpn.com server-list link
protonvpn countries list               # country names, two-letter codes, server counts
protonvpn cities list US               # cities in a country, code or full name
```

`protonvpn servers` prints a link only. It shows no server table.

## Configuration

```sh
protonvpn config list   # current value of every setting
```

One sample of each `config set` setting and each accepted value:

```sh
protonvpn config set netshield off
protonvpn config set netshield malware-only
protonvpn config set netshield malware-ads-trackers   # recommended

protonvpn config set kill-switch off
protonvpn config set kill-switch standard             # blocks traffic if the tunnel drops

protonvpn config set port-forwarding on
protonvpn config set port-forwarding off

protonvpn config set custom-dns on --dns 1.1.1.1,8.8.8.8
protonvpn config set custom-dns on --dns 2606:4700:4700::1111
protonvpn config set custom-dns off                   # use the Proton DNS servers

protonvpn config set vpn-accelerator on               # recommended
protonvpn config set vpn-accelerator off

protonvpn config set moderate-nat on                  # better gaming and P2P connectivity
protonvpn config set moderate-nat off                 # strict NAT

protonvpn config set ipv6 on
protonvpn config set ipv6 off                         # default

protonvpn config set anonymous-crash-reports on
protonvpn config set anonymous-crash-reports off
```

`--dns` is the only option of a `config set` subcommand. It takes a
comma-separated list of IPv4 or IPv6 addresses and applies to `custom-dns on`.

Port forwarding needs an external script to keep the port lease. Without the
script the port expires. See
https://protonvpn.com/support/port-forwarding-manual-setup#linux

There is no protocol setting in this version. NetworkManager owns the tunnel,
and the protocol in use shows in `protonvpn status` and in the waybar module
`common/.config/hypr/scripts/waybar-protonvpn.sh`.

## Notes for this repository

1. The zsh alias `vpn` starts the GUI `protonvpn-app`, not this CLI. See
   `system/base/shells/zsh.nix`.
2. The waybar module reads `nmcli`, not `protonvpn status`, because
   `protonvpn status` parses the 25 MB server-list cache on every call.
