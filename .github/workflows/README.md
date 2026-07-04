# GitHub Workflows

This folder is reserved for GitHub Actions workflows.

Planned V2 workflow:

- release.yml

Expected responsibilities:

- Run syntax checks.
- Build MSI and Portable EXE.
- Validate MSI metadata.
- Generate hashes.
- Generate update-manifest.json.
- Package public release artifacts.
- Upload release artifacts to GitHub Releases.

The release workflow should call the existing packaging script instead of replacing it:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\packaging\Build-Packages.ps1
```
