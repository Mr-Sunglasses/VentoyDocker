# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VentoyDocker enables running Ventoy (bootable USB creation tool) via Docker, primarily targeting macOS users since Ventoy doesn't officially support macOS. The project uses qemu-nbd to bridge the host's USB device to a Docker container running Ventoy.

## Architecture

### Two-Process System
The project requires two separate processes working together:

1. **NBD Server (Host)**: `StartNbd.sh` runs qemu-nbd on the macOS host to expose the USB device over TCP
2. **Ventoy Container**: `StartVentoy.sh` runs a Docker container that connects to the NBD server and runs Ventoy CLI/Web

### Communication Flow
```
macOS USB Device → qemu-nbd (port 10809) → Docker container → nbd-client → /dev/nbd0 → Ventoy
```

The container connects to the host via `host.docker.internal` to access the NBD server.

## Key Commands

### Building and Running
```bash
# 1. Start NBD server (MUST run first, requires sudo)
sudo ./mount-usb.sh -d /dev/diskN [-p 10809]

# 2. Start Ventoy container (run in separate terminal)
./ventoy.sh [-p 24680]

# Container automatically:
# - Mounts NBD device at /dev/nbd0
# - Starts VentoyWeb on 0.0.0.0:24680
# - Sets up cleanup trap for safe exit

# 3. Access VentoyWeb in browser
# Open: http://localhost:24680

# 4. Exit with Ctrl+C (cleanup happens automatically)
```

### Manual Operations (if needed)
```bash
# Manual mount (if auto-mount fails)
./scripts/container/mount.sh [-d /dev/nbd0] [-p 10809]

# Manual cleanup (if needed before exit)
./scripts/container/cleanup.sh [-d /dev/nbd0]
```

### Finding USB Device Path
```bash
diskutil list
# Look for external disk (e.g., /dev/disk5)
```

## Important Implementation Details

### Platform Support
- **macOS only**: Linux users should use Ventoy natively
- Requires QEMU installed via Homebrew: `brew install qemu`
- Scripts include OS detection and validation

### Docker Image
- Based on `ubuntu:latest`
- Tagged as `ventoy-docker:1.1.07` (matches Ventoy version)
- Auto-builds on first run if not present
- Contains Ventoy 1.1.07 extracted to `/root/ventoy-1.1.07`

### Critical Safety Measures
- NBD device is automatically detached on container exit via EXIT trap
- Manual cleanup available via `./scripts/container/cleanup.sh` if needed
- USB device is forcibly unmounted before starting qemu-nbd
- All scripts use `set -euo pipefail` for error handling

### Port Configuration
- Default NBD port: `10809` (configurable with `-p`)
- Default VentoyWeb port: `24680` (configurable with `-p`)
- Container runs with `--privileged` flag for device access

### Supported Features
- ✅ Ventoy CLI
- ✅ VentoyWeb interface (browser-based)
- ❌ Ventoy GUI (not supported in container)

## Script Locations
- `mount-usb.sh`: Host-side NBD server startup
- `ventoy.sh`: Host-side Docker container startup
- `scripts/container/entrypoint.sh`: Container entrypoint (auto-mount + cleanup trap)
- `scripts/container/mount.sh`: Manual NBD mount (fallback)
- `scripts/container/cleanup.sh`: Manual NBD cleanup (fallback)
