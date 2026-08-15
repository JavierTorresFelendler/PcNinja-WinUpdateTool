$ErrorActionPreference = 'SilentlyContinue'

$programDataDir = Join-Path $env:ProgramData 'PcNinja\WinUpdateTool'
$programDataParentDir = Join-Path $env:ProgramData 'PcNinja'

function Remove-EmptyDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ((Test-Path -LiteralPath $Path) -and -not (Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue)) {
        Remove-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    }
}

$pcnWinUpdateTaskNames = @(
    'PcNinja WinUpdate Tool',
    'PcNinja WinUpdate Tool Retry',
    'PcNinja WinUpdate Tool Run Once'
)

try {
    $tasks = @(Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
        $pcnWinUpdateTaskNames -contains $_.TaskName -or $_.TaskName -like 'PcNinja WinUpdate Tool*'
    })

    foreach ($task in $tasks) {
        $taskPath = if ([string]::IsNullOrWhiteSpace([string]$task.TaskPath)) { '\' } else { [string]$task.TaskPath }
        Unregister-ScheduledTask -TaskName $task.TaskName -TaskPath $taskPath -Confirm:$false -ErrorAction SilentlyContinue
    }

    foreach ($taskName in $pcnWinUpdateTaskNames) {
        Unregister-ScheduledTask -TaskName $taskName -TaskPath '\PcNinja\' -Confirm:$false -ErrorAction SilentlyContinue
    }
}
catch {
    $null = $_
}

if (Test-Path -LiteralPath $programDataDir) {
    Remove-Item -LiteralPath $programDataDir -Recurse -Force -ErrorAction SilentlyContinue
}

try {
    if ([System.Diagnostics.EventLog]::SourceExists('PcNinja WinUpdate Tool')) {
        [System.Diagnostics.EventLog]::DeleteEventSource('PcNinja WinUpdate Tool')
    }
}
catch {
    $null = $_
}

Remove-EmptyDirectory -Path $programDataParentDir


