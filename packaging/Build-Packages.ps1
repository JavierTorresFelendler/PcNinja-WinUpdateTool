param(
    [string]$Version,
    [string]$PublicLabel,
    [string]$ReleaseTag,
    [string]$Repository,
    [string]$CertificateThumbprint,
    [string]$PfxPath,
    [securestring]$PfxPassword,
    [string]$TimestampServer = 'http://timestamp.digicert.com'
)

$ErrorActionPreference = 'Stop'

$packagingDir = Split-Path -Parent $PSCommandPath
$packageRoot = Split-Path -Parent $packagingDir
$workspaceRoot = Split-Path -Parent (Split-Path -Parent $packageRoot)
$versionFile = Join-Path $packageRoot 'version.json'

if (Test-Path -LiteralPath $versionFile -PathType Leaf) {
    $versionInfo = Get-Content -LiteralPath $versionFile -Raw | ConvertFrom-Json
    if (-not $Version -and $versionInfo.version) {
        $Version = [string]$versionInfo.version
    }

    if (-not $PublicLabel -and $versionInfo.publicLabel) {
        $PublicLabel = [string]$versionInfo.publicLabel
    }

    if (-not $Repository -and $versionInfo.githubRepository) {
        $Repository = [string]$versionInfo.githubRepository
    }
}

if (-not $Version) {
    $Version = '2.0.5.0'
}

if (-not $PublicLabel) {
    $PublicLabel = 'V2.0.0-RC6'
}

if (-not $Repository) {
    $Repository = 'JavierTorresFelendler/PcNinja-WinUpdateTool'
}

if (-not $ReleaseTag) {
    $ReleaseTag = ('v' + ($PublicLabel -replace '^V', '')).ToLowerInvariant()
}

$distDir = Join-Path $packageRoot 'dist'
$payloadZip = Join-Path $distDir 'portable-payload.zip'
$msiPath = Join-Path $distDir ("PcNinja-WinUpdateTool-Setup-{0}-x64.msi" -f $Version)
$portableExePath = Join-Path $distDir ("PcNinja-WinUpdateTool-Portable-{0}.exe" -f $Version)
$publicReleaseDir = Join-Path $packageRoot 'public-release'
$publicMsiFileName = "PcNinja-WinUpdateTool-$PublicLabel-Setup-x64.msi"
$publicPortableFileName = "PcNinja-WinUpdateTool-$PublicLabel-Portable.exe"
$publicZipFileName = "PcNinja-WinUpdateTool-$PublicLabel-PublicRelease.zip"
$publicMsiPath = Join-Path $publicReleaseDir $publicMsiFileName
$publicPortablePath = Join-Path $publicReleaseDir $publicPortableFileName
$publicZipPath = Join-Path $packageRoot $publicZipFileName
$examplesDir = Join-Path $distDir 'deployment-examples'
$hostExePath = Join-Path $packageRoot 'PcNinja.WinUpdateTool.exe'
$cliExePath = Join-Path $packageRoot 'PcNinja.WinUpdateTool.Cli.exe'
$wxsPath = Join-Path $packagingDir 'PcNinja.WinUpdateTool.wxs'
$launcherSource = Join-Path $packagingDir 'PortableLauncher.cs'
$hostSource = Join-Path $packagingDir 'WinUpdateToolHost.cs'
$cliSource = Join-Path $packagingDir 'WinUpdateToolCli.cs'
$iconPath = Join-Path $packageRoot 'assets\PcNinja.ico'

if (-not (Test-Path -LiteralPath $distDir)) {
    New-Item -ItemType Directory -Path $distDir -Force | Out-Null
}
else {
    Get-ChildItem -LiteralPath $distDir -File |
        Where-Object { $_.Name -like 'PcNinja-WinUpdateTool-*.msi' -or $_.Name -like 'PcNinja-WinUpdateTool-*.exe' -or $_.Name -like 'PcNinja-WinUpdateTool-*.wixpdb' } |
        Remove-Item -Force
}

