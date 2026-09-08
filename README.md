# File Browser Next Installer

Automated installation scripts for [File Browser Next](https://github.com/FilebrowserNext/filebrowserNEXT).

## Quick Install

### Linux, macOS, BSD

Run in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/FilebrowserNext/get/main/get.sh | bash
```

Or with `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/FilebrowserNext/get/main/get.sh | bash
```

The script will automatically detect your OS and architecture (`amd64` or `arm64`), download the latest release from GitHub, and place the executable in `/usr/local/bin/filebrowser`.

### Windows (PowerShell)

Run in PowerShell as Administrator:

```powershell
iwr -useb https://raw.githubusercontent.com/FilebrowserNext/get/main/get.ps1 | iex
```

The script downloads the latest release, installs it in `C:\Program Files\File Browser Next\`, and adds it to your system PATH.

## Starting File Browser Next

Once installed, start the server pointing to your files:

```bash
filebrowser -r /path/to/your/files
```

Then open your browser at:
`http://127.0.0.1:8080`
