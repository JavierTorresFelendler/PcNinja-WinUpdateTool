@echo off
setlocal
set "MSI=%~dp0..\PcNinja-WinUpdateTool-V2.0.0-RC20-Setup-x64.msi"
msiexec /i "%MSI%" /qn /norestart
exit /b %ERRORLEVEL%
