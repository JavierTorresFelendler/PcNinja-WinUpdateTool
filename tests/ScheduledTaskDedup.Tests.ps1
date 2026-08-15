$modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) 'WinUpdateCore.psm1'
Import-Module $modulePath -Force

Describe 'PcNinja scheduled task replacement' {
    InModuleScope WinUpdateCore {
        It 'removes matching tasks from canonical and legacy task paths' {
            Mock Test-PcnAdministrator { $true }
            Mock Write-PcnWinUpdateLog { }
            Mock Get-ScheduledTask {
                @(
                    [pscustomobject]@{ TaskName = 'PcNinja WinUpdate Tool'; TaskPath = '\PcNinja\' },
                    [pscustomobject]@{ TaskName = 'PcNinja WinUpdate Tool'; TaskPath = '\' },
                    [pscustomobject]@{ TaskName = 'PcNinja WinUpdate Tool V2'; TaskPath = '\Legacy\' },
                    [pscustomobject]@{ TaskName = 'Unrelated Task'; TaskPath = '\' }
                )
            }
            Mock Unregister-ScheduledTask { }

            $result = Unregister-PcnWinUpdateToolTasks

            $result.Warnings.Count | Should Be 0
            $result.Removed.Count | Should Be 3
            Assert-MockCalled Unregister-ScheduledTask -Times 1 -ParameterFilter {
                $TaskName -eq 'PcNinja WinUpdate Tool' -and $TaskPath -eq '\PcNinja\'
            }
            Assert-MockCalled Unregister-ScheduledTask -Times 1 -ParameterFilter {
                $TaskName -eq 'PcNinja WinUpdate Tool' -and $TaskPath -eq '\'
            }
            Assert-MockCalled Unregister-ScheduledTask -Times 1 -ParameterFilter {
                $TaskName -eq 'PcNinja WinUpdate Tool V2' -and $TaskPath -eq '\Legacy\'
            }
        }

        It 'cleans old tasks before registering the canonical task' {
            Mock Test-PcnAdministrator { $true }
            Mock Test-Path { $true }
            Mock New-PcnScheduledTaskXml { '<Task />' }
            Mock Unregister-PcnWinUpdateToolTasks { [pscustomobject]@{ Warnings = @() } }
            Mock Register-ScheduledTask { }
            Mock Write-PcnWinUpdateLog { }

            $config = [pscustomobject]@{
                Frequency = 'Monthly'
                Time = '03:00'
                RunAtStartup = $false
                StartupDelayMinutes = 5
            }

            Register-PcnWinUpdateScheduledTask -Config $config -ScriptPath 'C:\Program Files\PcNinja\WinUpdateTool\WinUpdateTool.ps1'

            Assert-MockCalled Unregister-PcnWinUpdateToolTasks -Times 1
            Assert-MockCalled Register-ScheduledTask -Times 1 -ParameterFilter {
                $TaskName -eq 'PcNinja WinUpdate Tool' -and $TaskPath -eq '\PcNinja\' -and $Force
            }
        }
    }
}
