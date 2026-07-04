# PcNinja WinUpdate Tool V2 Roadmap

Source channel: https://github.com/JavierTorresFelendler/PcNinja-WinUpdateTool

Current stable baseline: V1.1.2

Target public release: V2.0.0

Target internal version: 2.0.0.0

## V2.0 Direction

V2.0 is a safe production upgrade, not a risky rewrite.

Goals:

- Keep Windows Update / Microsoft Update as the trusted install source.
- Keep MSI and Portable EXE as first-class artifacts.
- Keep CLI support for installed and portable flows.
- Keep silent MSI deployment compatible with BigFix/RMM.
- Add GitHub release pipeline support.
- Add a safe PcNinja Tool Update check based on release artifacts, hashes, and a manifest.
- Improve Dashboard clarity, health visibility, and logs without slowing startup.

## V2.0 Scope

1. Version manifest
   - One source of truth for public label and internal version.
   - Used by PowerShell, C# launchers, WiX, packaging, release notes, and manifest generation.

2. GitHub release pipeline
   - Build through `packaging/Build-Packages.ps1`.
   - Produce MSI, Portable EXE, SHA256 hashes, public ZIP, and `update-manifest.json`.
   - Publish draft/prerelease artifacts from GitHub Actions.

3. App update check
   - Add `AppUpdateCheck -Json`.
   - Add `AppUpdateDownload -Json`.
   - Add user-initiated `AppUpdateInstall -Json` for installed MSI deployments.
   - Verify HTTPS source, version, file name, SHA256, and signature when available.
   - Download verified MSI to an app-controlled update cache.
   - Launch the MSI and let the installer close only PcNinja WinUpdate Tool processes before file replacement.
   - Keep fully silent self-update deferred until the user-initiated path is proven stable.

4. Health and diagnostics
   - Add `HealthCheck -Json`.
   - Add non-destructive reset preview.
   - Normalize JSON output fields for automation.

5. UI polish
   - Preserve WinForms and Windows PowerShell 5.1 compatibility.
   - Keep tabs: Dashboard, Updates, Schedule, Drivers, Logs.
   - Make dark theme the polished default direction.
   - Clearly separate Windows Updates from PcNinja Tool Update.

## Deferred To V2.1+

- Fully silent self-update installation.
- Automatic portable self-replacement.
- Vendor-specific driver installation.
- Cloud/fleet dashboard.
- Intune package generation.
- Full UI rewrite outside WinForms.

## Build Safety

Do not run destructive Windows Update reset or live update installation on the developer machine unless Javier explicitly approves a VM/live test.
