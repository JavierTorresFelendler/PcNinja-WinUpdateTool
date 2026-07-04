function Show-PcnWinUpdateV2Ui {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    [System.Windows.Forms.Application]::EnableVisualStyles()

    $colors = [pscustomobject]@{
        AppBack = [System.Drawing.Color]::FromArgb(8, 13, 18)
        HeaderBack = [System.Drawing.Color]::FromArgb(7, 11, 16)
        SidebarBack = [System.Drawing.Color]::FromArgb(16, 22, 28)
        CardBack = [System.Drawing.Color]::FromArgb(20, 27, 34)
        CardAlt = [System.Drawing.Color]::FromArgb(17, 24, 31)
        Border = [System.Drawing.Color]::FromArgb(47, 59, 69)
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

    function Start-V2ToolProcess {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Arguments
        )

        $powershell = Get-PcnPowershellPath
        Start-Process -FilePath $powershell -ArgumentList $Arguments -WindowStyle Hidden | Out-Null
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
        $infoText = New-V2Label -Text 'V2 downloads directly from GitHub Releases, verifies SHA256, and then hands off to MSI.' -X 72 -Y 12 -Width 610 -Height 38
        $info.Controls.Add($infoText)
        $dialog.Controls.Add($info)

        $safety = New-V2Card -X 24 -Y 402 -Width 712 -Height 42 -Title ''
        $safety.Controls.Add((New-V2Label -Text 'No git pull is used on customer machines.' -X 72 -Y 8 -Width 610 -Height 24))
        $safety.Controls.Add((New-V2Label -Text ([string][char]0xE72E) -X 22 -Y 5 -Width 38 -Height 30 -Font (New-Object System.Drawing.Font('Segoe MDL2 Assets', 21)) -ForeColor $colors.Purple -Align 'MiddleCenter'))
        $dialog.Controls.Add($safety)

        $checkButton = New-V2Button -Text 'Check Again' -X 24 -Y 466 -Width 128 -Height 32
        $downloadButton = New-V2Button -Text 'Download Verified' -X 164 -Y 466 -Width 164 -Height 32 -BackColor ([System.Drawing.Color]::FromArgb(13, 36, 58))
        $installButton = New-V2Button -Text 'Install MSI' -X 340 -Y 466 -Width 118 -Height 32 -BackColor ([System.Drawing.Color]::FromArgb(42, 24, 67)) -BorderColor $colors.Purple
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
                $check = Invoke-PcnAppUpdateCheck -PackageType 'Msi'
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
                $target = Get-V2DownloadsFolder
                $summary.Text = "Downloading verified MSI to:`r`n$target"
                $dialog.Refresh()
                $download = Invoke-PcnAppUpdateDownload -PackageType 'Msi' -CachePath $target
                if ($download.Success -and $download.FilePath) {
                    $shaValue.Text = 'Verified'
                    $shaValue.ForeColor = $colors.Green
                    [System.Windows.Forms.MessageBox]::Show("Downloaded and verified:`r`n$($download.FilePath)", 'PcNinja Tool Update', 'OK', 'Information') | Out-Null
                }
                elseif ($download.Result -eq 'NoNewerVersion') {
                    [System.Windows.Forms.MessageBox]::Show('No newer MSI is available from the manifest.', 'PcNinja Tool Update', 'OK', 'Information') | Out-Null
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

    $quickActions = New-V2Card -X 16 -Y 462 -Width 228 -Height 112 -Title 'Quick Actions'
    $quickActions.BackColor = $colors.CardAlt
    $sidebar.Controls.Add($quickActions)
    $quickScanButton = New-V2Button -Text 'Scan for Updates' -X 14 -Y 38 -Width 200 -Height 28
    $quickLogsButton = New-V2Button -Text 'View Logs' -X 14 -Y 72 -Width 96 -Height 28 -BorderColor $colors.Border
    $quickResetButton = New-V2Button -Text 'Reset WU' -X 118 -Y 72 -Width 96 -Height 28 -BorderColor $colors.Red -ForeColor $colors.Red
    $quickActions.Controls.AddRange([System.Windows.Forms.Control[]]@($quickScanButton, $quickLogsButton, $quickResetButton))

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
    $tabX = 0
    foreach ($name in @('Dashboard', 'Updates', 'Schedule', 'Drivers', 'Logs')) {
        $button = New-V2Button -Text $name -X $tabX -Y 0 -Width 138 -Height 42 -BorderColor $colors.Border
        $button.Tag = $name
        $button.Add_Click({
            param($sender, $eventArgs)
            foreach ($entry in $pages.GetEnumerator()) {
                $entry.Value.Visible = ($entry.Key -eq [string]$sender.Tag)
            }

            foreach ($tabEntry in $tabButtons.GetEnumerator()) {
                $tabEntry.Value.BackColor = $colors.HeaderBack
                $tabEntry.Value.FlatAppearance.BorderColor = $colors.Border
            }

            $sender.BackColor = $colors.Blue
            $sender.FlatAppearance.BorderColor = $colors.Blue2
        })
        $tabHost.Controls.Add($button)
        $tabButtons[$name] = $button
        $tabX += 138
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

    $smokeTimer = New-Object System.Windows.Forms.Timer
    $smokeTimer.Interval = 1500
    $smokeTimer.Add_Tick({
        $smokeTimer.Stop()
        $form.Close()
    })

    $dashboard = $pages['Dashboard']
    $dashboard.Controls.Add((New-V2Label -Text 'Dashboard' -X 0 -Y 0 -Width 240 -Height 32 -Font $fontHero))
    $overviewCard = New-V2Card -X 0 -Y 44 -Width 595 -Height 150 -Title 'System Update Overview'
    $overviewIcon = New-V2Label -Text ([string][char]0xE73E) -X 22 -Y 48 -Width 70 -Height 58 -Font (New-Object System.Drawing.Font('Segoe MDL2 Assets', 38)) -ForeColor $colors.Green -Align 'MiddleCenter'
    $overviewStatus = New-V2Label -Text 'Your system is ready.' -X 108 -Y 54 -Width 450 -Height 30 -Font $fontTitle
    $overviewSub = New-V2Label -Text 'Use the Updates tab to scan, install, snooz, or review restart status.' -X 108 -Y 88 -Width 450 -Height 26 -ForeColor $colors.Muted
    $overviewCard.Controls.AddRange([System.Windows.Forms.Control[]]@($overviewIcon, $overviewStatus, $overviewSub))
    $dashboard.Controls.Add($overviewCard)

    $updateCard = New-V2Card -X 610 -Y 44 -Width 260 -Height 150 -Title 'PcNinja Tool Update'
    $toolUpdateHeadline = New-V2Label -Text 'Check available' -X 20 -Y 48 -Width 220 -Height 28 -Font $fontTitle -ForeColor $colors.Purple
    $toolUpdateCurrent = New-V2Label -Text "Current: $script:PcnToolPublicLabel" -X 20 -Y 78 -Width 220 -Height 24 -ForeColor $colors.Muted
    $toolUpdateButton = New-V2Button -Text 'Check Tool Update' -X 20 -Y 108 -Width 220 -Height 32 -BackColor ([System.Drawing.Color]::FromArgb(32, 23, 45)) -BorderColor $colors.Purple
    $updateCard.Controls.AddRange([System.Windows.Forms.Control[]]@($toolUpdateHeadline, $toolUpdateCurrent, $toolUpdateButton))
    $dashboard.Controls.Add($updateCard)

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

    $dashActionsCard = New-V2Card -X 0 -Y 376 -Width 870 -Height 115 -Title 'Quick Actions'
    $dashRunButton = New-V2Button -Text 'Run Updates' -X 20 -Y 54 -Width 180 -Height 38 -BackColor ([System.Drawing.Color]::FromArgb(12, 74, 142))
    $dashAuditButton = New-V2Button -Text 'Create Driver Audit' -X 216 -Y 54 -Width 180 -Height 38
    $dashLogsButton = New-V2Button -Text 'View Logs' -X 412 -Y 54 -Width 150 -Height 38
    $dashResetButton = New-V2Button -Text 'Reset Windows Update' -X 578 -Y 54 -Width 220 -Height 38 -BorderColor $colors.Red -ForeColor $colors.Red
    $dashActionsCard.Controls.AddRange([System.Windows.Forms.Control[]]@($dashRunButton, $dashAuditButton, $dashLogsButton, $dashResetButton))
    $dashboard.Controls.Add($dashActionsCard)

    $updates = $pages['Updates']
    $manualCard = New-V2Card -X 0 -Y 0 -Width 870 -Height 130 -Title 'Manual Windows Updates'
    $manualCard.Controls.Add((New-V2Label -Text 'Scan Windows Update and Microsoft Update for your system.' -X 20 -Y 40 -Width 520 -Height 24 -ForeColor $colors.Muted))
    $scanButton = New-V2Button -Text 'Scan' -X 20 -Y 76 -Width 220 -Height 38 -BackColor ([System.Drawing.Color]::FromArgb(12, 74, 142))
    $runUpdatesButton = New-V2Button -Text 'Run Updates' -X 255 -Y 76 -Width 220 -Height 38 -BackColor ([System.Drawing.Color]::FromArgb(12, 74, 142))
    $snoozButton = New-V2Button -Text 'Snooz to run' -X 490 -Y 76 -Width 220 -Height 38 -BackColor ([System.Drawing.Color]::FromArgb(52, 28, 88)) -BorderColor $colors.Purple
    $manualCard.Controls.AddRange([System.Windows.Forms.Control[]]@($scanButton, $runUpdatesButton, $snoozButton))
    $updates.Controls.Add($manualCard)

    $candidateCard = New-V2Card -X 0 -Y 146 -Width 870 -Height 100 -Title 'Candidate Preview'
    $candidateCard.Controls.Add((New-V2Label -Text 'Preview important updates that are available.' -X 20 -Y 40 -Width 360 -Height 24 -ForeColor $colors.Muted))
    $previewButton = New-V2Button -Text 'Preview Updates' -X 20 -Y 64 -Width 150 -Height 28
    $importantCount = New-V2Label -Text '-' -X 480 -Y 42 -Width 60 -Height 32 -Font $fontHero -ForeColor $colors.Orange -Align 'MiddleCenter'
    $optionalCount = New-V2Label -Text '-' -X 610 -Y 42 -Width 60 -Height 32 -Font $fontHero -ForeColor $colors.Blue2 -Align 'MiddleCenter'
    $driversCount = New-V2Label -Text '-' -X 740 -Y 42 -Width 60 -Height 32 -Font $fontHero -ForeColor $colors.Green -Align 'MiddleCenter'
    $candidateCard.Controls.AddRange([System.Windows.Forms.Control[]]@($previewButton, $importantCount, $optionalCount, $driversCount))
    $candidateCard.Controls.Add((New-V2Label -Text 'Important' -X 468 -Y 72 -Width 86 -Height 20 -Font $fontSmall -ForeColor $colors.Muted -Align 'MiddleCenter'))
    $candidateCard.Controls.Add((New-V2Label -Text 'Optional' -X 600 -Y 72 -Width 86 -Height 20 -Font $fontSmall -ForeColor $colors.Muted -Align 'MiddleCenter'))
    $candidateCard.Controls.Add((New-V2Label -Text 'Drivers' -X 728 -Y 72 -Width 86 -Height 20 -Font $fontSmall -ForeColor $colors.Muted -Align 'MiddleCenter'))
    $updates.Controls.Add($candidateCard)

    $restartCard = New-V2Card -X 0 -Y 262 -Width 870 -Height 90 -Title 'Restart State'
    $restartLabel = New-V2Label -Text 'Checking restart state...' -X 20 -Y 48 -Width 500 -Height 24 -ForeColor $colors.Muted
    $restartDetailsButton = New-V2Button -Text 'Details' -X 735 -Y 42 -Width 100 -Height 32 -BorderColor $colors.Border
    $restartCard.Controls.AddRange([System.Windows.Forms.Control[]]@($restartLabel, $restartDetailsButton))
    $updates.Controls.Add($restartCard)

    $linksCard = New-V2Card -X 0 -Y 368 -Width 870 -Height 100 -Title 'Helpful Links'
    $linksCard.Controls.Add((New-V2LinkLabel -Text 'PcNinja Windows Image' -Url 'https://win11.pcninja.pro/' -X 20 -Y 54 -Width 260))
    $linksCard.Controls.Add((New-V2LinkLabel -Text 'PcNinja Classes' -Url 'https://class.pcninja.pro' -X 430 -Y 54 -Width 220))
    $updates.Controls.Add($linksCard)

    $schedule = $pages['Schedule']
    $scheduleCard = New-V2Card -X 0 -Y 0 -Width 430 -Height 230 -Title 'Schedule'
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
    $scheduleTimeCombo = New-V2ComboBox -X 180 -Y 60 -Width 120 -Items @('02:00', '03:00', '04:00', '09:00', '18:00') -Selected '03:00'
    $scheduleDayCombo = New-V2ComboBox -X 180 -Y 92 -Width 120 -Items @('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday') -Selected 'Sunday'
    $scheduleMonthDayCombo = New-V2ComboBox -X 180 -Y 124 -Width 120 -Items @('1', '5', '10', '15', '20', '25', '28') -Selected '15'
    $scheduleCard.Controls.AddRange([System.Windows.Forms.Control[]]@($scheduleTimeCombo, $scheduleDayCombo, $scheduleMonthDayCombo))
    $schedule.Controls.Add($scheduleCard)

    $retryCard = New-V2Card -X 445 -Y 0 -Width 425 -Height 230 -Title 'Retry Policy'
    $retryCard.Controls.Add((New-V2Label -Text 'Configure how to handle failures and retries.' -X 20 -Y 40 -Width 360 -Height 24 -ForeColor $colors.Muted))
    $retryCard.Controls.Add((New-V2Label -Text 'Retry failed updates' -X 20 -Y 78 -Width 170 -Height 24))
    $retryAttemptsCombo = New-V2ComboBox -X 220 -Y 74 -Width 160 -Items @('0 times', '1 time', '3 times', '5 times') -Selected '3 times'
    $retryCard.Controls.Add((New-V2Label -Text 'Retry interval' -X 20 -Y 118 -Width 170 -Height 24))
    $retryIntervalCombo = New-V2ComboBox -X 220 -Y 114 -Width 160 -Items @('5 minutes', '15 minutes', '60 minutes') -Selected '5 minutes'
    $retryCard.Controls.Add((New-V2Label -Text 'On repeated failure' -X 20 -Y 158 -Width 170 -Height 24))
    $retryFailureCombo = New-V2ComboBox -X 220 -Y 154 -Width 160 -Items @('Snooz and retry later', 'Stop after retries') -Selected 'Snooz and retry later'
    $retryCard.Controls.AddRange([System.Windows.Forms.Control[]]@($retryAttemptsCombo, $retryIntervalCombo, $retryFailureCombo))
    $schedule.Controls.Add($retryCard)

    $wakeCard = New-V2Card -X 0 -Y 246 -Width 430 -Height 120 -Title 'Wake Options'
    $startupCheck = New-V2CheckBox -Text 'Also run after startup' -X 20 -Y 36 -Checked $false
    $startupDelayLabel = New-V2Label -Text 'Startup delay' -X 246 -Y 34 -Width 94 -Height 24 -ForeColor $colors.Muted
    $startupDelayCombo = New-V2ComboBox -X 344 -Y 30 -Width 64 -Items @('0', '5', '15', '30', '60') -Selected '5'
    $wakeCheck = New-V2CheckBox -Text 'Wake the computer to run this task' -X 20 -Y 68 -Checked $false
    $missedCheck = New-V2CheckBox -Text 'Run if the task is missed' -X 20 -Y 96 -Checked $true
    $wakeCard.Controls.AddRange([System.Windows.Forms.Control[]]@($startupCheck, $startupDelayLabel, $startupDelayCombo, $wakeCheck, $missedCheck))
    $schedule.Controls.Add($wakeCard)

    $nextCard = New-V2Card -X 445 -Y 246 -Width 425 -Height 120 -Title 'Next Run Summary'
    $nextRunValue = New-V2Label -Text 'Not scheduled' -X 20 -Y 48 -Width 360 -Height 30 -Font $fontTitle -ForeColor $colors.Blue2
    $nextModeValue = New-V2Label -Text 'Schedule disabled' -X 20 -Y 82 -Width 360 -Height 24 -ForeColor $colors.Muted
    $nextCard.Controls.AddRange([System.Windows.Forms.Control[]]@($nextRunValue, $nextModeValue))
    $schedule.Controls.Add($nextCard)
    $saveScheduleButton = New-V2Button -Text 'Save Schedule' -X 625 -Y 392 -Width 220 -Height 40 -BackColor ([System.Drawing.Color]::FromArgb(52, 28, 88)) -BorderColor $colors.Purple
    $schedule.Controls.Add($saveScheduleButton)

    $drivers = $pages['Drivers']
    $auditCard = New-V2Card -X 0 -Y 0 -Width 420 -Height 175 -Title 'Driver Audit'
    $auditCard.Controls.Add((New-V2Label -Text 'Scan your system and create a driver inventory report.' -X 20 -Y 42 -Width 360 -Height 24 -ForeColor $colors.Muted))
    $driverAuditButton = New-V2Button -Text 'Create Audit' -X 20 -Y 82 -Width 150 -Height 36
    $openDriverReportButton = New-V2Button -Text 'Open Report' -X 188 -Y 82 -Width 150 -Height 36 -BackColor ([System.Drawing.Color]::FromArgb(52, 28, 88)) -BorderColor $colors.Purple
    $auditStatus = New-V2Label -Text 'Last audit: Not yet' -X 20 -Y 132 -Width 360 -Height 24 -ForeColor $colors.Muted
    $auditCard.Controls.AddRange([System.Windows.Forms.Control[]]@($driverAuditButton, $openDriverReportButton, $auditStatus))
    $drivers.Controls.Add($auditCard)

    $reportCard = New-V2Card -X 440 -Y 0 -Width 430 -Height 175 -Title 'Latest Report'
    $reportSummary = New-V2Label -Text "Devices scanned: -`r`nDrivers found: -`r`nOutdated drivers: -`r`nUnknown devices: -" -X 20 -Y 48 -Width 260 -Height 92 -ForeColor $colors.Text
    $viewFullReportButton = New-V2Button -Text 'View Full Report' -X 270 -Y 120 -Width 140 -Height 32
    $reportCard.Controls.AddRange([System.Windows.Forms.Control[]]@($reportSummary, $viewFullReportButton))
    $drivers.Controls.Add($reportCard)

    $toolsCard = New-V2Card -X 0 -Y 192 -Width 420 -Height 210 -Title 'PcNinja Tools'
    $toolsCard.Controls.Add((New-V2LinkLabel -Text 'PcNinja Driver Updater' -Url 'https://driver.pcninja.pro' -X 20 -Y 52))
    $toolsCard.Controls.Add((New-V2LinkLabel -Text 'PcNinja Office Installer' -Url 'https://office.pcninja.pro' -X 20 -Y 84))
    $toolsCard.Controls.Add((New-V2LinkLabel -Text 'PcNinja Activation' -Url 'https://active.pcninja.pro' -X 20 -Y 116))
    $toolsCard.Controls.Add((New-V2LinkLabel -Text 'PcNinja Windows Image' -Url 'https://win11.pcninja.pro/' -X 20 -Y 148))
    $toolsCard.Controls.Add((New-V2Label -Text 'PcNinja file password:' -X 236 -Y 52 -Width 164 -Height 24 -ForeColor $colors.Muted))
    $passwordBox = New-V2TextBox -X 236 -Y 82 -Width 150 -Text 'JavierTorres'
    $passwordBox.ReadOnly = $true
    $passwordBox.TextAlign = 'Center'
    $toolsCard.Controls.Add($passwordBox)
    $drivers.Controls.Add($toolsCard)

    $sourcesCard = New-V2Card -X 440 -Y 192 -Width 430 -Height 210 -Title 'Manufacturer Sources (Reference Only)'
    $sourcesCard.Controls.Add((New-V2LinkLabel -Text 'Dell Drivers' -Url 'https://www.dell.com/support/home/en-us?app=drivers' -X 20 -Y 52))
    $sourcesCard.Controls.Add((New-V2LinkLabel -Text 'HP Support' -Url 'https://ftp.ext.hp.com/pub/caps-softpaq/cmit/HPIA.html' -X 20 -Y 84))
    $sourcesCard.Controls.Add((New-V2LinkLabel -Text 'Lenovo Support' -Url 'https://support.lenovo.com/us/en/solutions/ht003029-lenovo-system-update-update-drivers-bios-and-applications' -X 20 -Y 116))
    $sourcesCard.Controls.Add((New-V2LinkLabel -Text 'ASUS Support' -Url 'https://www.asus.com/support/download-center/' -X 20 -Y 148))
    $sourcesCard.Controls.Add((New-V2Label -Text 'Links are reference only. Installation is not performed by this tool.' -X 20 -Y 176 -Width 380 -Height 22 -Font $fontSmall -ForeColor $colors.Muted))
    $drivers.Controls.Add($sourcesCard)

    $logs = $pages['Logs']
    $logsCard = New-V2Card -X 0 -Y 0 -Width 870 -Height 510 -Title 'Application Logs'
    $logsCard.Controls.Add((New-V2Label -Text 'View and analyze tool logs for troubleshooting.' -X 20 -Y 40 -Width 400 -Height 24 -ForeColor $colors.Muted))
    $refreshLogsButton = New-V2Button -Text 'Refresh' -X 20 -Y 72 -Width 110 -Height 30
    $followLogsButton = New-V2Button -Text 'Follow' -X 140 -Y 72 -Width 110 -Height 30
    $bottomLogsButton = New-V2Button -Text 'Bottom' -X 260 -Y 72 -Width 110 -Height 30
    $filterBox = New-V2TextBox -X 610 -Y 72 -Width 230 -Height 28 -Text ''
    $logsCard.Controls.AddRange([System.Windows.Forms.Control[]]@($refreshLogsButton, $followLogsButton, $bottomLogsButton, $filterBox))
    $logBox = New-Object System.Windows.Forms.RichTextBox
    $logBox.ReadOnly = $true
    $logBox.BorderStyle = 'FixedSingle'
    $logBox.BackColor = [System.Drawing.Color]::FromArgb(7, 12, 17)
    $logBox.ForeColor = $colors.Text
    $logBox.Font = $fontMono
    $logBox.Location = New-V2Point 20 112
    $logBox.Size = New-V2Size 820 345
    $logBox.Anchor = 'Top,Bottom,Left,Right'
    $logBox.WordWrap = $false
    $logsCard.Controls.Add($logBox)
    $logFooter = New-V2Label -Text 'Log file: WinUpdateTool.log' -X 20 -Y 466 -Width 600 -Height 24 -Font $fontSmall -ForeColor $colors.Muted
    $logsCard.Controls.Add($logFooter)
    $logs.Controls.Add($logsCard)

    function Refresh-V2Logs {
        try {
            $paths = Initialize-PcnWinUpdateFolders
            if (-not (Test-Path -LiteralPath $paths.LogFile)) {
                $logBox.Text = "No log file yet.`r`n$($paths.LogFile)"
                return
            }

            $lines = Get-Content -LiteralPath $paths.LogFile -Tail 1250 -ErrorAction Stop
            $filter = [string]$filterBox.Text
            if (-not [string]::IsNullOrWhiteSpace($filter)) {
                $lines = $lines | Where-Object { $_ -like "*$filter*" }
            }

            $logBox.Text = ($lines -join "`r`n")
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
            $lastRun = Format-V2Date -Value $state.LastRunStart
            $lastInstall = Format-V2Date -Value $state.LastRunEnd
            $lastScanValue.Text = $lastRun
            $lastInstallValue.Text = $lastInstall

            $pendingReboot = Test-PcnPendingReboot
            if ($pendingReboot) {
                $rebootValue.Text = 'Required'
                $rebootValue.ForeColor = $colors.Orange
                $restartLabel.Text = 'Restart required after the last update operation.'
            }
            else {
                $rebootValue.Text = 'Not required'
                $rebootValue.ForeColor = $colors.Green
                $restartLabel.Text = 'Not required'
            }

            if ([bool]$config.Enabled) {
                $next = Get-PcnScheduledTaskStatus
                if ($next.Installed) {
                    $nextRunText = Format-V2Date -Value $next.NextRunTime
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
            Register-PcnWinUpdateScheduledTask -Config $config -ScriptPath $PSCommandPath
            $footerLabel.Text = 'Schedule saved.'
            Refresh-V2Status
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Schedule Error', 'OK', 'Error') | Out-Null
        }
    }

    function Start-V2RunUpdates {
        param([switch]$Snooz)

        $allow = if ($Snooz) { ' -AllowStopBackgroundActivity' } else { '' }
        $arguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}" -Mode RunUpdates -Silent -RunType Manual{1}' -f $PSCommandPath, $allow
        Start-V2ToolProcess -Arguments $arguments
        $footerLabel.Text = if ($Snooz) { 'Snooz update run started.' } else { 'Windows Update run started.' }
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

        $arguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}" -Mode ResetWindowsUpdate -ConfirmReset' -f $PSCommandPath
        Start-V2ToolProcess -Arguments $arguments
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

    function Invoke-V2UpdatePreview {
        try {
            $footerLabel.Text = 'Scanning Windows Update candidates...'
            $importantCount.Text = '...'
            $optionalCount.Text = '...'
            $driversCount.Text = '...'
            $form.Refresh()

            Enable-PcnMicrosoftUpdate
            Test-PcnNetworkReadiness | Out-Null
            Initialize-PcnWindowsUpdateServices

            $session = New-Object -ComObject Microsoft.Update.Session
            $searcher = $session.CreateUpdateSearcher()
            $result = $searcher.Search('IsInstalled=0 and IsHidden=0')

            $important = 0
            $optional = 0
            $drivers = 0

            for ($index = 0; $index -lt $result.Updates.Count; $index++) {
                $update = $result.Updates.Item($index)
                $typeName = Get-PcnUpdateTypeName -Update $update
                $isDriver = ($typeName -eq 'Driver')
                $isOptional = $false

                try {
                    $isOptional = [bool]$update.BrowseOnly
                }
                catch {
                    $isOptional = $false
                }

                if ($isDriver) {
                    $drivers++
                }
                elseif ($isOptional) {
                    $optional++
                }
                else {
                    $important++
                }
            }

            $importantCount.Text = [string]$important
            $optionalCount.Text = [string]$optional
            $driversCount.Text = [string]$drivers
            $footerLabel.Text = "Scan complete. Important: $important, Optional: $optional, Drivers: $drivers."
            Write-PcnWinUpdateLog -Message "V2 preview scan complete. Important: $important, Optional: $optional, Drivers: $drivers." -EventID 1082
        }
        catch {
            $importantCount.Text = '!'
            $optionalCount.Text = '!'
            $driversCount.Text = '!'
            $footerLabel.Text = "Preview scan failed: $($_.Exception.Message)"
            [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Preview Updates', 'OK', 'Warning') | Out-Null
        }
    }

    function Check-V2ToolUpdateInline {
        try {
            $toolUpdateHeadline.Text = 'Checking...'
            $toolStatusValue.Text = 'Checking'
            $toolStatusValue.ForeColor = $colors.Orange
            $form.Refresh()
            $check = Invoke-PcnAppUpdateCheck -PackageType 'Msi'
            $latest = if ($check.LatestPublicLabel) { [string]$check.LatestPublicLabel } else { [string]$check.LatestVersion }
            $latestValueSide.Text = $latest
            if ($check.Result -eq 'UpdateAvailable') {
                $toolStatusValue.Text = 'Update'
                $toolStatusValue.ForeColor = $colors.Purple
                $toolUpdateHeadline.Text = 'Update available'
                $toolUpdateHeadline.ForeColor = $colors.Purple
            }
            elseif ($check.Result -eq 'UpToDate') {
                $toolStatusValue.Text = 'Up to date'
                $toolStatusValue.ForeColor = $colors.Green
                $toolUpdateHeadline.Text = 'Up to date'
                $toolUpdateHeadline.ForeColor = $colors.Green
            }
            else {
                $toolStatusValue.Text = 'Problem'
                $toolStatusValue.ForeColor = $colors.Orange
                $toolUpdateHeadline.Text = 'Manifest problem'
                $toolUpdateHeadline.ForeColor = $colors.Orange
            }
        }
        catch {
            $latestValueSide.Text = 'Unavailable'
            $toolStatusValue.Text = 'Offline'
            $toolStatusValue.ForeColor = $colors.Orange
            $toolUpdateHeadline.Text = 'Manifest unavailable'
            $toolUpdateHeadline.ForeColor = $colors.Orange
        }
    }

    $sidebarUpdateButton.Add_Click({ Show-V2ToolUpdateDialog -Owner $form; Check-V2ToolUpdateInline })
    $toolUpdateButton.Add_Click({ Show-V2ToolUpdateDialog -Owner $form; Check-V2ToolUpdateInline })
    $settingsButton.Add_Click({ $tabButtons['Schedule'].PerformClick() })
    $helpButton.Add_Click({ Start-Process -FilePath 'https://www.PcNinja.Pro' | Out-Null })
    $quickScanButton.Add_Click({ $tabButtons['Updates'].PerformClick(); Invoke-V2UpdatePreview })
    $quickLogsButton.Add_Click({ $tabButtons['Logs'].PerformClick(); Refresh-V2Logs })
    $quickResetButton.Add_Click({ Start-V2ResetWindowsUpdate })
    $dashRunButton.Add_Click({ Start-V2RunUpdates })
    $dashAuditButton.Add_Click({ Start-V2DriverAudit })
    $dashLogsButton.Add_Click({ $tabButtons['Logs'].PerformClick(); Refresh-V2Logs })
    $dashResetButton.Add_Click({ Start-V2ResetWindowsUpdate })
    $scanButton.Add_Click({ Invoke-V2UpdatePreview })
    $previewButton.Add_Click({ Invoke-V2UpdatePreview })
    $runUpdatesButton.Add_Click({ Start-V2RunUpdates })
    $snoozButton.Add_Click({ Start-V2RunUpdates -Snooz })
    $restartDetailsButton.Add_Click({ [System.Windows.Forms.MessageBox]::Show($restartLabel.Text, 'Restart State', 'OK', 'Information') | Out-Null })
    $saveScheduleButton.Add_Click({ Save-V2Schedule })
    $driverAuditButton.Add_Click({ Start-V2DriverAudit })
    $openDriverReportButton.Add_Click({ Open-V2DriverReports })
    $viewFullReportButton.Add_Click({ Open-V2DriverReports })
    $refreshLogsButton.Add_Click({ Refresh-V2Logs })
    $followLogsButton.Add_Click({ $footerLabel.Text = 'Log follow enabled for this view.' })
    $bottomLogsButton.Add_Click({ $logBox.SelectionStart = $logBox.TextLength; $logBox.ScrollToCaret() })
    $filterBox.Add_TextChanged({ Refresh-V2Logs })

    $form.Add_Shown({
        Load-V2ScheduleConfig
        Refresh-V2Status
        Refresh-V2Logs
        $tabButtons['Dashboard'].PerformClick()
        if ([string]$env:PCNINJA_V2_UI_SMOKE -eq '1') {
            $footerLabel.Text = 'V2 UI smoke test ready.'
            $smokeTimer.Start()
            return
        }

        Check-V2ToolUpdateInline
    })

    [void][System.Windows.Forms.Application]::Run($form)
}
