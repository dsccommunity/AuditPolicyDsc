
$script:DSCModuleName      = 'AuditPolicyDsc'
$script:DSCResourceName    = 'MSFT_AuditPolicyCsv'

#region HEADER
# Integration Test Template Version: 1.1.1
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile 

    Describe "$($script:DSCResourceName)_Integration" {
        
        Context 'Should set policy without force flag' {

            $force = $false
            #region DEFAULT TESTS

            <# 
                Since the tests read in CSV files, they are stored in a subfolder for the user and
                system context to both access.
            #>           
            $CsvPath = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath 'BackupCsv') `
                                 -ChildPath 'audit.csv'

            It 'Should compile and apply the MOF without throwing' {
                {
                    & "$($script:DSCResourceName)_Config" -CsvPath $CsvPath `
                                                          -Force $force `
                                                          -OutputPath $TestEnvironment.WorkingFolder
                    
                    Start-DscConfiguration -Path $TestEnvironment.WorkingFolder `
                        -ComputerName localhost -Wait -Verbose -Force
                } | Should not throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                { $script:currentConfig = Get-DscConfiguration -Verbose -ErrorAction Stop } | 
                    Should Not throw
            }

            #endregion
        }
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
