# screenshot-upload

Automatically uploads screenshots to a remote server, copies the URL to your clipboard, and syncs processed files via iCloud.

Uses macOS launchd `WatchPaths` to monitor a folder—no Automator folder actions required.

## How It Works

```
┌────────────────────────────┐
│  Screenshot saved to       │
│  ~/Documents/Screenshots/  │
└─────────────┬──────────────┘
              │
              ▼
┌────────────────────────────┐
│  launchd detects change    │
│  (WatchPaths)              │
└─────────────┬──────────────┘
              │
              ▼
┌────────────────────────────┐
│  Script runs:              │
│  1. scp to server (tmp)    │
│  2. ssh rename on server   │
│  3. pbcopy URL             │
│  4. mv to Processed/       │
│  5. Notification           │
└─────────────┬──────────────┘
              │
              ▼
┌────────────────────────────┐
│  iCloud syncs Processed/   │
│  to other Macs             │
└────────────────────────────┘
```

## Prerequisites

- SSH key authentication configured for your remote host
- Remote directory exists and is writable
- macOS (tested on Sonoma/Sequoia)

## Installation

1. Clone the repo:
   ```bash
   git clone https://github.com/youruser/screenshot-upload.git
   cd screenshot-upload
   ```

2. Edit `upload-screenshot.sh` and set your configuration:
   ```bash
   host='your-ssh-host'
   remotedir="/path/to/remote/directory"
   webhost="your.domain.com"
   ```

3. Run the installer:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## Usage

1. Take a screenshot (Cmd+Shift+4, etc.)
2. Save it to `~/Documents/Screenshots/`
3. Wait ~2 seconds
4. URL is in your clipboard—paste it anywhere

## Configuration

Edit `~/.local/bin/upload-screenshot.sh` to change settings:

```bash
host='your-ssh-host'                    # SSH host (from ~/.ssh/config or hostname)
remotedir="/var/www/html/screenshots"   # Remote path
webhost="screenshots.example.com"       # Public URL base
src="$HOME/Documents/Screenshots"       # Watch folder
processed="$HOME/Documents/Screenshots/Processed"  # Destination folder
```

After editing, reload the agent:

```bash
launchctl unload ~/Library/LaunchAgents/org.iaconelli.screenshot-upload.plist
launchctl load ~/Library/LaunchAgents/org.iaconelli.screenshot-upload.plist
```

## Logs

```bash
# Script log (uploads, errors)
tail -f ~/Library/Logs/screenshot-upload.log

# launchd log (agent issues)
tail -f ~/Library/Logs/screenshot-upload-launchd.log
```

## Uninstallation

```bash
./uninstall.sh
```

## Troubleshooting

### Agent not running?

```bash
launchctl list | grep screenshot
# Should show: -  0  org.iaconelli.screenshot-upload
```

### Nothing happening?

```bash
# Check if the watch folder exists
ls -la ~/Documents/Screenshots/

# Check logs
tail -20 ~/Library/Logs/screenshot-upload.log
```

### SSH failing?

```bash
# Test connection manually
ssh your-host "echo ok"

# Ensure agent has access to SSH keys
ssh-add -l
```

launchd jobs run non-interactively. If your SSH host key isn't in `~/.ssh/known_hosts`, the connection will fail silently. Run an interactive SSH connection first to accept the host key:

```bash
ssh your-host "echo ok"
```

If you're using `UserKnownHostsFile /dev/null` in your SSH config, remove it—launchd jobs need persistent known_hosts.

### Permission denied on remote?

```bash
ssh your-host "ls -la /path/to/remote/directory"
```

## Why launchd instead of Folder Actions?

- **Reproducible**: Plain text files, version-controllable, scriptable deployment
- **Reliable**: launchd is PID 1, always running
- **Diagnosable**: Clear logs, standard tooling (`launchctl`)
- **Portable**: Copy the files to a new Mac, run the installer, done

Folder Actions require GUI configuration and offer no way to automate setup.

## Licence

MIT