if (Test-Path -LiteralPath $examplesDir) {
    Remove-Item -LiteralPath $examplesDir -Recurse -Force
}

if (Test-Path -LiteralPath $publicReleaseDir) {
    Remove-Item -LiteralPath $publicReleaseDir -Recurse -Force
}

if (Test-Path -LiteralPath $publicZipPath) {
    Remove-Item -LiteralPath $publicZipPath -Force
}

if (Test-Path -LiteralPath ($publicZipPath + '.sha256.txt')) {
    Remove-Item -LiteralPath ($publicZipPath + '.sha256.txt') -Force
}

function Write-ExampleFile {
    param(
        [string]$Name,
        [string[]]$Lines
    )

    if (-not (Test-Path -LiteralPath $examplesDir)) {
        New-Item -ItemType Directory -Path $examplesDir -Force | Out-Null
    }

    Set-Content -LiteralPath (Join-Path $examplesDir $Name) -Value $Lines -Encoding ASCII
}

function Invoke-MsiSql {
    param(
        [object]$Database,
        [string]$Query
    )

    $view = $Database.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $Database, @($Query))
    try {
        $view.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $view, $null) | Out-Null
    }
    finally {
        $view.GetType().InvokeMember('Close', 'InvokeMethod', $null, $view, $null) | Out-Null
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($view)
    }
}

function Repair-MsiScheduleDialogFlow {
    param([string]$Path)

    $installer = New-Object -ComObject WindowsInstaller.Installer
    $database = $installer.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $installer, @($Path, 1))
    try {
        Invoke-MsiSql -Database $database -Query "DELETE FROM ``ControlEvent`` WHERE ``Dialog_``='InstallDirDlg' AND ``Control_``='Next' AND ``Event``='NewDialog' AND ``Argument``='VerifyReadyDlg'"
        Invoke-MsiSql -Database $database -Query "DELETE FROM ``ControlEvent`` WHERE ``Dialog_``='VerifyReadyDlg' AND ``Control_``='Back' AND ``Event``='NewDialog' AND ``Argument``='InstallDirDlg' AND ``Condition``='NOT Installed'"
        Invoke-MsiSql -Database $database -Query "UPDATE ``ControlEvent`` SET ``Condition``='1', ``Ordering``=10 WHERE ``Dialog_``='InstallDirDlg' AND ``Control_``='Next' AND ``Event``='NewDialog' AND ``Argument``='PcNinjaScheduleDlg'"
        Invoke-MsiSql -Database $database -Query "UPDATE ``ControlEvent`` SET ``Ordering``=1 WHERE ``Dialog_``='VerifyReadyDlg' AND ``Control_``='Back' AND ``Event``='NewDialog' AND ``Argument``='PcNinjaScheduleDlg'"
        $database.GetType().InvokeMember('Commit', 'InvokeMethod', $null, $database, $null) | Out-Null
    }
    finally {
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($database)
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($installer)
        $database = $null
        $installer = $null
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }
}

function Get-ReleaseSigningCertificate {
    param(
        [string]$Thumbprint,
        [string]$PfxFile,
        [securestring]$Password
    )

    if ($PfxFile) {
        if (-not (Test-Path -LiteralPath $PfxFile -PathType Leaf)) {
            throw "PFX file was not found: $PfxFile"
        }

        if (-not $Password) {
            $Password = Read-Host -Prompt 'PFX password' -AsSecureString
        }

        $imported = Import-PfxCertificate -FilePath $PfxFile -CertStoreLocation Cert:\CurrentUser\My -Password $Password -Exportable
        if (-not $imported) {
            throw 'PFX import did not return a certificate.'
        }

        return $imported | Select-Object -First 1
    }

    $certs = Get-ChildItem -Path Cert:\CurrentUser\My, Cert:\LocalMachine\My -CodeSigningCert -ErrorAction SilentlyContinue |
        Where-Object { $_.HasPrivateKey }

    if ($Thumbprint) {
        $cleanThumbprint = ($Thumbprint -replace '\s', '').ToUpperInvariant()
        $match = $certs | Where-Object { ($_.Thumbprint -replace '\s', '').ToUpperInvariant() -eq $cleanThumbprint } | Select-Object -First 1
        if (-not $match) {
            throw "Code-signing certificate was not found or has no private key: $Thumbprint"
        }

        return $match
    }

    $valid = @($certs | Where-Object { $_.NotAfter -gt (Get-Date) })
    if ($valid.Count -eq 1) {
        return $valid[0]
    }

    return $null
}

