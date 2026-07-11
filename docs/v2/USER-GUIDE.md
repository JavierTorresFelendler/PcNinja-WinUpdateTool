# PcNinja WinUpdate Tool V2 User Guide

PcNinja WinUpdate Tool V2 is a Windows 10/11 utility for checking and installing Windows Update, Microsoft Update, optional update, and Windows Update driver catalog items from one focused interface.

## Main Workflow

1. Open the tool as Administrator.
2. Go to **Updates**.
3. Select the update scopes you want to include:
   - **Windows updates** for security, cumulative, .NET, and servicing updates.
   - **Optional updates** for browse-only optional packages.
   - **Driver updates** for drivers offered by Windows Update.
   - **Firmware / BIOS updates** only when you explicitly want firmware candidates included.
4. Click **Check Available Updates**.
5. Review the counts and use **View List** when you want to inspect candidates.
6. Click **Install Selected Updates** when you are ready.

## Restart Handling

The **Restart State** panel shows whether Windows currently reports a required reboot.

- **Restart Now** restarts the computer immediately.
- **Details** shows the reason detected by Windows.
- If a restart is pending, the tool can still let you ignore the warning once and continue a check when that is useful.

## Scheduling

Click **Settings** to configure automatic Windows Update runs.

- Choose **Daily**, **Weekly**, or **Monthly**.
- Enable **Also run after startup** when a missed maintenance window should run after user logon.
- Set a startup delay to avoid running immediately at sign-in.
- Use **Wake the computer to run this task** when supported by the machine.
- Use **Run if the task is missed** to let Task Scheduler recover missed runs.
- Use **Save Schedule** in the header to create or update the PcNinja scheduled tasks.
- Use **Clear Schedule** in the header to remove PcNinja WinUpdate Tool scheduled tasks and disable the saved schedule.

## Logs

The **Logs** tab shows live application progress.

- **Refresh** reloads the current log view.
- **Following** toggles live append mode.
- **Bottom** jumps to the newest line.
- **Open Log File** opens the active log in Notepad.
- **Filter logs** narrows the visible log lines.
- **Export Bundle** creates a public support bundle for troubleshooting.

Logs are stored under:

```text
C:\ProgramData\PcNinja\WinUpdateTool\Logs
```

## Tool Updates

The left sidebar shows the installed tool version and latest available version.

- **Check Tool Update** checks the GitHub release manifest.
- MSI builds download the verified MSI and hand off to the installer.
- Portable builds download the next versioned portable EXE beside the current portable file and start the new EXE after download.
- Customer machines do not use `git pull`.

## Drivers

The **Drivers** tab can create a driver inventory audit report and provides reference links for PcNinja tools and manufacturer support pages.

Driver installation remains controlled by Windows Update unless a future vendor module is added.

## Command Line

Installed CLI examples:

```cmd
"%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe" /?
"%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe" -Mode Status -Json
"%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe" -Mode PreviewUpdates -Json
"%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe" -Mode CollectLogs -OutputPath C:\Temp -Json
```

Portable CLI examples:

```cmd
PcNinja-WinUpdateTool-V2.2.2.1-Portable.exe /?
PcNinja-WinUpdateTool-V2.2.2.1-Portable.exe -Mode Status -Json
PcNinja-WinUpdateTool-V2.2.2.1-Portable.exe -Mode AppUpdateCheck -Json
PcNinja-WinUpdateTool-V2.2.2.1-Portable.exe -Mode AppUpdateDownload -UpdatePackageType Portable -Json
```

## Support Links

- V2 repository: <https://github.com/JavierTorresFelendler/PcNinja-WinUpdateTool-V2>
- PcNinja website: <https://www.pcninja.pro>
- Help portal: <https://help.pcninja.pro>

