# VentoyDocker

<p align="center">
  <img src="./assets/VentoyDocker.png" alt="VentoyDocker logo" width="300" />
</p>

Run [Ventoy](https://www.ventoy.net/) on macOS via Docker. Create bootable USB drives easily with a web interface.

## Quick Start

**Prerequisites:** Docker, QEMU (`brew install qemu`), USB drive

1. **Clone and setup:**
   ```bash
   git clone https://github.com/Mr-Sunglasses/VentoyDocker.git
   cd VentoyDocker
   chmod +x mount-usb.sh ventoy.sh
   ```

2. **Find your USB device:**
   ```bash
   diskutil list
   # Look for your USB drive, e.g., /dev/disk5 (external, physical)
   ```

3. **Mount USB and start Ventoy:**
   ```bash
   # Terminal 1: Mount USB device
   sudo ./mount-usb.sh -d /dev/disk5

   # Terminal 2: Start Ventoy
   ./ventoy.sh
   ```

4. **Access VentoyWeb:**
   Open `http://localhost:24680` in your browser

5. **Exit:**
   Press `Ctrl+C` in Terminal 2 (auto-cleanup)

## Configuration

**Optional:** Customize settings in `.env`:
```bash
cp .env.example .env
# Edit .env for Ventoy version, ports, etc.
```

**Custom ports:**
```bash
sudo ./mount-usb.sh -d /dev/disk5 -p 10809  # NBD port
./ventoy.sh -p 8080                         # Web port
```

## Troubleshooting

**Rebuild after updates:**
```bash
docker rmi ventoy-docker:1.1.07
./ventoy.sh
```

**CLI mode:**
Press `Ctrl+C`, restart container, run: `./scripts/container/mount.sh && bash`

## Notes

- ✅ Supports: Ventoy CLI, VentoyWeb
- ❌ Not supported: Ventoy GUI

----

### Contributing via GitHub

We welcome _everyone_ to contribute to issue reports, suggest new features, and create pull requests.

If you have something to add - anything from a typo through to a whole new feature, we're happy to check it out! Just make sure to fill out our template when submitting your request; the questions it asks will help the volunteers quickly understand what you're aiming to achieve.

-----

## Authors

- [@Mr-Sunglasses](https://www.github.com/Mr-Sunglasses)

## License

[MIT](https://choosealicense.com/licenses/mit/)

## 💪 Thanks to all Wonderful Contributors

Thanks a lot for spending your time helping VentoyDocker grow.
Thanks a lot! Keep rocking 🍻

[![Contributors](https://contrib.rocks/image?repo=Mr-Sunglasses/VentoyDocker)](https://github.com/Mr-Sunglasses/VentoyDocker/graphs/contributors)

## 🙏 Support++

This project needs your shiny star ⭐.
Don't forget to leave a star ⭐️

[![forthebadge](https://forthebadge.com/images/badges/built-with-love.svg)](https://forthebadge.com)