function Sign-ReleaseFile {
    param(
        [string]$Path,
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,
        [string]$Timestamp
    )

    if (-not $Certificate) {
        return
    }

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Cannot sign missing file: $Path"
    }

    $signature = Set-AuthenticodeSignature -LiteralPath $Path -Certificate $Certificate -HashAlgorithm SHA256 -TimestampServer $Timestamp
    if ($signature.Status -ne 'Valid') {
        throw "Signing failed for $Path. Status: $($signature.Status). Message: $($signature.StatusMessage)"
    }
}

function Sign-ReleaseFiles {
    param(
        [string[]]$Paths,
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,
        [string]$Timestamp
    )

    if (-not $Certificate) {
        return
    }

    foreach ($path in $Paths) {
        Sign-ReleaseFile -Path $path -Certificate $Certificate -Timestamp $Timestamp
    }
}

$signingCertificate = Get-ReleaseSigningCertificate -Thumbprint $CertificateThumbprint -PfxFile $PfxPath -Password $PfxPassword
if ($signingCertificate) {
    Write-Host "Signing enabled with certificate: $($signingCertificate.Subject)"
}
else {
    Write-Host 'Signing skipped: no code-signing certificate was provided or found.'
}
$wixCandidates = @(
    (Join-Path $workspaceRoot '.build-tools-wix6\wix.exe'),
    (Join-Path $workspaceRoot '.build-tools\wix.exe'),
    'wix.exe'
)

$wix = $wixCandidates | Where-Object {
    if ($_ -eq 'wix.exe') {
        return [bool](Get-Command $_ -ErrorAction SilentlyContinue)
    }

    return Test-Path -LiteralPath $_
} | Select-Object -First 1

if (-not $wix) {
    throw 'WiX was not found. Install it with: dotnet tool install wix --version 6.* --tool-path .build-tools-wix6'
}

Push-Location $packageRoot
try {
    $extensionList = & $wix extension list 2>$null
    if ($LASTEXITCODE -ne 0 -or (($extensionList -join "`n") -notmatch 'WixToolset\.UI\.wixext')) {
        & $wix extension add 'WixToolset.UI.wixext/6.0.2'
        if ($LASTEXITCODE -ne 0) {
            throw "WiX UI extension install failed with exit code $LASTEXITCODE."
        }
    }
}
finally {
    Pop-Location
}

$csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path -LiteralPath $csc)) {
    throw "The .NET Framework compiler was not found: $csc"
}

$powerShellAutomation = [psobject].Assembly.Location
if (-not (Test-Path -LiteralPath $powerShellAutomation)) {
    throw "System.Management.Automation.dll was not found: $powerShellAutomation"
}

& $csc `
    /nologo `
    /target:winexe `
    /optimize+ `
    /platform:x64 `
    /out:$hostExePath `
    /win32icon:$iconPath `
    /reference:$powerShellAutomation `
    /reference:System.Windows.Forms.dll `
    /reference:System.Drawing.dll `
    $hostSource

if ($LASTEXITCODE -ne 0) {
    throw "Branded host compile failed with exit code $LASTEXITCODE."
}

