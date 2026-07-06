function Show-PcnWinUpdateV2Ui {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    [System.Windows.Forms.Application]::EnableVisualStyles()

    $colors = [pscustomobject]@{
        AppBack = [System.Drawing.Color]::FromArgb(8, 13, 18)
        HeaderBack = [System.Drawing.Color]::FromArgb(7, 11, 16)
        SidebarBack = [System.Drawing.Color]::FromArgb(16, 22, 28)
        CardBack = [System.Drawing.Color]::FromArgb(18, 24, 30)
        CardAlt = [System.Drawing.Color]::FromArgb(14, 20, 26)
        Border = [System.Drawing.Color]::FromArgb(33, 43, 53)
        Text = [System.Drawing.Color]::FromArgb(238, 245, 252)
        Muted = [System.Drawing.Color]::FromArgb(157, 172, 186)
        Blue = [System.Drawing.Color]::FromArgb(25, 120, 215)
        Blue2 = [System.Drawing.Color]::FromArgb(72, 170, 255)
        Purple = [System.Drawing.Color]::FromArgb(122, 65, 210)
        Green = [System.Drawing.Color]::FromArgb(102, 198, 88)
        Orange = [System.Drawing.Color]::FromArgb(255, 166, 64)
        Red = [System.Drawing.Color]::FromArgb(214, 78, 78)
        Input = [System.Drawing.Color]::FromArgb(13, 18, 24)
    }

    $fontBase = New-Object System.Drawing.Font('Segoe UI', 10)
    $fontSmall = New-Object System.Drawing.Font('Segoe UI', 8.5)
    $fontTitle = New-Object System.Drawing.Font('Segoe UI Semibold', 12, [System.Drawing.FontStyle]::Bold)
    $fontHero = New-Object System.Drawing.Font('Segoe UI Semibold', 18, [System.Drawing.FontStyle]::Bold)
    $fontMono = New-Object System.Drawing.Font('Consolas', 9)

    function New-V2Point([int]$X, [int]$Y) {
        return New-Object System.Drawing.Point($X, $Y)
    }

    function New-V2Size([int]$Width, [int]$Height) {
        return New-Object System.Drawing.Size($Width, $Height)
    }

    function Add-V2BorderPaint {
        param(
            [Parameter(Mandatory = $true)]
            [System.Windows.Forms.Control]$Control,

            [System.Drawing.Color]$BorderColor = $colors.Border
        )

        $Control.Tag = [pscustomobject]@{
            PcnV2BorderColor = $BorderColor
        }

        $Control.Add_Paint({
            param($sender, $eventArgs)

            $pen = $null
            try {
                $color = [System.Drawing.Color]::FromArgb(47, 59, 69)
                if ($sender.Tag -and $sender.Tag.PSObject.Properties['PcnV2BorderColor']) {
                    $tagColor = $sender.Tag.PcnV2BorderColor
                    if ($tagColor -is [System.Drawing.Color] -and -not $tagColor.IsEmpty) {
                        $color = $tagColor
                    }
                }

                $pen = New-Object System.Drawing.Pen -ArgumentList @($color)
                $eventArgs.Graphics.DrawRectangle($pen, 0, 0, ($sender.ClientSize.Width - 1), ($sender.ClientSize.Height - 1))
            }
            catch {
                $null = $_
            }
            finally {
                if ($pen) {
                    $pen.Dispose()
                }
            }
        })
    }

    function New-V2Label {
        param(
            [string]$Text,
            [int]$X,
            [int]$Y,
            [int]$Width,
            [int]$Height = 24,
            [System.Drawing.Font]$Font = $fontBase,
            [System.Drawing.Color]$ForeColor = $colors.Text,
            [string]$Align = 'MiddleLeft'
        )

        $label = New-Object System.Windows.Forms.Label
        $label.Text = $Text
        $label.AutoSize = $false
        $label.Font = $Font
        $label.ForeColor = $ForeColor
        $label.BackColor = [System.Drawing.Color]::Transparent
        $label.Location = New-V2Point $X $Y
        $label.Size = New-V2Size $Width $Height
        $label.TextAlign = $Align
        return $label
    }

    function New-V2Card {
        param(
            [int]$X,
            [int]$Y,
            [int]$Width,
            [int]$Height,
            [string]$Title
        )

        $panel = New-Object System.Windows.Forms.Panel
        $panel.BackColor = $colors.CardBack
        $panel.Location = New-V2Point $X $Y
        $panel.Size = New-V2Size $Width $Height
        $panel.Margin = New-Object System.Windows.Forms.Padding(0)
        Add-V2BorderPaint -Control $panel

        if (-not [string]::IsNullOrWhiteSpace($Title)) {
            $panel.Controls.Add((New-V2Label -Text $Title -X 16 -Y 10 -Width ($Width - 32) -Height 26 -Font $fontTitle))
        }

        return $panel
    }

    function New-V2Button {
        param(
            [string]$Text,
            [int]$X,
            [int]$Y,
            [int]$Width,
            [int]$Height = 36,
            [System.Drawing.Color]$BackColor = $colors.CardAlt,
            [System.Drawing.Color]$BorderColor = $colors.Blue,
            [System.Drawing.Color]$ForeColor = $colors.Text
        )

        $button = New-Object System.Windows.Forms.Button
        $button.Text = $Text
        $button.Font = $fontBase
        $button.ForeColor = $ForeColor
        $button.BackColor = $BackColor
        $button.FlatStyle = 'Flat'
        $button.FlatAppearance.BorderColor = $BorderColor
        $button.FlatAppearance.BorderSize = 1
        $button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(28, 45, 62)
        $button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(24, 92, 160)
        $button.UseVisualStyleBackColor = $false
        $button.Location = New-V2Point $X $Y
        $button.Size = New-V2Size $Width $Height
        return $button
    }

    function New-V2LinkLabel {
        param(
            [string]$Text,
            [string]$Url,
            [int]$X,
            [int]$Y,
            [int]$Width = 240,
            [int]$Height = 24
        )

        $link = New-Object System.Windows.Forms.LinkLabel
        $link.Text = $Text
        $link.Tag = $Url
        $link.AutoSize = $false
        $link.Font = $fontBase
        $link.Location = New-V2Point $X $Y
        $link.Size = New-V2Size $Width $Height
        $link.BackColor = [System.Drawing.Color]::Transparent
        $link.ForeColor = $colors.Blue2
        $link.LinkColor = $colors.Blue2
        $link.ActiveLinkColor = $colors.Purple
        $link.VisitedLinkColor = $colors.Blue2
        $link.Add_LinkClicked({
            param($sender, $eventArgs)
            Start-Process -FilePath ([string]$sender.Tag) | Out-Null
        })
        return $link
    }

    function New-V2TextBox {
        param(
            [int]$X,
            [int]$Y,
            [int]$Width,
            [int]$Height = 28,
            [string]$Text = ''
        )

        $box = New-Object System.Windows.Forms.TextBox
        $box.Text = $Text
        $box.Font = $fontBase
        $box.ForeColor = $colors.Text
        $box.BackColor = $colors.Input
        $box.BorderStyle = 'FixedSingle'
        $box.Location = New-V2Point $X $Y
        $box.Size = New-V2Size $Width $Height
        return $box
    }

    function New-V2ComboBox {
        param(
            [int]$X,
            [int]$Y,
            [int]$Width,
            [string[]]$Items,
            [string]$Selected
        )

        $combo = New-Object System.Windows.Forms.ComboBox
        $combo.DropDownStyle = 'DropDownList'
        $combo.Font = $fontBase
        $combo.ForeColor = $colors.Text
        $combo.BackColor = $colors.Input
        $combo.FlatStyle = 'Flat'
        $combo.Location = New-V2Point $X $Y
        $combo.Size = New-V2Size $Width 30
        $combo.Items.AddRange($Items)
        if ($Selected) {
            $combo.SelectedItem = $Selected
        }
        elseif ($combo.Items.Count -gt 0) {
            $combo.SelectedIndex = 0
        }
        return $combo
    }

    function New-V2CheckBox {
        param(
            [string]$Text,
            [int]$X,
            [int]$Y,
            [bool]$Checked = $false
        )

        $check = New-Object System.Windows.Forms.CheckBox
        $check.Text = $Text
        $check.Font = $fontBase
        $check.ForeColor = $colors.Text
        $check.BackColor = [System.Drawing.Color]::Transparent
        $check.AutoSize = $true
        $check.Location = New-V2Point $X $Y
        $check.Checked = $Checked
        return $check
    }

    function Get-V2DownloadsFolder {
        $profile = [Environment]::GetFolderPath('UserProfile')
        if ([string]::IsNullOrWhiteSpace($profile)) {
            return (Get-PcnAppUpdateCacheRoot)
        }

        $downloads = Join-Path $profile 'Downloads'
        New-Item -ItemType Directory -Path $downloads -Force | Out-Null
        return $downloads
    }

    function Get-V2AppUpdatePackageType {
        if ([string]$env:PCNINJA_PORTABLE_MODE -eq '1' -or -not [string]::IsNullOrWhiteSpace([string]$env:PCNINJA_PORTABLE_SOURCE_EXE)) {
            return 'Portable'
        }

        return 'Msi'
    }

    function Get-V2PortableSourceFolder {
        $sourceExe = [string]$env:PCNINJA_PORTABLE_SOURCE_EXE
        if ([string]::IsNullOrWhiteSpace($sourceExe)) {
            return $null
        }

        try {
            $sourcePath = [System.IO.Path]::GetFullPath($sourceExe)
            $sourceFolder = [System.IO.Path]::GetDirectoryName($sourcePath)
            if (-not [string]::IsNullOrWhiteSpace($sourceFolder) -and (Test-Path -LiteralPath $sourceFolder -PathType Container)) {
                return $sourceFolder
            }
        }
        catch {
            return $null
        }

        return $null
    }

    function Get-V2AppUpdateDownloadFolder {
        param([ValidateSet('Msi', 'Portable')][string]$PackageType = 'Msi')

        if ($PackageType -eq 'Portable') {
            $portableFolder = Get-V2PortableSourceFolder
            if (-not [string]::IsNullOrWhiteSpace($portableFolder)) {
                return $portableFolder
            }
        }

        return (Get-V2DownloadsFolder)
    }

    function Format-V2Date {
        param([object]$Value)

        if (-not $Value) {
            return 'Not yet'
        }

        try {
            $date = [datetime]$Value
            if ($date.Year -lt 2000) {
                return 'Not yet'
            }

            return $date.ToString('dd-MMM HH:mm')
        }
        catch {
            return 'Not yet'
        }
    }

    function Get-V2OsSummary {
        try {
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
            return [pscustomobject]@{
                Caption = [string]$os.Caption
                Version = [string]$os.Version
                Build = [string]$os.BuildNumber
            }
        }
        catch {
            return [pscustomobject]@{
                Caption = 'Windows'
                Version = ''
                Build = ''
            }
        }
    }

    function Get-V2MainScriptPath {
        if ($script:PcnMainScriptPath -and (Test-Path -LiteralPath $script:PcnMainScriptPath -PathType Leaf)) {
            return $script:PcnMainScriptPath
        }

        $candidate = Join-Path $PSScriptRoot 'WinUpdateTool.ps1'
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return $candidate
        }

        return $PSCommandPath
    }

    function Start-V2ToolProcess {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Arguments,

            [string]$WorkingDirectory
        )

        $powershell = Get-PcnPowershellPath
        $startInfo = @{
            FilePath = $powershell
            ArgumentList = $Arguments
            WindowStyle = 'Hidden'
            PassThru = $true
        }

        if (-not [string]::IsNullOrWhiteSpace($WorkingDirectory)) {
            $startInfo.WorkingDirectory = $WorkingDirectory
        }

        $process = Start-Process @startInfo
        Write-PcnWinUpdateLog -Message "V2 background process started. PID: $($process.Id)." -EventID 1083
        return $process
    }

    function Show-V2ToolUpdateDialog {
        param(
            [System.Windows.Forms.Form]$Owner
        )

        $dialog = New-Object System.Windows.Forms.Form
        $dialog.Text = 'PcNinja Tool Update'
        $dialog.StartPosition = 'CenterParent'
        $dialog.FormBorderStyle = 'FixedDialog'
        $dialog.MinimizeBox = $false
        $dialog.MaximizeBox = $false
        $dialog.ShowInTaskbar = $false
        $dialog.ClientSize = New-V2Size 760 510
        $dialog.BackColor = $colors.CardBack
        $dialog.ForeColor = $colors.Text
        $dialog.Font = $fontBase
        if ($Owner.Icon) {
            $dialog.Icon = $Owner.Icon
        }

        $state = [pscustomobject]@{
            Check = $null
            Status = 'NotChecked'
            Message = 'Ready to check GitHub Releases.'
        }
        $packageType = Get-V2AppUpdatePackageType
        $packageLabel = if ($packageType -eq 'Portable') { 'portable EXE' } else { 'MSI' }

        $title = New-V2Label -Text 'PcNinja Tool Update' -X 24 -Y 18 -Width 420 -Height 30 -Font $fontHero
        $dialog.Controls.Add($title)

        $summary = New-V2Label -Text 'Checking update manifest...' -X 116 -Y 72 -Width 600 -Height 58 -Font $fontTitle
        $dialog.Controls.Add($summary)

        $cloudIcon = New-V2Label -Text ([string][char]0xE898) -X 30 -Y 76 -Width 70 -Height 62 -Font (New-Object System.Drawing.Font('Segoe MDL2 Assets', 40)) -ForeColor $colors.Purple -Align 'MiddleCenter'
        $dialog.Controls.Add($cloudIcon)

        $line = New-Object System.Windows.Forms.Panel
        $line.BackColor = $colors.Purple
        $line.Location = New-V2Point 24 148
        $line.Size = New-V2Size 712 1
        $dialog.Controls.Add($line)

        $left = New-V2Card -X 24 -Y 166 -Width 348 -Height 145 -Title ''
        $dialog.Controls.Add($left)
        $right = New-V2Card -X 388 -Y 166 -Width 348 -Height 145 -Title ''
        $dialog.Controls.Add($right)

        $currentValue = New-V2Label -Text $script:PcnToolPublicLabel -X 150 -Y 18 -Width 145 -Height 28 -Font $fontTitle -ForeColor $colors.Blue2
        $latestValue = New-V2Label -Text 'Unknown' -X 150 -Y 56 -Width 145 -Height 28 -Font $fontTitle -ForeColor $colors.Blue2
        $channelValue = New-V2Label -Text $script:PcnToolVersionInfo.ReleaseChannel -X 150 -Y 94 -Width 145 -Height 28 -Font $fontTitle -ForeColor $colors.Blue2
        $left.Controls.Add((New-V2Label -Text 'Current Version:' -X 18 -Y 20 -Width 130 -Height 24))
        $left.Controls.Add((New-V2Label -Text 'Latest Version:' -X 18 -Y 58 -Width 130 -Height 24))
        $left.Controls.Add((New-V2Label -Text 'Channel:' -X 18 -Y 96 -Width 130 -Height 24))
        $left.Controls.Add($currentValue)
        $left.Controls.Add($latestValue)
        $left.Controls.Add($channelValue)

        $manifestValue = New-V2Label -Text 'Pending' -X 150 -Y 18 -Width 145 -Height 28 -Font $fontTitle -ForeColor $colors.Orange
        $shaValue = New-V2Label -Text 'Pending' -X 150 -Y 56 -Width 145 -Height 28 -Font $fontTitle -ForeColor $colors.Orange
        $signValue = New-V2Label -Text 'Unsigned build' -X 150 -Y 94 -Width 145 -Height 28 -Font $fontTitle -ForeColor $colors.Orange
        $right.Controls.Add((New-V2Label -Text 'Manifest Status:' -X 18 -Y 20 -Width 130 -Height 24))
        $right.Controls.Add((New-V2Label -Text 'SHA256 Status:' -X 18 -Y 58 -Width 130 -Height 24))
        $right.Controls.Add((New-V2Label -Text 'Signing Status:' -X 18 -Y 96 -Width 130 -Height 24))
        $right.Controls.Add($manifestValue)
        $right.Controls.Add($shaValue)
        $right.Controls.Add($signValue)

        $info = New-V2Card -X 24 -Y 328 -Width 712 -Height 62 -Title ''
        $info.Controls.Add((New-V2Label -Text ([string][char]0xE946) -X 22 -Y 12 -Width 38 -Height 38 -Font (New-Object System.Drawing.Font('Segoe MDL2 Assets', 24)) -ForeColor $colors.Blue2 -Align 'MiddleCenter'))
        $infoText = New-V2Label -Text "V2 downloads the $packageLabel directly from GitHub Releases and verifies SHA256." -X 72 -Y 12 -Width 610 -Height 38
        $info.Controls.Add($infoText)
        $dialog.Controls.Add($info)

        $safety = New-V2Card -X 24 -Y 402 -Width 712 -Height 42 -Title ''
        $safety.Controls.Add((New-V2Label -Text 'No git pull is used on customer machines.' -X 72 -Y 8 -Width 610 -Height 24))
        $safety.Controls.Add((New-V2Label -Text ([string][char]0xE72E) -X 22 -Y 5 -Width 38 -Height 30 -Font (New-Object System.Drawing.Font('Segoe MDL2 Assets', 21)) -ForeColor $colors.Purple -Align 'MiddleCenter'))
        $dialog.Controls.Add($safety)

        $checkButton = New-V2Button -Text 'Check Again' -X 24 -Y 466 -Width 128 -Height 32
        $downloadButton = New-V2Button -Text $(if ($packageType -eq 'Portable') { 'Download EXE' } else { 'Download Verified' }) -X 164 -Y 466 -Width 164 -Height 32 -BackColor ([System.Drawing.Color]::FromArgb(13, 36, 58))
        $installButton = New-V2Button -Text 'Install MSI' -X 340 -Y 466 -Width 118 -Height 32 -BackColor ([System.Drawing.Color]::FromArgb(42, 24, 67)) -BorderColor $colors.Purple
        $installButton.Visible = ($packageType -eq 'Msi')
        $releaseButton = New-V2Button -Text 'Open Release Page' -X 470 -Y 466 -Width 154 -Height 32
        $closeDialogButton = New-V2Button -Text 'Close' -X 636 -Y 466 -Width 100 -Height 32 -BorderColor $colors.Border
        $dialog.Controls.AddRange([System.Windows.Forms.Control[]]@($checkButton, $downloadButton, $installButton, $releaseButton, $closeDialogButton))

        function Update-DialogFromCheck {
            param([object]$CheckResult)

            $state.Check = $CheckResult
            $latestText = if ($CheckResult.LatestPublicLabel) { [string]$CheckResult.LatestPublicLabel } else { [string]$CheckResult.LatestVersion }
            if ([string]::IsNullOrWhiteSpace($latestText)) {
                $latestText = 'Unknown'
            }

            $latestValue.Text = $latestText
            $channelValue.Text = if ($CheckResult.Channel) { [string]$CheckResult.Channel } else { [string]$script:PcnToolVersionInfo.ReleaseChannel }
            $manifestValue.Text = if ($CheckResult.Success) { 'Verified' } else { 'Problem' }
            $manifestValue.ForeColor = if ($CheckResult.Success) { $colors.Green } else { $colors.Red }
            $shaValue.Text = if ($CheckResult.IsNewer) { 'Pending download' } else { 'Not required' }
            $shaValue.ForeColor = if ($CheckResult.IsNewer) { $colors.Orange } else { $colors.Green }

            if ($CheckResult.Result -eq 'UpdateAvailable') {
                $summary.Text = "A new version is available.`r`nCurrent: $($CheckResult.CurrentPublicLabel)    Latest: $latestText"
                $cloudIcon.ForeColor = $colors.Purple
                $downloadButton.Enabled = $true
                $installButton.Enabled = $true
            }
            elseif ($CheckResult.Result -eq 'UpToDate') {
                $summary.Text = "PcNinja WinUpdate Tool is up to date.`r`nCurrent: $($CheckResult.CurrentPublicLabel)"
                $cloudIcon.ForeColor = $colors.Green
                $downloadButton.Enabled = $false
                $installButton.Enabled = $false
            }
            else {
                $summary.Text = "The update manifest was read, but it is not usable.`r`n$($CheckResult.Errors -join '; ')"
                $cloudIcon.ForeColor = $colors.Orange
                $downloadButton.Enabled = $false
                $installButton.Enabled = $false
            }
        }

        function Invoke-DialogCheck {
            try {
                $summary.Text = 'Checking GitHub Releases manifest...'
                $dialog.Refresh()
                $check = Invoke-PcnAppUpdateCheck -PackageType $packageType
                Update-DialogFromCheck -CheckResult $check
            }
            catch {
                $summary.Text = "Could not read the GitHub release manifest.`r`n$($_.Exception.Message)"
                $manifestValue.Text = 'Unavailable'
                $manifestValue.ForeColor = $colors.Red
                $shaValue.Text = 'Not checked'
                $shaValue.ForeColor = $colors.Orange
                $downloadButton.Enabled = $false
                $installButton.Enabled = $false
            }
        }

        $checkButton.Add_Click({
            Invoke-DialogCheck
        })

        $downloadButton.Add_Click({
            try {
                $target = Get-V2AppUpdateDownloadFolder -PackageType $packageType
                $summary.Text = "Downloading verified $packageLabel to:`r`n$target"
                $dialog.Refresh()
                $download = Invoke-PcnAppUpdateDownload -PackageType $packageType -CachePath $target
                if ($download.Success -and $download.FilePath) {
                    $shaValue.Text = 'Verified'
                    $shaValue.ForeColor = $colors.Green
                    [System.Windows.Forms.MessageBox]::Show("Downloaded and verified:`r`n$($download.FilePath)", 'PcNinja Tool Update', 'OK', 'Information') | Out-Null
                }
                elseif ($download.Result -eq 'NoNewerVersion') {
                    [System.Windows.Forms.MessageBox]::Show("No newer $packageLabel is available from the manifest.", 'PcNinja Tool Update', 'OK', 'Information') | Out-Null
                }
                else {
                    [System.Windows.Forms.MessageBox]::Show("Download did not complete: $($download.Result)", 'PcNinja Tool Update', 'OK', 'Warning') | Out-Null
                }
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Download Tool Update', 'OK', 'Warning') | Out-Null
            }
        })

        $installButton.Add_Click({
            $answer = [System.Windows.Forms.MessageBox]::Show(
                "This will download the verified MSI, start Windows Installer, and close PcNinja WinUpdate Tool so files can be replaced.`r`n`r`nContinue?",
                'Install Tool Update',
                'YesNo',
                'Question'
            )

            if ($answer -ne 'Yes') {
                return
            }

            try {
                $install = Invoke-PcnAppUpdateInstall -CachePath (Get-V2DownloadsFolder)
                if ($install.Success -and $install.Result -eq 'InstallerHandoffStarted') {
                    [System.Windows.Forms.MessageBox]::Show('Windows Installer was started. The app will close now.', 'Install Tool Update', 'OK', 'Information') | Out-Null
                    $dialog.Close()
                    $Owner.Close()
                }
                else {
                    [System.Windows.Forms.MessageBox]::Show("Installer handoff did not start: $($install.Result)", 'Install Tool Update', 'OK', 'Warning') | Out-Null
                }
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Install Tool Update', 'OK', 'Warning') | Out-Null
            }
        })

        $releaseButton.Add_Click({
            $url = Get-PcnDefaultAppUpdateReleaseUrl
            if ($state.Check -and $state.Check.ReleaseNotesUrl) {
                $url = [string]$state.Check.ReleaseNotesUrl
            }

            Start-Process -FilePath $url | Out-Null
        })

        $closeDialogButton.Add_Click({
            $dialog.Close()
        })

        $dialog.Add_Shown({
            Invoke-DialogCheck
        })

        $dialog.ShowDialog($Owner) | Out-Null
    }

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'PcNinja WinUpdate Tool V2.0'
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = $colors.AppBack
    $form.ForeColor = $colors.Text
    $form.Font = $fontBase
    $form.Size = New-V2Size 1180 735
    $form.MinimumSize = New-V2Size 1050 650

    $iconPath = Join-Path $PSScriptRoot 'assets\PcNinja.ico'
    if (Test-Path -LiteralPath $iconPath) {
        try {
            $form.Icon = New-Object System.Drawing.Icon($iconPath)
        }
        catch {
            $null = $_
        }
    }

    $header = New-Object System.Windows.Forms.Panel
    $header.BackColor = $colors.HeaderBack
    $header.Location = New-V2Point 0 0
    $header.Size = New-V2Size 1180 44
    $header.Anchor = 'Top,Left,Right'
    $form.Controls.Add($header)

    $logo = New-Object System.Windows.Forms.PictureBox
    $logo.Location = New-V2Point 14 8
    $logo.Size = New-V2Size 28 28
    $logo.SizeMode = 'Zoom'
    if (Test-Path -LiteralPath $iconPath) {
        try {
            $logo.Image = ([System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)).ToBitmap()
        }
        catch {
            $logo.BackColor = $colors.Blue
        }
    }
    $header.Controls.Add($logo)
    $header.Controls.Add((New-V2Label -Text 'PcNinja WinUpdate Tool V2.0' -X 52 -Y 8 -Width 360 -Height 28 -Font $fontTitle))

    $settingsButton = New-V2Button -Text 'Settings' -X 945 -Y 8 -Width 94 -Height 28 -BorderColor $colors.Border
    $settingsButton.Anchor = 'Top,Right'
    $helpButton = New-V2Button -Text 'Help' -X 1050 -Y 8 -Width 70 -Height 28 -BorderColor $colors.Border
    $helpButton.Anchor = 'Top,Right'
    $header.Controls.AddRange([System.Windows.Forms.Control[]]@($settingsButton, $helpButton))

    $sidebar = New-V2Card -X 10 -Y 54 -Width 260 -Height 620 -Title 'System Status'
    $sidebar.Anchor = 'Top,Bottom,Left'
    $form.Controls.Add($sidebar)

    $osInfo = Get-V2OsSummary
    $sidebar.Controls.Add((New-V2Label -Text ([string][char]0xE782) -X 16 -Y 46 -Width 24 -Height 24 -Font (New-Object System.Drawing.Font('Segoe MDL2 Assets', 14)) -ForeColor $colors.Blue2))
    $sidebar.Controls.Add((New-V2Label -Text 'Windows' -X 46 -Y 44 -Width 175 -Height 24 -Font $fontTitle))
    $windowsLabel = New-V2Label -Text ("{0}`r`n{1} ({2})" -f $osInfo.Caption, $osInfo.Version, $osInfo.Build) -X 46 -Y 70 -Width 190 -Height 46 -Font $fontSmall -ForeColor $colors.Muted
    $sidebar.Controls.Add($windowsLabel)

    $healthValue = New-V2Label -Text 'OK' -X 180 -Y 125 -Width 58 -Height 22 -ForeColor $colors.Green -Align 'MiddleRight'
    $lastScanValue = New-V2Label -Text 'Loading...' -X 130 -Y 154 -Width 108 -Height 22 -ForeColor $colors.Text -Align 'MiddleRight'
    $lastInstallValue = New-V2Label -Text 'Loading...' -X 130 -Y 183 -Width 108 -Height 22 -ForeColor $colors.Text -Align 'MiddleRight'
    $rebootValue = New-V2Label -Text 'Checking' -X 130 -Y 212 -Width 108 -Height 22 -ForeColor $colors.Green -Align 'MiddleRight'

    $sidebar.Controls.Add((New-V2Label -Text 'Health' -X 18 -Y 125 -Width 110 -Height 22 -ForeColor $colors.Text))
    $sidebar.Controls.Add((New-V2Label -Text 'Last Scan' -X 18 -Y 154 -Width 110 -Height 22 -ForeColor $colors.Text))
    $sidebar.Controls.Add((New-V2Label -Text 'Last Install' -X 18 -Y 183 -Width 110 -Height 22 -ForeColor $colors.Text))
    $sidebar.Controls.Add((New-V2Label -Text 'Reboot' -X 18 -Y 212 -Width 110 -Height 22 -ForeColor $colors.Text))
    $sidebar.Controls.AddRange([System.Windows.Forms.Control[]]@($healthValue, $lastScanValue, $lastInstallValue, $rebootValue))

    $divider1 = New-Object System.Windows.Forms.Panel
    $divider1.BackColor = $colors.Border
    $divider1.Location = New-V2Point 16 252
    $divider1.Size = New-V2Size 228 1
    $sidebar.Controls.Add($divider1)

    $sidebar.Controls.Add((New-V2Label -Text 'PcNinja Tool' -X 18 -Y 270 -Width 160 -Height 24 -Font $fontTitle))
    $installedValue = New-V2Label -Text $script:PcnToolPublicLabel -X 130 -Y 304 -Width 108 -Height 22 -Align 'MiddleRight'
    $latestValueSide = New-V2Label -Text 'Check needed' -X 130 -Y 333 -Width 108 -Height 22 -Align 'MiddleRight'
    $toolStatusValue = New-V2Label -Text 'Unknown' -X 130 -Y 362 -Width 108 -Height 22 -ForeColor $colors.Orange -Align 'MiddleRight'
    $sidebar.Controls.Add((New-V2Label -Text 'Installed' -X 18 -Y 304 -Width 90 -Height 22))
    $sidebar.Controls.Add((New-V2Label -Text 'Latest' -X 18 -Y 333 -Width 90 -Height 22))
    $sidebar.Controls.Add((New-V2Label -Text 'Status' -X 18 -Y 362 -Width 90 -Height 22))
    $sidebar.Controls.AddRange([System.Windows.Forms.Control[]]@($installedValue, $latestValueSide, $toolStatusValue))

    $sidebarUpdateButton = New-V2Button -Text 'Check Tool Update' -X 16 -Y 402 -Width 228 -Height 34 -BackColor ([System.Drawing.Color]::FromArgb(32, 23, 45)) -BorderColor $colors.Purple
    $sidebar.Controls.Add($sidebarUpdateButton)

    $tabHost = New-Object System.Windows.Forms.Panel
    $tabHost.BackColor = $colors.HeaderBack
    $tabHost.Location = New-V2Point 280 54
    $tabHost.Size = New-V2Size 880 42
    $tabHost.Anchor = 'Top,Left,Right'
    $form.Controls.Add($tabHost)

    $content = New-Object System.Windows.Forms.Panel
    $content.BackColor = $colors.AppBack
    $content.Location = New-V2Point 280 104
    $content.Size = New-V2Size 880 570
    $content.Anchor = 'Top,Bottom,Left,Right'
    $form.Controls.Add($content)

    $pages = @{}
    foreach ($name in @('Dashboard', 'Updates', 'Schedule', 'Drivers', 'Logs')) {
        $page = New-Object System.Windows.Forms.Panel
        $page.BackColor = $colors.AppBack
        $page.Dock = 'Fill'
        $page.Visible = $false
        $content.Controls.Add($page)
        $pages[$name] = $page
    }

    $tabButtons = @{}
    function Show-V2Page {
        param([Parameter(Mandatory = $true)][string]$Name)

        foreach ($entry in $pages.GetEnumerator()) {
            $entry.Value.Visible = ($entry.Key -eq $Name)
        }

        foreach ($tabEntry in $tabButtons.GetEnumerator()) {
            $tabEntry.Value.BackColor = $colors.HeaderBack
            $tabEntry.Value.FlatAppearance.BorderColor = $colors.Border
        }

        if ($tabButtons.ContainsKey($Name)) {
            $tabButtons[$Name].BackColor = $colors.Blue
            $tabButtons[$Name].FlatAppearance.BorderColor = $colors.Blue2
        }

        if ($Name -eq 'Schedule') {
            $settingsButton.BackColor = $colors.Blue
            $settingsButton.FlatAppearance.BorderColor = $colors.Blue2
        }
        else {
            $settingsButton.BackColor = $colors.HeaderBack
            $settingsButton.FlatAppearance.BorderColor = $colors.Border
        }

        if ($Name -eq 'Logs') {
            Refresh-V2Logs -ScrollToEnd
            $logFollowTimer.Start()
        }
    }

    $tabX = 0
    foreach ($name in @('Dashboard', 'Updates', 'Drivers', 'Logs')) {
        $button = New-V2Button -Text $name -X $tabX -Y 0 -Width 172 -Height 42 -BorderColor $colors.Border
        $button.Tag = $name
        $button.Add_Click({
            param($sender, $eventArgs)
            Show-V2Page -Name ([string]$sender.Tag)
        })
        $tabHost.Controls.Add($button)
        $tabButtons[$name] = $button
        $tabX += 172
    }

    $footer = New-Object System.Windows.Forms.StatusStrip
    $footer.BackColor = $colors.HeaderBack
    $footer.ForeColor = $colors.Muted
    $footer.SizingGrip = $false
    $footerLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
    $footerLabel.Text = 'Ready'
    $footerLabel.Spring = $true
    $footerLabel.TextAlign = 'MiddleLeft'
    $systemLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
    $systemLabel.Text = 'All systems operational'
    $systemLabel.ForeColor = $colors.Green
    [void]$footer.Items.Add($footerLabel)
    [void]$footer.Items.Add($systemLabel)
    $form.Controls.Add($footer)

    $uiState = [pscustomobject]@{
        LogFollow = $true
        ScanProcess = $null
        ScanOutPath = $null
        ScanErrPath = $null
        LastPreviewItems = @()
        PendingReboot = $null
        LastLogText = $null
        LastLogFilter = $null
        LogFilterPlaceholderActive = $false
        LogFilePath = $null
        LogFileOffset = 0L
        LogLoadedLineCount = 0
    }

    $smokeTimer = New-Object System.Windows.Forms.Timer
    $smokeTimer.Interval = 1500
    $smokeTimer.Add_Tick({
        $smokeTimer.Stop()
        $form.Close()
    })

    $logFollowTimer = New-Object System.Windows.Forms.Timer
    $logFollowTimer.Interval = 1000
    $logFollowTimer.Add_Tick({
        if ($pages.ContainsKey('Logs') -and $pages['Logs'].Visible -and [bool]$uiState.LogFollow) {
            Update-V2LogFollow
        }
    })

    $scanTimer = New-Object System.Windows.Forms.Timer
    $scanTimer.Interval = 750
    $scanTimer.Add_Tick({
        Complete-V2UpdatePreviewIfReady
    })

    $dashboard = $pages['Dashboard']
    $dashboard.Controls.Add((New-V2Label -Text 'Dashboard' -X 0 -Y 0 -Width 240 -Height 32 -Font $fontHero))
    $overviewCard = New-V2Card -X 0 -Y 44 -Width 870 -Height 150 -Title 'System Update Overview'
    $overviewIcon = New-V2Label -Text ([string][char]0xE73E) -X 22 -Y 48 -Width 70 -Height 58 -Font (New-Object System.Drawing.Font('Segoe MDL2 Assets', 38)) -ForeColor $colors.Green -Align 'MiddleCenter'
    $overviewStatus = New-V2Label -Text 'Your system is ready.' -X 108 -Y 54 -Width 700 -Height 30 -Font $fontTitle
    $overviewSub = New-V2Label -Text 'Use Updates for Windows Update runs, Settings for scheduling, and Logs for live progress.' -X 108 -Y 88 -Width 700 -Height 26 -ForeColor $colors.Muted
    $overviewCard.Controls.AddRange([System.Windows.Forms.Control[]]@($overviewIcon, $overviewStatus, $overviewSub))
    $dashboard.Controls.Add($overviewCard)

    $scheduleSummaryCard = New-V2Card -X 0 -Y 210 -Width 430 -Height 150 -Title 'Schedule Summary'
    $scheduleSummaryText = New-V2Label -Text 'Loading schedule...' -X 20 -Y 48 -Width 380 -Height 72 -Font $fontTitle -ForeColor $colors.Blue2
    $scheduleSummaryCard.Controls.Add($scheduleSummaryText)
    $dashboard.Controls.Add($scheduleSummaryCard)

    $healthCard = New-V2Card -X 445 -Y 210 -Width 425 -Height 150 -Title 'Health Check Summary'
    $healthCard.Controls.Add((New-V2Label -Text ([string][char]0xE73E) -X 22 -Y 54 -Width 34 -Height 34 -Font (New-Object System.Drawing.Font('Segoe MDL2 Assets', 22)) -ForeColor $colors.Green -Align 'MiddleCenter'))
    $healthText = New-V2Label -Text 'Healthy' -X 70 -Y 56 -Width 300 -Height 32 -Font $fontHero -ForeColor $colors.Green
    $healthSub = New-V2Label -Text 'No blocking condition detected by the local status check.' -X 70 -Y 94 -Width 330 -Height 24 -ForeColor $colors.Muted
    $healthCard.Controls.AddRange([System.Windows.Forms.Control[]]@($healthText, $healthSub))
    $dashboard.Controls.Add($healthCard)

    $repairCard = New-V2Card -X 0 -Y 376 -Width 870 -Height 112 -Title 'Repair Windows Update'
    $repairCard.Controls.Add((New-V2Label -Text 'Use this only when Windows Update appears stuck scanning, downloading, or installing.' -X 20 -Y 44 -Width 560 -Height 24 -ForeColor $colors.Muted))
    $dashboardResetButton = New-V2Button -Text 'Reset Windows Update' -X 640 -Y 42 -Width 190 -Height 36 -BackColor ([System.Drawing.Color]::FromArgb(48, 18, 24)) -BorderColor $colors.Red -ForeColor $colors.Red
    $repairCard.Controls.Add($dashboardResetButton)
    $dashboard.Controls.Add($repairCard)

    $updates = $pages['Updates']
    $manualCard = New-V2Card -X 0 -Y 0 -Width 870 -Height 190 -Title 'Windows Update Run'
    $manualCard.Controls.Add((New-V2Label -Text 'Choose what PcNinja should check and install from Windows Update.' -X 20 -Y 40 -Width 610 -Height 24 -ForeColor $colors.Muted))
    $windowsUpdatesCheck = New-V2CheckBox -Text 'Windows updates' -X 24 -Y 72 -Checked $true
    $optionalUpdatesCheck = New-V2CheckBox -Text 'Optional updates' -X 270 -Y 72 -Checked $true
    $driverUpdatesCheck = New-V2CheckBox -Text 'Driver updates' -X 516 -Y 72 -Checked $true
    $firmwareUpdatesCheck = New-V2CheckBox -Text 'Firmware / BIOS updates' -X 24 -Y 112 -Checked $false
    $manualCard.Controls.AddRange([System.Windows.Forms.Control[]]@($windowsUpdatesCheck, $optionalUpdatesCheck, $driverUpdatesCheck, $firmwareUpdatesCheck))
    $manualCard.Controls.Add((New-V2Label -Text 'Security, cumulative, .NET, servicing' -X 48 -Y 96 -Width 210 -Height 18 -Font $fontSmall -ForeColor $colors.Muted))
    $manualCard.Controls.Add((New-V2Label -Text 'Browse-only optional packages' -X 294 -Y 96 -Width 190 -Height 18 -Font $fontSmall -ForeColor $colors.Muted))
    $manualCard.Controls.Add((New-V2Label -Text 'Windows Update driver catalog' -X 540 -Y 96 -Width 210 -Height 18 -Font $fontSmall -ForeColor $colors.Muted))
    $manualCard.Controls.Add((New-V2Label -Text 'Explicit opt-in only' -X 48 -Y 136 -Width 180 -Height 18 -Font $fontSmall -ForeColor $colors.Muted))
    $checkAvailableButton = New-V2Button -Text 'Check Available Updates' -X 394 -Y 136 -Width 210 -Height 38 -BackColor ([System.Drawing.Color]::FromArgb(12, 74, 142))
    $installSelectedButton = New-V2Button -Text 'Install Selected Updates' -X 620 -Y 136 -Width 220 -Height 38 -BackColor $colors.Blue
    $manualCard.Controls.AddRange([System.Windows.Forms.Control[]]@($checkAvailableButton, $installSelectedButton))
    $updates.Controls.Add($manualCard)

    $availableCard = New-V2Card -X 0 -Y 206 -Width 870 -Height 120 -Title 'Available Updates'
    $availableSummary = New-V2Label -Text 'No check has run yet.' -X 20 -Y 48 -Width 360 -Height 44 -ForeColor $colors.Muted
    $viewUpdateListButton = New-V2Button -Text 'View List' -X 20 -Y 82 -Width 120 -Height 28 -BorderColor $colors.Border
    $importantCount = New-V2Label -Text '-' -X 455 -Y 42 -Width 60 -Height 34 -Font $fontHero -ForeColor $colors.Orange -Align 'MiddleCenter'
    $optionalCount = New-V2Label -Text '-' -X 560 -Y 42 -Width 60 -Height 34 -Font $fontHero -ForeColor $colors.Blue2 -Align 'MiddleCenter'
    $driversCount = New-V2Label -Text '-' -X 665 -Y 42 -Width 60 -Height 34 -Font $fontHero -ForeColor $colors.Green -Align 'MiddleCenter'
    $firmwareSkippedCount = New-V2Label -Text '-' -X 770 -Y 42 -Width 60 -Height 34 -Font $fontHero -ForeColor $colors.Purple -Align 'MiddleCenter'
    $availableCard.Controls.AddRange([System.Windows.Forms.Control[]]@($availableSummary, $viewUpdateListButton, $importantCount, $optionalCount, $driversCount, $firmwareSkippedCount))
    $availableCard.Controls.Add((New-V2Label -Text 'Important' -X 442 -Y 78 -Width 86 -Height 20 -Font $fontSmall -ForeColor $colors.Muted -Align 'MiddleCenter'))
    $availableCard.Controls.Add((New-V2Label -Text 'Optional' -X 548 -Y 78 -Width 86 -Height 20 -Font $fontSmall -ForeColor $colors.Muted -Align 'MiddleCenter'))
    $availableCard.Controls.Add((New-V2Label -Text 'Drivers' -X 653 -Y 78 -Width 86 -Height 20 -Font $fontSmall -ForeColor $colors.Muted -Align 'MiddleCenter'))
    $availableCard.Controls.Add((New-V2Label -Text 'Firmware skipped' -X 744 -Y 78 -Width 120 -Height 20 -Font $fontSmall -ForeColor $colors.Muted -Align 'MiddleCenter'))
    $updates.Controls.Add($availableCard)

    $restartCard = New-V2Card -X 0 -Y 342 -Width 870 -Height 90 -Title 'Restart State'
    $restartLabel = New-V2Label -Text 'Checking restart state...' -X 20 -Y 48 -Width 570 -Height 24 -ForeColor $colors.Muted
    $restartNowButton = New-V2Button -Text 'Restart Now' -X 610 -Y 42 -Width 112 -Height 32 -BackColor ([System.Drawing.Color]::FromArgb(42, 24, 18)) -BorderColor $colors.Orange -ForeColor $colors.Orange
    $restartDetailsButton = New-V2Button -Text 'Details' -X 735 -Y 42 -Width 100 -Height 32 -BorderColor $colors.Border
    $restartCard.Controls.AddRange([System.Windows.Forms.Control[]]@($restartLabel, $restartNowButton, $restartDetailsButton))
    $updates.Controls.Add($restartCard)

    $linksCard = New-V2Card -X 0 -Y 448 -Width 870 -Height 95 -Title 'Helpful Links'
    $linksCard.Controls.Add((New-V2LinkLabel -Text 'PcNinja Windows Image' -Url 'https://win11.pcninja.pro/' -X 20 -Y 54 -Width 260))
    $linksCard.Controls.Add((New-V2LinkLabel -Text 'PcNinja Classes' -Url 'https://class.pcninja.pro' -X 430 -Y 54 -Width 220))
    $updates.Controls.Add($linksCard)

    $schedule = $pages['Schedule']
    $scheduleCard = New-V2Card -X 0 -Y 0 -Width 560 -Height 220 -Title 'Schedule'
    $scheduleCard.Controls.Add((New-V2Label -Text 'Choose when the tool should run Windows Update.' -X 20 -Y 40 -Width 360 -Height 24 -ForeColor $colors.Muted))
    $dailyRadio = New-Object System.Windows.Forms.RadioButton
    $weeklyRadio = New-Object System.Windows.Forms.RadioButton
    $monthlyRadio = New-Object System.Windows.Forms.RadioButton
    $radioRows = @(
        @($dailyRadio, 'Daily', 62),
        @($weeklyRadio, 'Weekly', 94),
        @($monthlyRadio, 'Monthly', 126)
    )
    foreach ($row in $radioRows) {
        $row[0].Text = [string]$row[1]
        $row[0].ForeColor = $colors.Text
        $row[0].BackColor = [System.Drawing.Color]::Transparent
        $row[0].Font = $fontBase
        $row[0].Location = New-V2Point 20 ([int]$row[2])
        $row[0].AutoSize = $true
        $scheduleCard.Controls.Add($row[0])
    }
    $scheduleTimeCombo = New-V2ComboBox -X 230 -Y 60 -Width 145 -Items @('02:00', '03:00', '04:00', '09:00', '18:00') -Selected '03:00'
    $scheduleDayCombo = New-V2ComboBox -X 230 -Y 92 -Width 145 -Items @('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday') -Selected 'Sunday'
    $scheduleMonthDayCombo = New-V2ComboBox -X 230 -Y 124 -Width 145 -Items @('1', '5', '10', '15', '20', '25', '28') -Selected '15'
    $scheduleCard.Controls.AddRange([System.Windows.Forms.Control[]]@($scheduleTimeCombo, $scheduleDayCombo, $scheduleMonthDayCombo))
    $schedule.Controls.Add($scheduleCard)

    $nextCard = New-V2Card -X 580 -Y 0 -Width 290 -Height 220 -Title 'Next Run Summary'
    $nextCard.Anchor = 'Top,Right'
    $nextRunValue = New-V2Label -Text 'Not scheduled' -X 20 -Y 54 -Width 245 -Height 34 -Font $fontTitle -ForeColor $colors.Blue2
    $nextModeValue = New-V2Label -Text 'Schedule disabled' -X 20 -Y 96 -Width 245 -Height 60 -ForeColor $colors.Muted
    $nextCard.Controls.AddRange([System.Windows.Forms.Control[]]@($nextRunValue, $nextModeValue))
    $schedule.Controls.Add($nextCard)

    $wakeCard = New-V2Card -X 0 -Y 238 -Width 870 -Height 118 -Title 'Wake Options'
    $wakeCard.Anchor = 'Top,Left,Right'
    $startupCheck = New-V2CheckBox -Text 'Also run after startup' -X 20 -Y 42 -Checked $false
    $startupDelayLabel = New-V2Label -Text 'Startup delay' -X 310 -Y 40 -Width 98 -Height 24 -ForeColor $colors.Muted
    $startupDelayCombo = New-V2ComboBox -X 414 -Y 36 -Width 72 -Items @('0', '5', '15', '30', '60') -Selected '5'
    $wakeCheck = New-V2CheckBox -Text 'Wake the computer to run this task' -X 20 -Y 78 -Checked $false
    $missedCheck = New-V2CheckBox -Text 'Run if the task is missed' -X 414 -Y 78 -Checked $true
    $wakeCard.Controls.AddRange([System.Windows.Forms.Control[]]@($startupCheck, $startupDelayLabel, $startupDelayCombo, $wakeCheck, $missedCheck))
    $schedule.Controls.Add($wakeCard)

    $retryCard = New-V2Card -X 0 -Y 374 -Width 870 -Height 110 -Title 'Retry Policy'
    $retryCard.Anchor = 'Top,Left,Right'
    $retryCard.Controls.Add((New-V2Label -Text 'Configure how to handle failures and retries.' -X 20 -Y 40 -Width 360 -Height 24 -ForeColor $colors.Muted))
    $retryCard.Controls.Add((New-V2Label -Text 'Retry failed updates' -X 20 -Y 74 -Width 145 -Height 24))
    $retryAttemptsCombo = New-V2ComboBox -X 168 -Y 70 -Width 145 -Items @('0 times', '1 time', '3 times', '5 times') -Selected '3 times'
    $retryCard.Controls.Add((New-V2Label -Text 'Retry interval' -X 340 -Y 74 -Width 105 -Height 24))
    $retryIntervalCombo = New-V2ComboBox -X 448 -Y 70 -Width 145 -Items @('5 minutes', '15 minutes', '60 minutes') -Selected '5 minutes'
    $retryCard.Controls.Add((New-V2Label -Text 'On repeated failure' -X 565 -Y 74 -Width 135 -Height 24))
    $retryFailureCombo = New-V2ComboBox -X 704 -Y 70 -Width 144 -Items @('Snooz and retry later', 'Stop after retries') -Selected 'Snooz and retry later'
    $retryFailureCombo.Anchor = 'Top,Right'
    $retryCard.Controls.AddRange([System.Windows.Forms.Control[]]@($retryAttemptsCombo, $retryIntervalCombo, $retryFailureCombo))
    $schedule.Controls.Add($retryCard)

    $clearScheduleButton = New-V2Button -Text 'Clear Schedule' -X 390 -Y 506 -Width 220 -Height 40 -BackColor ([System.Drawing.Color]::FromArgb(48, 18, 24)) -BorderColor $colors.Red -ForeColor $colors.Red
    $clearScheduleButton.Anchor = 'Bottom,Right'
    $saveScheduleButton = New-V2Button -Text 'Save Schedule' -X 625 -Y 506 -Width 220 -Height 40 -BackColor ([System.Drawing.Color]::FromArgb(52, 28, 88)) -BorderColor $colors.Purple
    $saveScheduleButton.Anchor = 'Bottom,Right'
    $schedule.Controls.AddRange([System.Windows.Forms.Control[]]@($clearScheduleButton, $saveScheduleButton))

    $drivers = $pages['Drivers']
    $auditCard = New-V2Card -X 0 -Y 0 -Width 870 -Height 168 -Title ''
    $auditCard.Controls.Add((New-V2Label -Text 'Driver Audit' -X 20 -Y 12 -Width 260 -Height 26 -Font $fontTitle))
    $auditCard.Controls.Add((New-V2Label -Text 'Scan your system and create a driver inventory report.' -X 20 -Y 46 -Width 420 -Height 24 -ForeColor $colors.Muted))
    $driverAuditButton = New-V2Button -Text 'Create Audit' -X 20 -Y 94 -Width 150 -Height 36
    $openDriverReportButton = New-V2Button -Text 'Open Report' -X 188 -Y 94 -Width 150 -Height 36 -BackColor ([System.Drawing.Color]::FromArgb(52, 28, 88)) -BorderColor $colors.Purple
    $auditStatus = New-V2Label -Text 'Last audit: Not yet' -X 20 -Y 134 -Width 420 -Height 24 -ForeColor $colors.Muted
    $auditDivider = New-Object System.Windows.Forms.Panel
    $auditDivider.BackColor = $colors.Border
    $auditDivider.Location = New-V2Point 488 22
    $auditDivider.Size = New-V2Size 1 122
    $auditCard.Controls.Add($auditDivider)
    $auditCard.Controls.Add((New-V2Label -Text 'Latest Report' -X 520 -Y 12 -Width 300 -Height 26 -Font $fontTitle))
    $reportSummary = New-V2Label -Text "Devices scanned: -`r`nDrivers found: -`r`nOutdated drivers: -`r`nUnknown devices: -" -X 520 -Y 50 -Width 175 -Height 92 -ForeColor $colors.Text
    $viewFullReportButton = New-V2Button -Text 'View Full Report' -X 710 -Y 96 -Width 140 -Height 32
    $auditCard.Controls.AddRange([System.Windows.Forms.Control[]]@($driverAuditButton, $openDriverReportButton, $auditStatus, $reportSummary, $viewFullReportButton))
    $drivers.Controls.Add($auditCard)

    $toolsCard = New-V2Card -X 0 -Y 184 -Width 870 -Height 148 -Title 'PcNinja Tools'
    $toolsCard.Controls.Add((New-V2Label -Text 'PcNinja download links and shared file password.' -X 20 -Y 42 -Width 440 -Height 24 -ForeColor $colors.Muted))
    $pcnDriverLink = New-V2LinkLabel -Text 'PcNinja Driver Updater' -Url 'https://driver.pcninja.pro' -X 20 -Y 78 -Width 225
    $pcnOfficeLink = New-V2LinkLabel -Text 'PcNinja Office Installer' -Url 'https://office.pcninja.pro' -X 20 -Y 110 -Width 225
    $pcnActivationLink = New-V2LinkLabel -Text 'PcNinja Activation' -Url 'https://active.pcninja.pro' -X 290 -Y 78 -Width 205
    $pcnWindowsLink = New-V2LinkLabel -Text 'PcNinja Windows Image' -Url 'https://win11.pcninja.pro/' -X 290 -Y 110 -Width 205
    foreach ($pcnLink in @($pcnDriverLink, $pcnOfficeLink, $pcnActivationLink, $pcnWindowsLink)) {
        $pcnLink.Font = $fontTitle
    }

    $toolsCard.Controls.Add((New-V2Label -Text 'File password' -X 620 -Y 58 -Width 190 -Height 24 -ForeColor $colors.Muted))
    $passwordBox = New-V2TextBox -X 620 -Y 88 -Width 190 -Text 'JavierTorres'
    $passwordBox.ReadOnly = $true
    $passwordBox.TextAlign = 'Center'
    $toolsCard.Controls.AddRange([System.Windows.Forms.Control[]]@($pcnDriverLink, $pcnOfficeLink, $pcnActivationLink, $pcnWindowsLink, $passwordBox))
    $drivers.Controls.Add($toolsCard)

    $sourcesCard = New-V2Card -X 0 -Y 348 -Width 870 -Height 150 -Title 'Manufacturer Sources (Reference Only)'
    $sourcesCard.Controls.Add((New-V2Label -Text 'Use these sources for reference and manual research. This tool does not install vendor packages from these links.' -X 20 -Y 42 -Width 790 -Height 24 -ForeColor $colors.Muted))
    $sourcesCard.Controls.Add((New-V2LinkLabel -Text 'Dell Drivers' -Url 'https://www.dell.com/support/home/en-us?app=drivers' -X 20 -Y 82 -Width 180))
    $sourcesCard.Controls.Add((New-V2LinkLabel -Text 'HP Support' -Url 'https://ftp.ext.hp.com/pub/caps-softpaq/cmit/HPIA.html' -X 225 -Y 82 -Width 180))
    $sourcesCard.Controls.Add((New-V2LinkLabel -Text 'Lenovo Support' -Url 'https://support.lenovo.com/us/en/solutions/ht003029-lenovo-system-update-update-drivers-bios-and-applications' -X 430 -Y 82 -Width 180))
    $sourcesCard.Controls.Add((New-V2LinkLabel -Text 'ASUS Support' -Url 'https://www.asus.com/support/download-center/' -X 635 -Y 82 -Width 180))
    $sourcesCard.Controls.Add((New-V2Label -Text 'Driver installation remains controlled by Windows Update unless a future vendor module is added.' -X 20 -Y 116 -Width 790 -Height 22 -Font $fontSmall -ForeColor $colors.Muted))
    $drivers.Controls.Add($sourcesCard)

    $logs = $pages['Logs']
    $logsCard = New-V2Card -X 0 -Y 0 -Width 870 -Height 510 -Title 'Application Logs'
    $logsCard.Anchor = 'Top,Bottom,Left,Right'
    $logsCard.Controls.Add((New-V2Label -Text 'View and analyze tool logs for troubleshooting.' -X 20 -Y 40 -Width 400 -Height 24 -ForeColor $colors.Muted))
    $logFilterLabel = New-V2Label -Text 'Filter logs' -X 610 -Y 48 -Width 230 -Height 20 -Font $fontSmall -ForeColor $colors.Muted
    $logFilterLabel.Anchor = 'Top,Right'
    $logsCard.Controls.Add($logFilterLabel)
    $refreshLogsButton = New-V2Button -Text 'Refresh' -X 20 -Y 72 -Width 110 -Height 30
    $followLogsButton = New-V2Button -Text 'Following' -X 140 -Y 72 -Width 110 -Height 30
    $bottomLogsButton = New-V2Button -Text 'Bottom' -X 260 -Y 72 -Width 110 -Height 30
    $openLogFileButton = New-V2Button -Text 'Open Log File' -X 380 -Y 72 -Width 125 -Height 30 -BorderColor $colors.Border
    $filterBox = New-V2TextBox -X 610 -Y 72 -Width 230 -Height 28 -Text ''
    $filterBox.Anchor = 'Top,Right'
    $logFilterPlaceholder = 'Type to filter...'
    $filterBox.Text = $logFilterPlaceholder
    $filterBox.ForeColor = $colors.Muted
    $uiState.LogFilterPlaceholderActive = $true
    $logsCard.Controls.AddRange([System.Windows.Forms.Control[]]@($refreshLogsButton, $followLogsButton, $bottomLogsButton, $openLogFileButton, $filterBox))
    $logBox = New-Object System.Windows.Forms.RichTextBox
    $logBox.ReadOnly = $true
    $logBox.BorderStyle = 'FixedSingle'
    $logBox.BackColor = [System.Drawing.Color]::FromArgb(7, 12, 17)
    $logBox.ForeColor = $colors.Text
    $logBox.Font = $fontMono
    $logBox.Location = New-V2Point 20 112
    $logBox.Size = New-V2Size 820 345
    $logBox.Anchor = 'Top,Bottom,Left,Right'
    $logBox.WordWrap = $true
    $logBox.ScrollBars = 'ForcedVertical'
    $logBox.HideSelection = $false
    $logsCard.Controls.Add($logBox)
    $logFooter = New-V2Label -Text 'Log file: WinUpdateTool.log' -X 20 -Y 466 -Width 600 -Height 24 -Font $fontSmall -ForeColor $colors.Muted
    $logFooter.Anchor = 'Bottom,Left,Right'
    $logsCard.Controls.Add($logFooter)
    $logs.Controls.Add($logsCard)

    function Get-V2LogFilter {
        if ([bool]$uiState.LogFilterPlaceholderActive) {
            return ''
        }

        return [string]$filterBox.Text
    }

    function Set-V2LogFollowOffset {
        param([string]$Path)

        if (Test-Path -LiteralPath $Path -PathType Leaf) {
            $item = Get-Item -LiteralPath $Path -ErrorAction Stop
            $uiState.LogFilePath = [string]$item.FullName
            $uiState.LogFileOffset = [int64]$item.Length
        }
    }

    function Add-V2LogText {
        param(
            [AllowNull()]
            [string]$Text,

            [switch]$ScrollToEnd
        )

        if ([string]::IsNullOrEmpty($Text)) {
            return
        }

        $logBox.SuspendLayout()
        try {
            $logBox.AppendText($Text)
            if ($logBox.TextLength -gt 240000) {
                $trimStart = [Math]::Max(0, $logBox.TextLength - 180000)
                $logBox.Text = $logBox.Text.Substring($trimStart)
            }

            if ($ScrollToEnd) {
                $logBox.SelectionStart = $logBox.TextLength
                $logBox.SelectionLength = 0
                $logBox.ScrollToCaret()
            }
        }
        finally {
            $logBox.ResumeLayout()
        }
    }

    function Update-V2LogFollow {
        try {
            $paths = Initialize-PcnWinUpdateFolders
            if (-not (Test-Path -LiteralPath $paths.LogFile -PathType Leaf)) {
                return
            }

            $item = Get-Item -LiteralPath $paths.LogFile -ErrorAction Stop
            if ($uiState.LogFilePath -ne [string]$item.FullName -or [int64]$uiState.LogFileOffset -gt [int64]$item.Length) {
                Refresh-V2Logs -ScrollToEnd
                return
            }

            if ([int64]$uiState.LogFileOffset -eq [int64]$item.Length) {
                return
            }

            $stream = [System.IO.File]::Open($item.FullName, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
            try {
                [void]$stream.Seek([int64]$uiState.LogFileOffset, [System.IO.SeekOrigin]::Begin)
                $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8, $true)
                try {
                    $newText = $reader.ReadToEnd()
                    $uiState.LogFileOffset = [int64]$stream.Position
                }
                finally {
                    $reader.Dispose()
                }
            }
            finally {
                if ($stream) {
                    $stream.Dispose()
                }
            }

            $filter = Get-V2LogFilter
            if (-not [string]::IsNullOrWhiteSpace($filter)) {
                $newLines = @($newText -split "`r?`n" | Where-Object { $_ -like "*$filter*" })
                if ($newLines.Count -eq 0) {
                    return
                }
                $newText = (($newLines -join "`r`n") + "`r`n")
            }

            Add-V2LogText -Text $newText -ScrollToEnd
            $logFooter.Text = "Log file: $($paths.LogFile)    Follow: live append"
        }
        catch {
            $footerLabel.Text = "Log follow warning: $($_.Exception.Message)"
        }
    }

    function Open-V2LogFile {
        try {
            $paths = Initialize-PcnWinUpdateFolders
            if (-not (Test-Path -LiteralPath $paths.LogFile -PathType Leaf)) {
                Set-Content -LiteralPath $paths.LogFile -Value 'No log entries yet.' -Encoding UTF8
            }

            Start-Process -FilePath 'notepad.exe' -ArgumentList "`"$($paths.LogFile)`"" | Out-Null
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Open Log File', 'OK', 'Warning') | Out-Null
        }
    }

    function Refresh-V2Logs {
        param([switch]$ScrollToEnd)

        try {
            $paths = Initialize-PcnWinUpdateFolders
            if (-not (Test-Path -LiteralPath $paths.LogFile)) {
                $logBox.Text = "No log file yet.`r`n$($paths.LogFile)"
                return
            }

            $lines = Get-Content -LiteralPath $paths.LogFile -Tail 1250 -ErrorAction Stop
            $filter = Get-V2LogFilter
            if (-not [string]::IsNullOrWhiteSpace($filter)) {
                $lines = $lines | Where-Object { $_ -like "*$filter*" }
            }

            $nextText = ($lines -join "`r`n")
            $changed = ($uiState.LastLogText -ne $nextText)
            if ($changed) {
                $logBox.SuspendLayout()
                try {
                    $logBox.Text = $nextText
                    $uiState.LastLogText = $nextText
                    $uiState.LastLogFilter = $filter
                }
                finally {
                    $logBox.ResumeLayout()
                }
            }

            if ($ScrollToEnd -or (($changed) -and [bool]$uiState.LogFollow)) {
                $logBox.SelectionStart = $logBox.TextLength
                $logBox.SelectionLength = 0
                $logBox.ScrollToCaret()
            }

            Set-V2LogFollowOffset -Path $paths.LogFile
            $uiState.LogLoadedLineCount = @($lines).Count
            $logFooter.Text = "Log file: $($paths.LogFile)    Lines loaded: $(@($lines).Count)"
        }
        catch {
            $logBox.Text = "Could not load logs: $($_.Exception.Message)"
        }
    }

    function Refresh-V2Status {
        try {
            $state = Get-PcnWinUpdateState
            $config = Get-PcnWinUpdateConfig
            $lastRun = Format-V2Date -Value $state.LastRunStarted
            $lastInstall = Format-V2Date -Value $state.LastRunFinished
            $lastScanValue.Text = $lastRun
            $lastInstallValue.Text = $lastInstall

            $pendingReboot = Test-PcnPendingReboot
            $uiState.PendingReboot = $pendingReboot
            if ([bool]$pendingReboot.Pending) {
                $reasonText = if (@($pendingReboot.Reasons).Count -gt 0) { @($pendingReboot.Reasons)[0] } else { 'Windows reports that a restart is pending.' }
                $rebootValue.Text = 'Required'
                $rebootValue.ForeColor = $colors.Orange
                $restartLabel.Text = "Restart required: $reasonText"
                $restartNowButton.Enabled = $true
            }
            else {
                $rebootValue.Text = 'Not required'
                $rebootValue.ForeColor = $colors.Green
                if ($pendingReboot.PSObject.Properties['Warnings'] -and @($pendingReboot.Warnings).Count -gt 0) {
                    $restartLabel.Text = 'Not required. Non-blocking rename warnings were detected.'
                }
                else {
                    $restartLabel.Text = 'Not required'
                }
                $restartNowButton.Enabled = $false
            }

            if ([bool]$config.Enabled) {
                $next = Get-PcnScheduledTaskStatus
                $taskInstalled = $false
                if ($next.PSObject.Properties['Installed']) {
                    $taskInstalled = [bool]$next.Installed
                }
                elseif ($next.PSObject.Properties['Exists']) {
                    $taskInstalled = [bool]$next.Exists
                }

                if ($taskInstalled) {
                    $nextRunText = Format-V2Date -Value $next.NextRunTime
                    if ($nextRunText -eq 'Not yet') {
                        $nextRunText = 'Installed'
                    }
                    $startupText = if ([bool]$config.RunAtStartup) { " + startup delay $($config.StartupDelayMinutes)m" } else { '' }
                    $scheduleSummaryText.Text = "Next run: $nextRunText`r`nMode: $($config.Frequency) at $($config.Time)$startupText"
                    $nextRunValue.Text = $nextRunText
                    $nextModeValue.Text = "$($config.Frequency) at $($config.Time)$startupText"
                }
                else {
                    $scheduleSummaryText.Text = 'Schedule enabled, task not installed.'
                    $nextRunValue.Text = 'Task not installed'
                    $startupText = if ([bool]$config.RunAtStartup) { " + startup delay $($config.StartupDelayMinutes)m" } else { '' }
                    $nextModeValue.Text = "$($config.Frequency) at $($config.Time)$startupText"
                }
            }
            else {
                $scheduleSummaryText.Text = 'Automatic schedule is disabled.'
                $nextRunValue.Text = 'Not scheduled'
                $nextModeValue.Text = 'Schedule disabled'
            }
        }
        catch {
            $healthValue.Text = 'Check'
            $healthValue.ForeColor = $colors.Orange
            $footerLabel.Text = "Status warning: $($_.Exception.Message)"
        }
    }

    function Load-V2ScheduleConfig {
        try {
            $config = Get-PcnWinUpdateConfig
            $dailyRadio.Checked = ([string]$config.Frequency -eq 'Daily')
            $weeklyRadio.Checked = ([string]$config.Frequency -eq 'Weekly')
            $monthlyRadio.Checked = ([string]$config.Frequency -eq 'Monthly')
            if (-not ($dailyRadio.Checked -or $weeklyRadio.Checked -or $monthlyRadio.Checked)) {
                $dailyRadio.Checked = $true
            }
            if ($scheduleTimeCombo.Items.Contains([string]$config.Time)) {
                $scheduleTimeCombo.SelectedItem = [string]$config.Time
            }
            if ($scheduleDayCombo.Items.Contains([string]$config.DayOfWeek)) {
                $scheduleDayCombo.SelectedItem = [string]$config.DayOfWeek
            }
            if ($scheduleMonthDayCombo.Items.Contains([string]$config.MonthlyDay)) {
                $scheduleMonthDayCombo.SelectedItem = [string]$config.MonthlyDay
            }
            $startupCheck.Checked = [bool]$config.RunAtStartup
            if ($startupDelayCombo.Items.Contains([string]$config.StartupDelayMinutes)) {
                $startupDelayCombo.SelectedItem = [string]$config.StartupDelayMinutes
            }
            $wakeCheck.Checked = [bool]$config.WakeToRun
            $missedCheck.Checked = [bool]$config.RunIfMissed
        }
        catch {
            $dailyRadio.Checked = $true
        }
    }

    function Save-V2Schedule {
        try {
            $config = Get-PcnWinUpdateConfig
            $config.Enabled = $true
            if ($dailyRadio.Checked) { $config.Frequency = 'Daily' }
            elseif ($weeklyRadio.Checked) { $config.Frequency = 'Weekly' }
            elseif ($monthlyRadio.Checked) { $config.Frequency = 'Monthly' }
            else { $config.Frequency = 'Daily' }
            $config.Time = [string]$scheduleTimeCombo.SelectedItem
            $config.DayOfWeek = [string]$scheduleDayCombo.SelectedItem
            $config.MonthlyDay = [int]$scheduleMonthDayCombo.SelectedItem
            $config.RunAtStartup = [bool]$startupCheck.Checked
            $config.StartupDelayMinutes = [int]$startupDelayCombo.SelectedItem
            $config.WakeToRun = [bool]$wakeCheck.Checked
            $config.RunIfMissed = [bool]$missedCheck.Checked
            $config.AutoRetryEnabled = ([string]$retryAttemptsCombo.SelectedItem -ne '0 times')
            $config.RetryMaxAttempts = switch ([string]$retryAttemptsCombo.SelectedItem) {
                '0 times' { 0 }
                '1 time' { 1 }
                '5 times' { 5 }
                default { 3 }
            }
            $config.RetryInitialDelayMinutes = switch ([string]$retryIntervalCombo.SelectedItem) {
                '15 minutes' { 15 }
                '60 minutes' { 60 }
                default { 5 }
            }
            $config.MinimumCooldownMinutes = [int]$config.RetryInitialDelayMinutes
            $config.DisplayTheme = 'Dark'
            Save-PcnWinUpdateConfig -Config $config
            $engineScriptPath = Get-V2MainScriptPath
            Register-PcnWinUpdateScheduledTask -Config $config -ScriptPath $engineScriptPath
            $footerLabel.Text = 'Schedule saved.'
            Refresh-V2Status
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Schedule Error', 'OK', 'Error') | Out-Null
        }
    }

    function Clear-V2Schedule {
        $answer = [System.Windows.Forms.MessageBox]::Show(
            "Clear the saved schedule and remove PcNinja WinUpdate Tool scheduled tasks?`r`n`r`nThe PcNinja Task Scheduler folder may remain, but this tool's schedule, retry, and run-once tasks will be removed.",
            'Clear Schedule',
            'YesNo',
            'Warning'
        )

        if ($answer -ne 'Yes') {
            return
        }

        try {
            $cleanup = Unregister-PcnWinUpdateToolTasks
            $config = Get-PcnWinUpdateConfig
            $config.Enabled = $false
            $config.RunAtStartup = $false
            Save-PcnWinUpdateConfig -Config $config

            $state = Get-PcnWinUpdateState
            $state.LastRetryScheduled = $null
            $state.LastRetryReason = $null
            $state.RetryCount = 0
            Save-PcnWinUpdateState -State $state

            $dailyRadio.Checked = $true
            $startupCheck.Checked = $false
            $footerLabel.Text = "Schedule cleared. Removed task(s): $(@($cleanup.Removed).Count)."
            Load-V2ScheduleConfig
            Refresh-V2Status
            if ($pages['Logs'].Visible -and [bool]$uiState.LogFollow) {
                Refresh-V2Logs -ScrollToEnd
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Clear Schedule Error', 'OK', 'Error') | Out-Null
        }
    }

    function Get-V2UpdateScopeArguments {
        $parts = New-Object System.Collections.Generic.List[string]

        if ([bool]$windowsUpdatesCheck.Checked) {
            $parts.Add('-IncludeWindowsUpdates') | Out-Null
        }

        if ([bool]$optionalUpdatesCheck.Checked) {
            $parts.Add('-IncludeOptionalUpdates') | Out-Null
        }

        if ([bool]$driverUpdatesCheck.Checked) {
            $parts.Add('-IncludeDriverUpdates') | Out-Null
        }

        if ([bool]$firmwareUpdatesCheck.Checked) {
            $parts.Add('-IncludeFirmwareUpdates') | Out-Null
        }

        if ($parts.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show('Select at least one update scope before checking or installing.', 'Update Scope', 'OK', 'Information') | Out-Null
            return $null
        }

        return ($parts -join ' ')
    }

    function Format-V2PendingRebootDetails {
        param([object]$PendingState)

        if (-not $PendingState) {
            return 'Restart state has not been checked yet.'
        }

        $lines = New-Object System.Collections.Generic.List[string]
        $lines.Add("Pending: $([bool]$PendingState.Pending)") | Out-Null

        if (@($PendingState.Reasons).Count -gt 0) {
            $lines.Add('') | Out-Null
            $lines.Add('Reasons:') | Out-Null
            foreach ($reason in @($PendingState.Reasons)) {
                $lines.Add("  - $reason") | Out-Null
            }
        }

        if ($PendingState.PSObject.Properties['Warnings'] -and @($PendingState.Warnings).Count -gt 0) {
            $lines.Add('') | Out-Null
            $lines.Add('Warnings:') | Out-Null
            foreach ($warning in @($PendingState.Warnings)) {
                $lines.Add("  - $warning") | Out-Null
            }
        }

        if ($PendingState.PSObject.Properties['BlockingFileRenameOperations'] -and @($PendingState.BlockingFileRenameOperations).Count -gt 0) {
            $lines.Add('') | Out-Null
            $lines.Add('Blocking file rename operations:') | Out-Null
            foreach ($operation in @($PendingState.BlockingFileRenameOperations | Select-Object -First 8)) {
                $lines.Add("  - $($operation.Source) -> $($operation.Destination)") | Out-Null
            }
        }

        return ($lines -join "`r`n")
    }

    function Show-V2RestartRequiredDialog {
        param([ValidateSet('Check', 'Install')][string]$ActionName = 'Check')

        $dialog = New-Object System.Windows.Forms.Form
        $dialog.Text = 'Restart Required'
        $dialog.StartPosition = 'CenterParent'
        $dialog.FormBorderStyle = 'FixedDialog'
        $dialog.MinimizeBox = $false
        $dialog.MaximizeBox = $false
        $dialog.ShowInTaskbar = $false
        $dialog.ClientSize = New-V2Size 650 260
        $dialog.BackColor = $colors.CardBack
        $dialog.ForeColor = $colors.Text
        $dialog.Font = $fontBase
        $dialog.Tag = 'Cancel'
        if ($form.Icon) {
            $dialog.Icon = $form.Icon
        }

        $dialog.Controls.Add((New-V2Label -Text 'Windows restart is pending' -X 24 -Y 22 -Width 590 -Height 32 -Font $fontHero))
        $dialog.Controls.Add((New-V2Label -Text 'Windows reports that a restart is required. You can restart now, cancel, or ignore this once and continue the requested action.' -X 24 -Y 68 -Width 590 -Height 54 -ForeColor $colors.Muted))

        $detailsBox = New-Object System.Windows.Forms.TextBox
        $detailsBox.Multiline = $true
        $detailsBox.ReadOnly = $true
        $detailsBox.BorderStyle = 'FixedSingle'
        $detailsBox.BackColor = $colors.Input
        $detailsBox.ForeColor = $colors.Text
        $detailsBox.Font = $fontSmall
        $detailsBox.Location = New-V2Point 24 126
        $detailsBox.Size = New-V2Size 590 58
        $detailsBox.Text = Format-V2PendingRebootDetails -PendingState $uiState.PendingReboot
        $dialog.Controls.Add($detailsBox)

        $restartChoice = New-V2Button -Text 'Restart Now' -X 190 -Y 204 -Width 120 -Height 34 -BackColor ([System.Drawing.Color]::FromArgb(42, 24, 18)) -BorderColor $colors.Orange -ForeColor $colors.Orange
        $ignoreText = if ($ActionName -eq 'Install') { 'Ignore and install' } else { 'Ignore and check' }
        $ignoreChoice = New-V2Button -Text $ignoreText -X 324 -Y 204 -Width 150 -Height 34
        $cancelChoice = New-V2Button -Text 'Cancel' -X 488 -Y 204 -Width 90 -Height 34 -BorderColor $colors.Border
        $restartChoice.Add_Click({ $dialog.Tag = 'Restart'; $dialog.Close() })
        $ignoreChoice.Add_Click({ $dialog.Tag = 'Ignore'; $dialog.Close() })
        $cancelChoice.Add_Click({ $dialog.Tag = 'Cancel'; $dialog.Close() })
        $dialog.Controls.AddRange([System.Windows.Forms.Control[]]@($restartChoice, $ignoreChoice, $cancelChoice))
        $dialog.CancelButton = $cancelChoice

        $dialog.ShowDialog($form) | Out-Null
        return [string]$dialog.Tag
    }

    function Confirm-V2RestartGate {
        param([ValidateSet('Check', 'Install')][string]$ActionName = 'Check')

        try {
            $pending = Test-PcnPendingReboot
            $uiState.PendingReboot = $pending
            if (-not [bool]$pending.Pending) {
                return $true
            }

            $choice = Show-V2RestartRequiredDialog -ActionName $ActionName
            if ($choice -eq 'Restart') {
                Restart-PcnComputerNow
                return $false
            }

            if ($choice -eq 'Ignore') {
                Write-PcnWinUpdateLog -Message "User ignored pending restart for V2 $ActionName action. Reasons: $(@($pending.Reasons) -join '; ')" -EntryType Warning -EventID 1095
                return $true
            }

            $footerLabel.Text = "$ActionName cancelled because restart is pending."
            return $false
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Restart Required', 'OK', 'Warning') | Out-Null
            return $false
        }
    }

    function Show-V2WindowsUpdateSnoozeDialog {
        param([string]$ActivityMessage = 'Windows Update or Windows servicing is active.')

        $dialog = New-Object System.Windows.Forms.Form
        $dialog.Text = 'Windows Update Is Active'
        $dialog.StartPosition = 'CenterParent'
        $dialog.FormBorderStyle = 'FixedDialog'
        $dialog.MinimizeBox = $false
        $dialog.MaximizeBox = $false
        $dialog.ShowInTaskbar = $false
        $dialog.ClientSize = New-V2Size 640 250
        $dialog.BackColor = $colors.CardBack
        $dialog.ForeColor = $colors.Text
        $dialog.Font = $fontBase
        $dialog.Tag = 'Cancel'
        if ($form.Icon) {
            $dialog.Icon = $form.Icon
        }

        $dialog.Controls.Add((New-V2Label -Text 'Windows Update is active' -X 24 -Y 24 -Width 580 -Height 30 -Font $fontHero))
        $message = "$ActivityMessage`r`n`r`nSnooz temporarily stops Windows Update services, runs PcNinja, then starts them again. Retry leaves Windows Update alone and schedules a retry using your retry policy."
        $dialog.Controls.Add((New-V2Label -Text $message -X 24 -Y 70 -Width 590 -Height 92 -ForeColor $colors.Muted))

        $snoozeChoice = New-V2Button -Text 'Snooz to run' -X 162 -Y 186 -Width 120 -Height 34 -BackColor ([System.Drawing.Color]::FromArgb(52, 28, 88)) -BorderColor $colors.Purple
        $retryChoice = New-V2Button -Text 'Retry later' -X 298 -Y 186 -Width 120 -Height 34
        $cancelChoice = New-V2Button -Text 'Cancel' -X 434 -Y 186 -Width 90 -Height 34 -BorderColor $colors.Border
        $snoozeChoice.Add_Click({ $dialog.Tag = 'Snooze'; $dialog.Close() })
        $retryChoice.Add_Click({ $dialog.Tag = 'Retry'; $dialog.Close() })
        $cancelChoice.Add_Click({ $dialog.Tag = 'Cancel'; $dialog.Close() })
        $dialog.Controls.AddRange([System.Windows.Forms.Control[]]@($snoozeChoice, $retryChoice, $cancelChoice))
        $dialog.AcceptButton = $snoozeChoice
        $dialog.CancelButton = $cancelChoice

        $dialog.ShowDialog($form) | Out-Null
        return [string]$dialog.Tag
    }

    function Request-V2WindowsUpdateRetry {
        param([string]$Reason)

        $config = Get-PcnWinUpdateConfig
        $engineScriptPath = Get-V2MainScriptPath
        $retry = Request-PcnWinUpdateRetry -ScriptPath $engineScriptPath -Config $config -Reason $Reason
        $state = Get-PcnWinUpdateState
        $state.LastRunFinished = (Get-Date).ToString('s')
        $state.LastRunType = 'Manual'
        $state.LastResult = $retry.Result
        $state.LastMessage = $retry.Message
        $state.LastRebootRequired = $false
        Save-PcnWinUpdateState -State $state
        $footerLabel.Text = $retry.Message
        Refresh-V2Status
        if ($pages['Logs'].Visible -and [bool]$uiState.LogFollow) {
            Refresh-V2Logs -ScrollToEnd
        }
    }

    function Start-V2RunUpdates {
        if ($uiState.ScanProcess -and -not $uiState.ScanProcess.HasExited) {
            $footerLabel.Text = 'A check is already running.'
            return
        }

        if (-not (Confirm-V2RestartGate -ActionName 'Install')) {
            Refresh-V2Status
            return
        }

        $scopeArguments = Get-V2UpdateScopeArguments
        if ($null -eq $scopeArguments) {
            return
        }

        if ([bool]$firmwareUpdatesCheck.Checked) {
            $answer = [System.Windows.Forms.MessageBox]::Show(
                "Firmware/BIOS updates are enabled for this run.`r`n`r`nContinue only if the machine is on reliable power and you are comfortable letting Windows Update install firmware packages.",
                'Firmware Updates Enabled',
                'YesNo',
                'Warning'
            )

            if ($answer -ne 'Yes') {
                $footerLabel.Text = 'Windows Update run cancelled.'
                return
            }
        }

        $allowStopBackgroundActivity = $false
        $activity = Get-PcnWindowsUpdateActivity
        if ($activity.IsInstalling -or $activity.HasBackgroundActivity) {
            $choice = Show-V2WindowsUpdateSnoozeDialog -ActivityMessage $activity.Message
            if ($choice -eq 'Retry') {
                Request-V2WindowsUpdateRetry -Reason $activity.Message
                return
            }

            if ($choice -eq 'Snooze') {
                $allowStopBackgroundActivity = $true
                $footerLabel.Text = 'Snoozing Windows Update activity.'
            }
            else {
                $footerLabel.Text = 'Windows Update run cancelled.'
                return
            }
        }

        $engineScriptPath = Get-V2MainScriptPath
        $allow = if ($allowStopBackgroundActivity) { ' -AllowStopBackgroundActivity' } else { '' }
        $arguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}" -Mode RunUpdates -Silent -RunType Manual {1}{2}' -f $engineScriptPath, $scopeArguments, $allow
        Start-V2ToolProcess -Arguments $arguments -WorkingDirectory (Split-Path -Parent $engineScriptPath) | Out-Null
        Write-PcnWinUpdateLog -Message "V2 update run requested. Snooz: $allowStopBackgroundActivity. Scope: $scopeArguments. Engine: $engineScriptPath" -EventID 1084
        $footerLabel.Text = if ($allowStopBackgroundActivity) { 'Snooz update run started.' } else { 'Windows Update run started.' }
    }

    function Start-V2ResetWindowsUpdate {
        $answer = [System.Windows.Forms.MessageBox]::Show(
            "Reset Windows Update will stop Windows Update services, delete and recreate C:\Windows\SoftwareDistribution, and restart services.`r`n`r`nContinue?",
            'Reset Windows Update',
            'YesNo',
            'Warning'
        )

        if ($answer -ne 'Yes') {
            return
        }

        $engineScriptPath = Get-V2MainScriptPath
        $arguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}" -Mode ResetWindowsUpdate -ConfirmReset' -f $engineScriptPath
        Start-V2ToolProcess -Arguments $arguments -WorkingDirectory (Split-Path -Parent $engineScriptPath) | Out-Null
        $footerLabel.Text = 'Windows Update reset started.'
    }

    function Start-V2DriverAudit {
        try {
            $footerLabel.Text = 'Creating driver audit...'
            $form.Refresh()
            $report = Export-PcnDriverInventoryReport
            $auditStatus.Text = "Last audit: $(Get-Date -Format 'dd-MMM HH:mm')"
            $reportSummary.Text = "Devices scanned: $($report.TotalDevices)`r`nDriver candidates: $($report.CandidateDevices)`r`nAudit candidates: $($report.AuditCandidateDevices)`r`nHigh priority: $($report.HighPriorityAuditCandidates)"
            $footerLabel.Text = 'Driver audit created.'
            [System.Windows.Forms.MessageBox]::Show("Driver audit created.`r`n$($report.CsvPath)", 'Driver Audit', 'OK', 'Information') | Out-Null
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Driver Audit Error', 'OK', 'Error') | Out-Null
        }
    }

    function Open-V2DriverReports {
        $paths = Initialize-PcnWinUpdateFolders
        Start-Process -FilePath explorer.exe -ArgumentList $paths.DriverReportRoot | Out-Null
    }

    function Show-V2UpdateList {
        $items = @($uiState.LastPreviewItems)
        if ($items.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show('No update list is available yet. Run Check Available Updates first.', 'Available Updates', 'OK', 'Information') | Out-Null
            return
        }

        $dialog = New-Object System.Windows.Forms.Form
        $dialog.Text = 'Available Updates'
        $dialog.StartPosition = 'CenterParent'
        $dialog.FormBorderStyle = 'Sizable'
        $dialog.MinimizeBox = $false
        $dialog.ShowInTaskbar = $false
        $dialog.ClientSize = New-V2Size 760 470
        $dialog.MinimumSize = New-V2Size 620 360
        $dialog.BackColor = $colors.CardBack
        $dialog.ForeColor = $colors.Text
        $dialog.Font = $fontBase
        if ($form.Icon) {
            $dialog.Icon = $form.Icon
        }

        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Multiline = $true
        $textBox.ReadOnly = $true
        $textBox.ScrollBars = 'Both'
        $textBox.WordWrap = $false
        $textBox.BorderStyle = 'FixedSingle'
        $textBox.BackColor = $colors.Input
        $textBox.ForeColor = $colors.Text
        $textBox.Font = $fontMono
        $textBox.Location = New-V2Point 16 16
        $textBox.Size = New-V2Size 728 390
        $textBox.Anchor = 'Top,Bottom,Left,Right'

        $lines = foreach ($item in $items) {
            $state = if ([bool]$item.Included) { 'Included' } else { 'Skipped' }
            $kb = if ($item.Kb -and @($item.Kb).Count -gt 0) { " KB: $(@($item.Kb) -join ',')" } else { '' }
            '{0} | {1} | {2}{3} | {4}' -f $state, $item.Scope, $item.Type, $kb, $item.Title
        }
        $textBox.Text = ($lines -join "`r`n")
        $dialog.Controls.Add($textBox)

        $closeChoice = New-V2Button -Text 'Close' -X 638 -Y 420 -Width 106 -Height 34 -BorderColor $colors.Border
        $closeChoice.Anchor = 'Bottom,Right'
        $closeChoice.Add_Click({ $dialog.Close() })
        $dialog.Controls.Add($closeChoice)
        $dialog.CancelButton = $closeChoice
        $dialog.ShowDialog($form) | Out-Null
    }

    function ConvertFrom-V2ProcessJsonOutput {
        param(
            [AllowNull()]
            [string]$RawOutput,

            [string]$Context = 'background process'
        )

        $text = ([string]$RawOutput).TrimStart([char]0xFEFF).Trim()
        if ([string]::IsNullOrWhiteSpace($text)) {
            throw "$Context did not return JSON."
        }

        try {
            return ($text | ConvertFrom-Json)
        }
        catch {
            $start = $text.IndexOf('{')
            $end = $text.LastIndexOf('}')
            if ($start -ge 0 -and $end -gt $start) {
                $candidate = $text.Substring($start, ($end - $start + 1))
                try {
                    Write-PcnWinUpdateLog -Message "$Context returned non-JSON stream text before/after JSON. Ignoring stream noise for UI parse." -EntryType Warning -EventID 1096
                    return ($candidate | ConvertFrom-Json)
                }
                catch {
                    $null = $_
                }
            }

            $sample = $text
            if ($sample.Length -gt 400) {
                $sample = $sample.Substring(0, 400) + '...'
            }

            throw "$Context returned invalid JSON. First output: $sample"
        }
    }

    function Set-V2PreviewControlsEnabled {
        param([bool]$Enabled)

        $checkAvailableButton.Enabled = $Enabled
        $installSelectedButton.Enabled = $Enabled
        $viewUpdateListButton.Enabled = $Enabled
    }

    function Complete-V2UpdatePreviewIfReady {
        if (-not $uiState.ScanProcess) {
            return
        }

        if (-not $uiState.ScanProcess.HasExited) {
            $footerLabel.Text = 'Scan is still running...'
            return
        }

        $scanTimer.Stop()

        try {
            $raw = ''
            if ($uiState.ScanOutPath -and (Test-Path -LiteralPath $uiState.ScanOutPath -PathType Leaf)) {
                $raw = Get-Content -LiteralPath $uiState.ScanOutPath -Raw -ErrorAction Stop
            }

            if ([string]::IsNullOrWhiteSpace($raw)) {
                $stderr = ''
                if ($uiState.ScanErrPath -and (Test-Path -LiteralPath $uiState.ScanErrPath -PathType Leaf)) {
                    $stderr = Get-Content -LiteralPath $uiState.ScanErrPath -Raw -ErrorAction SilentlyContinue
                }

                throw "Preview scan did not return JSON. $stderr"
            }

            $scan = ConvertFrom-V2ProcessJsonOutput -RawOutput $raw -Context 'Preview scan'
            $scanObjects = @($scan)
            if ($scanObjects.Count -gt 1 -or $scan -is [array]) {
                $previewObjects = @($scanObjects | Where-Object {
                    $_ -and $_.PSObject.Properties['Mode'] -and ([string]$_.Mode -eq 'PreviewUpdates')
                })

                if ($previewObjects.Count -gt 0) {
                    $scan = $previewObjects[-1]
                    Write-PcnWinUpdateLog -Message 'Preview scan returned multiple JSON objects. Using the PreviewUpdates result object.' -EntryType Warning -EventID 1098
                }
                else {
                    $resultObjects = @($scanObjects | Where-Object {
                        $_ -and ($_.PSObject.Properties['Success'] -or $_.PSObject.Properties['Result'])
                    })
                    if ($resultObjects.Count -gt 0) {
                        $scan = $resultObjects[-1]
                    }
                }
            }

            $scanSucceeded = $false
            if ($scan.PSObject.Properties['Success']) {
                $scanSucceeded = [bool]$scan.Success
            }
            elseif ($scan.PSObject.Properties['Result']) {
                $scanSucceeded = ([string]$scan.Result -eq 'Succeeded')
            }

            if (-not $scanSucceeded) {
                $failureText = if ($scan.PSObject.Properties['Message'] -and -not [string]::IsNullOrWhiteSpace([string]$scan.Message)) {
                    [string]$scan.Message
                }
                elseif ($scan.PSObject.Properties['Errors'] -and @($scan.Errors).Count -gt 0) {
                    @($scan.Errors) -join '; '
                }
                elseif ($scan.PSObject.Properties['Result']) {
                    [string]$scan.Result
                }
                else {
                    'Unknown preview scan failure.'
                }

                if ($uiState.ScanErrPath -and (Test-Path -LiteralPath $uiState.ScanErrPath -PathType Leaf)) {
                    $stderrText = Get-Content -LiteralPath $uiState.ScanErrPath -Raw -ErrorAction SilentlyContinue
                    if (-not [string]::IsNullOrWhiteSpace($stderrText)) {
                        $failureText = "$failureText $stderrText"
                    }
                }

                throw "Preview scan failed: $failureText"
            }

            $importantCount.Text = [string]$scan.Important
            $optionalCount.Text = [string]$scan.Optional
            $driversCount.Text = [string]$scan.Drivers
            $firmwareSkippedCount.Text = [string]$scan.FirmwareSkipped
            $uiState.LastPreviewItems = @($scan.Items)
            if ([int]$scan.Total -eq 0) {
                $availableSummary.Text = "Last check: $(Get-Date -Format 'dd-MMM HH:mm'). No available updates for this machine."
            }
            else {
                $availableSummary.Text = "Last check: $(Get-Date -Format 'dd-MMM HH:mm'). Included: $($scan.Total), discovered: $($scan.TotalDiscovered)."
            }
            $lastScanValue.Text = (Get-Date).ToString('dd-MMM HH:mm')
            $footerLabel.Text = if ([int]$scan.Total -eq 0) {
                'Check complete. No available updates found.'
            }
            else {
                "Check complete. Important: $($scan.Important), Optional: $($scan.Optional), Drivers: $($scan.Drivers), Firmware skipped: $($scan.FirmwareSkipped)."
            }
            Refresh-V2Status
            if ($pages['Logs'].Visible -and [bool]$uiState.LogFollow) {
                Refresh-V2Logs -ScrollToEnd
            }
        }
        catch {
            $importantCount.Text = '!'
            $optionalCount.Text = '!'
            $driversCount.Text = '!'
            $firmwareSkippedCount.Text = '!'
            $availableSummary.Text = 'Check failed. Open Logs for details.'
            $footerLabel.Text = "Preview scan failed: $($_.Exception.Message)"
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Preview Updates', 'OK', 'Warning') | Out-Null
        }
        finally {
            Set-V2PreviewControlsEnabled -Enabled $true
            if ($uiState.ScanProcess) {
                $uiState.ScanProcess.Dispose()
            }
            foreach ($path in @($uiState.ScanOutPath, $uiState.ScanErrPath)) {
                if ($path -and (Test-Path -LiteralPath $path -PathType Leaf)) {
                    Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
                }
            }
            $uiState.ScanProcess = $null
            $uiState.ScanOutPath = $null
            $uiState.ScanErrPath = $null
        }
    }

    function Invoke-V2UpdatePreview {
        if ($uiState.ScanProcess -and -not $uiState.ScanProcess.HasExited) {
            $footerLabel.Text = 'A check is already running.'
            return
        }

        try {
            if (-not (Confirm-V2RestartGate -ActionName 'Check')) {
                Refresh-V2Status
                return
            }

            $scopeArguments = Get-V2UpdateScopeArguments
            if ($null -eq $scopeArguments) {
                return
            }

            $footerLabel.Text = 'Starting Windows Update check...'
            $importantCount.Text = '...'
            $optionalCount.Text = '...'
            $driversCount.Text = '...'
            $firmwareSkippedCount.Text = '...'
            $availableSummary.Text = 'Checking Windows Update and Microsoft Update...'
            Set-V2PreviewControlsEnabled -Enabled $false

            $paths = Initialize-PcnWinUpdateFolders
            $scanId = [guid]::NewGuid().ToString('N')
            $uiState.ScanOutPath = Join-Path $paths.LogRoot "PreviewScan-$scanId.json"
            $uiState.ScanErrPath = Join-Path $paths.LogRoot "PreviewScan-$scanId.err"
            $engineScriptPath = Get-V2MainScriptPath
            $arguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}" -Mode PreviewUpdates -Json {1}' -f $engineScriptPath, $scopeArguments

            $process = Start-Process -FilePath (Get-PcnPowershellPath) `
                -ArgumentList $arguments `
                -WorkingDirectory (Split-Path -Parent $engineScriptPath) `
                -WindowStyle Hidden `
                -RedirectStandardOutput $uiState.ScanOutPath `
                -RedirectStandardError $uiState.ScanErrPath `
                -PassThru

            $uiState.ScanProcess = $process
            Write-PcnWinUpdateLog -Message "V2 available update check started. PID: $($process.Id). Scope: $scopeArguments." -EventID 1085
            $scanTimer.Start()
        }
        catch {
            Set-V2PreviewControlsEnabled -Enabled $true
            $importantCount.Text = '!'
            $optionalCount.Text = '!'
            $driversCount.Text = '!'
            $firmwareSkippedCount.Text = '!'
            $availableSummary.Text = 'Check failed to start.'
            $footerLabel.Text = "Update check failed to start: $($_.Exception.Message)"
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Preview Updates', 'OK', 'Warning') | Out-Null
        }
    }

    function Check-V2ToolUpdateInline {
        try {
            $toolStatusValue.Text = 'Checking'
            $toolStatusValue.ForeColor = $colors.Orange
            $form.Refresh()
            $check = Invoke-PcnAppUpdateCheck -PackageType (Get-V2AppUpdatePackageType)
            $latest = if ($check.LatestPublicLabel) { [string]$check.LatestPublicLabel } else { [string]$check.LatestVersion }
            $latestValueSide.Text = $latest
            if ($check.Result -eq 'UpdateAvailable') {
                $toolStatusValue.Text = 'Update'
                $toolStatusValue.ForeColor = $colors.Purple
            }
            elseif ($check.Result -eq 'UpToDate') {
                $toolStatusValue.Text = 'Up to date'
                $toolStatusValue.ForeColor = $colors.Green
            }
            else {
                $toolStatusValue.Text = 'Problem'
                $toolStatusValue.ForeColor = $colors.Orange
            }
        }
        catch {
            $latestValueSide.Text = 'Unavailable'
            $toolStatusValue.Text = 'Offline'
            $toolStatusValue.ForeColor = $colors.Orange
        }
    }

    $sidebarUpdateButton.Add_Click({ Show-V2ToolUpdateDialog -Owner $form; Check-V2ToolUpdateInline })
    $settingsButton.Add_Click({ Show-V2Page -Name 'Schedule' })
    $helpButton.Add_Click({ Start-Process -FilePath 'https://help.pcninja.pro' | Out-Null })
    $checkAvailableButton.Add_Click({ Invoke-V2UpdatePreview })
    $installSelectedButton.Add_Click({ Start-V2RunUpdates })
    $viewUpdateListButton.Add_Click({ Show-V2UpdateList })
    $restartNowButton.Add_Click({
        try {
            Restart-PcnComputerNow
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Restart Now', 'OK', 'Warning') | Out-Null
        }
    })
    $restartDetailsButton.Add_Click({ [System.Windows.Forms.MessageBox]::Show((Format-V2PendingRebootDetails -PendingState $uiState.PendingReboot), 'Restart State', 'OK', 'Information') | Out-Null })
    $dashboardResetButton.Add_Click({ Start-V2ResetWindowsUpdate })
    $clearScheduleButton.Add_Click({ Clear-V2Schedule })
    $saveScheduleButton.Add_Click({ Save-V2Schedule })
    $driverAuditButton.Add_Click({ Start-V2DriverAudit })
    $openDriverReportButton.Add_Click({ Open-V2DriverReports })
    $viewFullReportButton.Add_Click({ Open-V2DriverReports })
    $refreshLogsButton.Add_Click({ Refresh-V2Logs })
    $openLogFileButton.Add_Click({ Open-V2LogFile })
    $followLogsButton.Add_Click({
        $uiState.LogFollow = -not [bool]$uiState.LogFollow
        $followLogsButton.Text = if ([bool]$uiState.LogFollow) { 'Following' } else { 'Follow' }
        $footerLabel.Text = if ([bool]$uiState.LogFollow) { 'Log follow enabled.' } else { 'Log follow paused.' }
        if ([bool]$uiState.LogFollow) {
            Refresh-V2Logs -ScrollToEnd
        }
    })
    $bottomLogsButton.Add_Click({ $logBox.SelectionStart = $logBox.TextLength; $logBox.ScrollToCaret() })
    $filterBox.Add_GotFocus({
        if ([bool]$uiState.LogFilterPlaceholderActive) {
            $uiState.LogFilterPlaceholderActive = $false
            $filterBox.Text = ''
            $filterBox.ForeColor = $colors.Text
        }
    })
    $filterBox.Add_LostFocus({
        if ([string]::IsNullOrWhiteSpace([string]$filterBox.Text)) {
            $uiState.LogFilterPlaceholderActive = $true
            $filterBox.ForeColor = $colors.Muted
            $filterBox.Text = $logFilterPlaceholder
        }
    })
    $filterBox.Add_TextChanged({ Refresh-V2Logs })

    $form.Add_FormClosed({
        $smokeTimer.Stop()
        $logFollowTimer.Stop()
        $scanTimer.Stop()
        if ($uiState.ScanProcess) {
            $uiState.ScanProcess.Dispose()
            $uiState.ScanProcess = $null
        }
    })

    $form.Add_Shown({
        Load-V2ScheduleConfig
        Refresh-V2Status
        $initialPage = 'Dashboard'
        if (-not [string]::IsNullOrWhiteSpace([string]$env:PCNINJA_V2_UI_SMOKE_PAGE) -and $pages.ContainsKey([string]$env:PCNINJA_V2_UI_SMOKE_PAGE)) {
            $initialPage = [string]$env:PCNINJA_V2_UI_SMOKE_PAGE
        }

        Show-V2Page -Name $initialPage
        if ([string]$env:PCNINJA_V2_UI_SMOKE -eq '1') {
            $footerLabel.Text = 'V2 UI smoke test ready.'
            $smokeTimer.Start()
            return
        }
    })

    [void][System.Windows.Forms.Application]::Run($form)
}
