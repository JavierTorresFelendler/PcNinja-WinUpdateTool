# V2.0.0-RC1 VM Test Checklist

Target VM: Windows 10 or Windows 11 test machine.

RC build policy:

- Unsigned.
- Local build only.
- No GitHub push required.
- Use public release artifacts from `public-release`.

## Files To Copy To VM

- `PcNinja-WinUpdateTool-V2.0.0-RC1-Setup-x64.msi`
- `PcNinja-WinUpdateTool-V2.0.0-RC1-Portable.exe`
- `SHA256SUMS.txt`
- `update-manifest.json`
- `deployment-examples\`

## Install Test

1. Install MSI interactively.
2. Confirm install folder:
   - `C:\Program Files\PcNinja\WinUpdateTool`
3. Confirm app appears in Installed Apps / Programs and Features.
4. Confirm version:
   - `2.0.0.0`
5. Launch GUI.
6. Confirm tabs:
   - Dashboard
   - Updates
   - Schedule
   - Drivers
   - Logs

## CLI Smoke Tests

Run from an elevated terminal:

```cmd
"%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe" /?
"%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe" -Mode Status -Json
"%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe" -Mode AppUpdateCheck -ManifestUrl "C:\Temp\update-manifest.json" -Json
```

Expected:

- Help shows `V2.0.0-RC1`.
- Status returns JSON.
- AppUpdateCheck reads manifest and reports `UpToDate` or `UpdateAvailable`.

## Portable Test

```cmd
PcNinja-WinUpdateTool-V2.0.0-RC1-Portable.exe /?
PcNinja-WinUpdateTool-V2.0.0-RC1-Portable.exe -Mode Status -Json
```

Expected:

- Help shows public portable filename.
- Extraction path:
  - `%LOCALAPPDATA%\PcNinja\WinUpdateTool\Portable\2.0.0.0`

## App Update Handoff Test

For RC1, app-update install is user-initiated and still needs VM validation.

Use a future test manifest that points from RC1 to a newer RC/MSI.

Expected flow:

1. AppUpdateCheck detects newer version.
2. AppUpdateDownload downloads MSI.
3. SHA256 matches.
4. AppUpdateInstall starts `msiexec`.
5. Current app exits or is closed before file replacement.

Do not use a production customer machine for the first handoff test.

## Destructive Windows Update Reset Test

Run only in the VM:

```cmd
"%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe" -Mode ResetWindowsUpdate -ConfirmReset -Json
```

Expected:

- Stops Windows Update related services.
- Recreates `C:\Windows\SoftwareDistribution`.
- Restarts services.
- Returns `Succeeded` or `SucceededWithWarnings`.

## Windows Update Run Test

Run only in the VM:

```cmd
"%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe" -Mode RunUpdates -Silent -RunType Manual -Json
```

Expected:

- Does not collide with active Windows Update.
- Uses retry/Snooz behavior when background activity exists.
- Logs result under:
  - `%ProgramData%\PcNinja\WinUpdateTool\Logs`

## Uninstall Test

1. Uninstall from Installed Apps / Programs and Features.
2. Confirm scheduled tasks are removed:
   - `\PcNinja\PcNinja WinUpdate Tool`
   - `\PcNinja\PcNinja WinUpdate Tool Retry`
   - `\PcNinja\PcNinja WinUpdate Tool Run Once`
3. Confirm install folder is removed.
4. Confirm no stale shortcut remains.