& $csc `
    /nologo `
    /target:exe `
    /optimize+ `
    /platform:x64 `
    /out:$cliExePath `
    /win32icon:$iconPath `
    $cliSource

if ($LASTEXITCODE -ne 0) {
    throw "CLI host compile failed with exit code $LASTEXITCODE."
}

Sign-ReleaseFiles -Certificate $signingCertificate -Timestamp $TimestampServer -Paths @(
    $hostExePath,
    $cliExePath,
    (Join-Path $packageRoot 'WinUpdateTool.ps1'),
    (Join-Path $packageRoot 'WinUpdateTool.V2Ui.ps1'),
    (Join-Path $packageRoot 'WinUpdateCore.psm1'),
    (Join-Path $packageRoot 'Install-WinUpdateTool.ps1'),
    (Join-Path $packageRoot 'Uninstall-WinUpdateTool.ps1'),
    (Join-Path $packageRoot 'MsiCleanup-WinUpdateTool.ps1'),
    (Join-Path $packageRoot 'MsiConfigure-WinUpdateTool.ps1')
)

Push-Location $packageRoot
try {
    & $wix build `
        -arch x64 `
        -ext WixToolset.UI.wixext `
        -d "SourceDir=$packageRoot" `
        -d "ProductVersion=$Version" `
        -o $msiPath `
        $wxsPath
}
finally {
    Pop-Location
}

if ($LASTEXITCODE -ne 0) {
    throw "WiX build failed with exit code $LASTEXITCODE."
}

Repair-MsiScheduleDialogFlow -Path $msiPath
Sign-ReleaseFile -Path $msiPath -Certificate $signingCertificate -Timestamp $TimestampServer

$stagingRoot = Join-Path ([IO.Path]::GetTempPath()) ('PcNinjaPortablePayload-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stagingRoot -Force | Out-Null

try {
    foreach ($file in @(
        'PcNinja.WinUpdateTool.exe',
        'PcNinja.WinUpdateTool.Cli.exe',
        'WinUpdateTool.ps1',
        'WinUpdateTool.V2Ui.ps1',
        'WinUpdateCore.psm1',
        'version.json',
        'Launch-WinUpdateTool.vbs',
        'Run-Portable.cmd',
        'README.md'
    )) {
        Copy-Item -LiteralPath (Join-Path $packageRoot $file) -Destination (Join-Path $stagingRoot $file) -Force
    }

    Copy-Item -LiteralPath (Join-Path $packageRoot 'assets') -Destination (Join-Path $stagingRoot 'assets') -Recurse -Force

    if (Test-Path -LiteralPath $payloadZip) {
        Remove-Item -LiteralPath $payloadZip -Force
    }

    Compress-Archive -Path (Join-Path $stagingRoot '*') -DestinationPath $payloadZip -Force
}
finally {
    if (Test-Path -LiteralPath $stagingRoot) {
        Remove-Item -LiteralPath $stagingRoot -Recurse -Force
    }
}

& $csc `
    /nologo `
    /target:exe `
    /optimize+ `
    /platform:x64 `
    /out:$portableExePath `
    /win32icon:$iconPath `
    "/resource:$payloadZip,PcNinjaPortablePayload" `
    /reference:System.IO.Compression.dll `
    /reference:System.IO.Compression.FileSystem.dll `
    /reference:System.Windows.Forms.dll `
    /reference:System.Drawing.dll `
    $launcherSource

if ($LASTEXITCODE -ne 0) {
    throw "Portable launcher compile failed with exit code $LASTEXITCODE."
}

Sign-ReleaseFile -Path $portableExePath -Certificate $signingCertificate -Timestamp $TimestampServer

Remove-Item -LiteralPath $payloadZip -Force

Write-ExampleFile -Name 'Install-MSI-Silent-Basic.cmd' -Lines @(
    '@echo off',
    'setlocal',
    ('set "MSI=%~dp0..\{0}"' -f $publicMsiFileName),
    'msiexec /i "%MSI%" /qn /norestart',
    'exit /b %ERRORLEVEL%'
)

Write-ExampleFile -Name 'Install-MSI-Silent-WithProperties.cmd' -Lines @(
    '@echo off',
    'setlocal',
    ('set "MSI=%~dp0..\{0}"' -f $publicMsiFileName),
    'msiexec /i "%MSI%" /qn /norestart ^',
    '  PCNINJA_ENABLE_SCHEDULE=1 ^',
    '  PCNINJA_FREQUENCY=Monthly ^',
    '  PCNINJA_MONTHLY_DAY=15 ^',
    '  PCNINJA_TIME=03:00 ^',
    '  PCNINJA_RUN_AT_STARTUP=1 ^',
    '  PCNINJA_STARTUP_DELAY=5 ^',
    '  PCNINJA_RUN_IF_MISSED=1 ^',
    '  PCNINJA_WAKE_TO_RUN=1 ^',
    '  PCNINJA_ALLOW_FIRMWARE=0 ^',
    '  PCNINJA_REBOOT_PROMPT=1 ^',
    '  PCNINJA_ENABLE_AUTORETRY=1 ^',
    '  PCNINJA_RETRY_INITIAL_DELAY=5 ^',
    '  PCNINJA_RETRY_MAX_ATTEMPTS=3 ^',
    '  PCNINJA_RETRY_BACKOFF=2 ^',
    '  PCNINJA_MINIMUM_COOLDOWN=5',
    'exit /b %ERRORLEVEL%'
)

Write-ExampleFile -Name 'BigFix-Action-Example.cmd' -Lines @(
    '@echo off',
    'rem BigFix usually works best with one command line.',
    ('msiexec /i "__Download\{0}" /qn /norestart PCNINJA_ENABLE_SCHEDULE=1 PCNINJA_FREQUENCY=Monthly PCNINJA_MONTHLY_DAY=15 PCNINJA_TIME=03:00 PCNINJA_RUN_AT_STARTUP=1 PCNINJA_STARTUP_DELAY=5 PCNINJA_RUN_IF_MISSED=1 PCNINJA_WAKE_TO_RUN=1 PCNINJA_ALLOW_FIRMWARE=0 PCNINJA_REBOOT_PROMPT=1 PCNINJA_ENABLE_AUTORETRY=1 PCNINJA_RETRY_INITIAL_DELAY=5 PCNINJA_RETRY_MAX_ATTEMPTS=3 PCNINJA_RETRY_BACKOFF=2 PCNINJA_MINIMUM_COOLDOWN=5' -f $publicMsiFileName)
)

Write-ExampleFile -Name 'Installed-CLI-Examples.cmd' -Lines @(
    '@echo off',
    'setlocal',
    'set "CLI=%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe"',
    '"%CLI%" /?',
    '"%CLI%" -Mode Status -Json',
    '"%CLI%" -Mode Configure -EnableSchedule -Frequency Monthly -MonthlyDay 15 -Time 03:00 -RunAtStartup -StartupDelayMinutes 5 -RunIfMissed -WakeToRun -RetryInitialDelayMinutes 5 -MinimumCooldownMinutes 5 -Json',
    '"%CLI%" -Mode RunUpdates -Silent -RunType Manual -Json',
    '"%CLI%" -Mode ResetWindowsUpdate -ConfirmReset -Json',
    '"%CLI%" -Mode AppUpdateCheck -Json',
    '"%CLI%" -Mode AppUpdateDownload -Json',
    'exit /b %ERRORLEVEL%'
)

Write-ExampleFile -Name 'Portable-CLI-Examples.cmd' -Lines @(
    '@echo off',
    'setlocal',
    ('set "PORTABLE=%~dp0..\{0}"' -f $publicPortableFileName),
    '"%PORTABLE%" /?',
    '"%PORTABLE%" -Mode Status -Json',
    '"%PORTABLE%" -Mode DriverAudit -Json',
    '"%PORTABLE%" -Mode Configure -EnableSchedule -Frequency Monthly -MonthlyDay 15 -Time 03:00 -RunAtStartup -StartupDelayMinutes 5 -RunIfMissed -WakeToRun -RetryInitialDelayMinutes 5 -MinimumCooldownMinutes 5 -Json',
    '"%PORTABLE%" -Mode ResetWindowsUpdate -ConfirmReset -Json',
    '"%PORTABLE%" -Mode AppUpdateCheck -Json',
    '"%PORTABLE%" -Mode AppUpdateDownload -Json',
    'exit /b %ERRORLEVEL%'
)

Write-ExampleFile -Name 'README-Deployment-Examples.txt' -Lines @(
    'PcNinja WinUpdate Tool deployment examples',
    '',
    'Files:',
    '  Install-MSI-Silent-Basic.cmd',
    '    Silent MSI install only.',
    '',
    '  Install-MSI-Silent-WithProperties.cmd',
    '    Silent MSI install plus post-install configuration using MSI properties.',
    '',
    '  BigFix-Action-Example.cmd',
    '    Single-line BigFix-style example. Adjust download paths for your action.',
    '',
    '  Installed-CLI-Examples.cmd',
    '    Examples for the installed CLI host.',
    '',
    '  Portable-CLI-Examples.cmd',
    '    Examples for the portable EXE CLI mode.',
    '',
    'App update modes:',
    '  AppUpdateCheck reads update-manifest.json and reports whether a newer release exists.',
    '  AppUpdateDownload downloads and verifies the selected release package.',
    '  AppUpdateInstall is user-initiated and is intended for installed MSI deployments.',
    '',
    'CMD line-continuation rule:',
    '  The ^ character is only for CMD/BAT line continuation.',
    '  It must be the final character on the line. Do not put spaces after it.',
    '  For BigFix deployment, a single msiexec command line is usually safer.',
    '',
    'JSON MSI deployment:',
    '  Not included in this release. Use MSI properties for silent configuration.',
    '',
    'MSI configuration properties:',
    '  PCNINJA_ENABLE_SCHEDULE',
    '  PCNINJA_FREQUENCY',
    '  PCNINJA_TIME',
    '  PCNINJA_DAY_OF_WEEK',
    '  PCNINJA_MONTHLY_DAY',
    '  PCNINJA_RUN_AT_STARTUP',
    '  PCNINJA_STARTUP_DELAY',
    '  PCNINJA_RUN_IF_MISSED',
    '  PCNINJA_WAKE_TO_RUN',
    '  PCNINJA_ALLOW_FIRMWARE',
    '  PCNINJA_REBOOT_PROMPT',
    '  PCNINJA_ENABLE_AUTORETRY',
    '  PCNINJA_RETRY_INITIAL_DELAY',
    '  PCNINJA_RETRY_MAX_ATTEMPTS',
    '  PCNINJA_RETRY_BACKOFF',
    '  PCNINJA_MINIMUM_COOLDOWN',
    '',
    'Boolean MSI values:',
    '  1/0, true/false, yes/no, and on/off are accepted.',
    '',
    'Important:',
    '  The MSI post-install configuration runs elevated as LocalSystem.',
    '  MSI post-install configuration log:',
    '  %ProgramData%\PcNinja\WinUpdateTool\Logs\MsiConfigure.log'
)

New-Item -ItemType Directory -Path $publicReleaseDir -Force | Out-Null
Copy-Item -LiteralPath $msiPath -Destination $publicMsiPath -Force
Copy-Item -LiteralPath $portableExePath -Destination $publicPortablePath -Force
Copy-Item -LiteralPath $examplesDir -Destination (Join-Path $publicReleaseDir 'deployment-examples') -Recurse -Force

$publicMsiHash = (Get-FileHash -LiteralPath $publicMsiPath -Algorithm SHA256).Hash
$publicPortableHash = (Get-FileHash -LiteralPath $publicPortablePath -Algorithm SHA256).Hash
$releaseBaseUrl = "https://github.com/$Repository/releases/download/$ReleaseTag"

$manifest = [ordered]@{
    channel = if ($versionInfo -and $versionInfo.releaseChannel) { [string]$versionInfo.releaseChannel } else { 'stable' }
    publicLabel = $PublicLabel
    version = $Version
    minimumSupportedVersion = $Version
    releaseNotesUrl = "https://github.com/$Repository/releases/tag/$ReleaseTag"
    msi = [ordered]@{
        fileName = $publicMsiFileName
        url = "$releaseBaseUrl/$publicMsiFileName"
        sha256 = $publicMsiHash
    }
    portable = [ordered]@{
        fileName = $publicPortableFileName
        url = "$releaseBaseUrl/$publicPortableFileName"
        sha256 = $publicPortableHash
    }
    signing = [ordered]@{
        required = [bool]($signingCertificate)
        expectedPublisher = 'PcNinja'
    }
}

$manifestPath = Join-Path $publicReleaseDir 'update-manifest.json'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 8), $utf8NoBom)

Set-Content -LiteralPath (Join-Path $publicReleaseDir "$PublicLabel-RELEASE-NOTES.txt") -Encoding UTF8 -Value @(
    "PcNinja WinUpdate Tool $PublicLabel Release Notes",
    '',
    'Release candidate for V2.0.0.',
    '',
    'Highlights:',
    '- Adds shared version manifest foundation.',
    '- Adds app update check/download/install CLI foundations.',
    '- Adds public update-manifest.json for GitHub Releases.',
    '- Fixes V2 UI manual run, Snooz run, reset, and schedule actions to launch WinUpdateTool.ps1.',
    '- Keeps Windows Update engine behavior based on V1.1.2.',
    '',
    'Notes:',
    '- This RC is unsigned unless signing was enabled during build.',
    '- Destructive Windows Update reset testing should be done in a VM.'
)

$signingStatus = if ($signingCertificate) { 'signed' } else { 'unsigned' }
Set-Content -LiteralPath (Join-Path $publicReleaseDir 'SIGNING-INSTRUCTIONS.txt') -Encoding UTF8 -Value @(
    "Signing status: $signingStatus",
    '',
    'If this release is unsigned, Windows SmartScreen or endpoint security tools may warn before execution.',
    '',
    'After signing, regenerate SHA256SUMS.txt and update-manifest.json.'
)

Set-Content -LiteralPath (Join-Path $publicReleaseDir 'PUBLIC-RELEASE-README.txt') -Encoding UTF8 -Value @(
    "PcNinja WinUpdate Tool $PublicLabel Public Release",
    '',
    'Files:',
    "- $publicMsiFileName",
    "- $publicPortableFileName",
    '- update-manifest.json',
    '- deployment-examples\',
    '- SHA256SUMS.txt',
    '',
    'Installed CLI examples:',
    '  "%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe" /?',
    '  "%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe" -Mode Status -Json',
    '  "%ProgramFiles%\PcNinja\WinUpdateTool\PcNinja.WinUpdateTool.Cli.exe" -Mode AppUpdateCheck -Json',
    '',
    'Portable examples:',
    "  $publicPortableFileName /?",
    "  $publicPortableFileName -Mode Status -Json",
    "  $publicPortableFileName -Mode AppUpdateCheck -Json",
    '',
    "Signing status: $signingStatus"
)

$shaLines = foreach ($file in (Get-ChildItem -LiteralPath $publicReleaseDir -File -Recurse | Sort-Object FullName)) {
    if ($file.Name -eq 'SHA256SUMS.txt') {
        continue
    }

    $relativePath = $file.FullName.Substring($publicReleaseDir.Length).TrimStart('\')
    '{0}  {1}' -f (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash, $relativePath
}

Set-Content -LiteralPath (Join-Path $publicReleaseDir 'SHA256SUMS.txt') -Value $shaLines -Encoding ASCII

Compress-Archive -Path (Join-Path $publicReleaseDir '*') -DestinationPath $publicZipPath -Force
$publicZipHash = (Get-FileHash -LiteralPath $publicZipPath -Algorithm SHA256).Hash
Set-Content -LiteralPath ($publicZipPath + '.sha256.txt') -Value ("{0}  {1}" -f $publicZipHash, $publicZipFileName) -Encoding ASCII

Get-FileHash -LiteralPath $msiPath, $portableExePath, $hostExePath, $cliExePath, $publicMsiPath, $publicPortablePath, $publicZipPath -Algorithm SHA256 |
    Select-Object Algorithm, Hash, Path
