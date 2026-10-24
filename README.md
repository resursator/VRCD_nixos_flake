
# VR CyberDeck for NixOS

Nix flake for packaging [VR CyberDeck](https://github.com/DeliciousMeatPop/VRCD) on NixOS.

VR CyberDeck is a desktop application for sideloading apps to Android devices and Meta Quest headsets. This flake packages the upstream AppImage using NixOS `appimageTools` and integrates the application with the desktop environment.

## Features

- Packages the upstream VR CyberDeck AppImage.
- Provides a desktop launcher and application icon.
- Includes `adb` utilities from `android-tools`.
- Includes `7z` utilities from `p7zip`.
- Supports running the application through `nix run`.
- Uses a pinned Nixpkgs revision through `flake.lock`.

## Architecture support

| Architecture | Upstream binary | Status |
| --- | --- | --- |
| x86_64 Linux | `vr-cyberdeck-1.8.7-x86_64.AppImage` | Tested |
| ARM64 Linux | `vr-cyberdeck-1.8.7-arm64.AppImage` | Untested |

ARM64 support is included based on the availability of an upstream ARM64 AppImage. It is expected to work on compatible ARM64 Linux systems, but has not been tested. Compatibility may depend on the system configuration, available libraries, and graphical environment.

## Requirements

- Nix with Flakes enabled.
- NixOS or another compatible Linux distribution.
- A supported Linux architecture: x86_64 or ARM64.
- A working graphical desktop environment.

## Usage

### Run directly

Run the application without installing it into your system configuration:

```bash
nix run github:resursator/VRCD_nixos_flake
```

To run from a local clone:

```bash
nix run .
```

### Build the package

```bash
nix build
```

The resulting application will be available through the `result` symlink.

### Install into a NixOS configuration

Add the flake as an input to your system configuration:

```nix
{
  inputs.vrcd.url = "github:resursator/VRCD_nixos_flake";

  outputs = { self, nixpkgs, vrcd, ... }: {
    # Your existing NixOS configuration
  };
}
```

Add the package to your system packages:

```nix
environment.systemPackages = [
  inputs.vrcd.packages.${pkgs.system}.default
];
```

Rebuild your system:

```bash
sudo nixos-rebuild switch --flake /path/to/your/flake#your-host
```

After installation, launch **VR CyberDeck** from your desktop application menu or run:

```bash
vr-cyberdeck
```

## Updating

The upstream AppImage version and its hash are defined in `flake.nix`.

To update to a new release:

1. Change the download URL to the desired upstream release.
2. Update the package version.
3. Update the source hash.
4. Update `flake.lock` if you want to use a newer Nixpkgs revision.
5. Build and test the package.

To calculate a new source hash, use:

```bash
nix store prefetch-file --hash-type sha256 <URL>
```

Replace the hash in `flake.nix` with the resulting SRI hash.

## Project structure

```text
VRCD_nixos_flake/
├── flake.nix
├── flake.lock
└── README.md
```

- `flake.nix` — AppImage packaging, desktop integration, and flake outputs.
- `flake.lock` — Pinned Nixpkgs revision and dependency metadata.

## License

This repository contains Nix packaging for VR CyberDeck and does not redistribute the upstream AppImage directly.

VR CyberDeck is licensed under the GNU Affero General Public License v3. The original application and its source code are maintained by the upstream project.

- Upstream: https://github.com/DeliciousMeatPop/VRCD
- License: https://www.gnu.org/licenses/agpl-3.0.html
