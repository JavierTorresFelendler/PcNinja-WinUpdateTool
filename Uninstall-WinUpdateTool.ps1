param(
    [switch]$KeepData
)

$ErrorActionPreference = 'Stop'

function Test-UninstallerAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-UninstallerAdministrator)) {
    Write-Error 'Please run this uninstaller as Administrator.'
    exit 1
}

$installDir = Join-Path $env:ProgramFiles 'PcNinja\WinUpdateTool'
$installParentDir = Join-Path $env:ProgramFiles 'PcNinja'
$programDataDir = Join-Path $env:ProgramData 'PcNinja\WinUpdateTool'
$programDataParentDir = Join-Path $env:ProgramData 'PcNinja'
$startMenuDir = Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\PcNinja'
$startMenuShortcut = Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\PcNinja\WinUpdate Tool.lnk'
$desktopShortcut = Join-Path ([Environment]::GetFolderPath('CommonDesktopDirectory')) 'WinUpdate Tool.lnk'
$uninstallKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PcNinja WinUpdate Tool'

Set-Location -LiteralPath $env:TEMP

function Remove-EmptyDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ((Test-Path -LiteralPath $Path) -and -not (Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue)) {
        Remove-Item -LiteralPath $Path -Force
    }
}

$pcnWinUpdateTaskNames = @(
    'PcNinja WinUpdate Tool',
    'PcNinja WinUpdate Tool Retry',
    'PcNinja WinUpdate Tool Run Once'
)

try {
    $tasks = @(Get-ScheduledTask -TaskPath '\PcNinja\' -ErrorAction SilentlyContinue | Where-Object {
        $pcnWinUpdateTaskNames -contains $_.TaskName -or $_.TaskName -like 'PcNinja WinUpdate Tool*'
    })

    foreach ($task in $tasks) {
        Unregister-ScheduledTask -TaskName $task.TaskName -TaskPath '\PcNinja\' -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "Scheduled task removed: $($task.TaskName)"
    }

    foreach ($taskName in $pcnWinUpdateTaskNames) {
        if (-not ($tasks | Where-Object { $_.TaskName -eq $taskName })) {
            Unregister-ScheduledTask -TaskName $taskName -TaskPath '\PcNinja\' -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
}
catch {
    Write-Host "Scheduled task cleanup warning: $($_.Exception.Message)"
}

foreach ($path in @($startMenuShortcut, $desktopShortcut)) {
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Force
    }
}

if (Test-Path -LiteralPath $uninstallKey) {
    Remove-Item -LiteralPath $uninstallKey -Recurse -Force
}

if (Test-Path -LiteralPath $installDir) {
    Remove-Item -LiteralPath $installDir -Recurse -Force
}

if (-not $KeepData -and (Test-Path -LiteralPath $programDataDir)) {
    Remove-Item -LiteralPath $programDataDir -Recurse -Force
}

try {
    if ([System.Diagnostics.EventLog]::SourceExists('PcNinja WinUpdate Tool')) {
        [System.Diagnostics.EventLog]::DeleteEventSource('PcNinja WinUpdate Tool')
        Write-Host 'Event Log source removed.'
    }
}
catch {
    Write-Host "Event Log source was not removed: $($_.Exception.Message)"
}

Remove-EmptyDirectory -Path $startMenuDir
Remove-EmptyDirectory -Path $installParentDir
if (-not $KeepData) {
    Remove-EmptyDirectory -Path $programDataParentDir
}

Write-Host 'PcNinja WinUpdate Tool uninstalled.'
if ($KeepData) {
    Write-Host "Config and logs were kept here: $programDataDir"
}


