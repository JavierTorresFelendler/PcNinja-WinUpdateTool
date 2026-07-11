@echo off
setlocal
set "PORTABLE=%~dp0..\PcNinja-WinUpdateTool-V2.2.4-RC1-Portable.exe"
"%PORTABLE%" /?
"%PORTABLE%" -Mode Status -Json
"%PORTABLE%" -Mode DriverAudit -Json
"%PORTABLE%" -Mode Configure -EnableSchedule -Frequency Monthly -MonthlyDay 15 -Time 03:00 -RunAtStartup -StartupDelayMinutes 5 -RunIfMissed -WakeToRun -RetryInitialDelayMinutes 5 -MinimumCooldownMinutes 5 -Json
"%PORTABLE%" -Mode ResetWindowsUpdate -ConfirmReset -Json
"%PORTABLE%" -Mode AppUpdateCheck -Json
"%PORTABLE%" -Mode AppUpdateDownload -UpdatePackageType Portable -Json
exit /b %ERRORLEVEL%
