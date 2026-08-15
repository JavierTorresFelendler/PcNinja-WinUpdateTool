@echo off
setlocal
set "MSI=%~dp0..\PcNinja-WinUpdateTool-V2.2.5-RC1-Setup-x64.msi"
msiexec /i "%MSI%" /qn /norestart
exit /b %ERRORLEVEL%
