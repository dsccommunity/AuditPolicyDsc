
$script:DSCModuleName      = 'AuditPolicyDsc'
$script:DSCResourceName    = 'MSFT_AuditPolicySubcategory'

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

# set the Subcategory details being tested
$Subcategory     = 'Credential Validation'


# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $ConfigFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $ConfigFile

    Describe "$($script:DSCResourceName)_Integration" {

        Context 'Should enable failure audit flag' {
            #region DEFAULT TESTS
            
            $AuditFlag       = 'Failure'
            $AuditFlagEnsure = 'Present'

            # set the system Subcategory to the incorrect state to ensure a valid test.
            & 'auditpol' '/set' "/subcategory:$Subcategory" '/failure:disable'
            
            It 'Should compile without throwing' {
                {
                    & "$($script:DSCResourceName)_Config" -Subcategory $Subcategory `
                                                          -AuditFlag $AuditFlag `
                                                          -AuditFlagEnsure $AuditFlagEnsure `
                                                          -OutputPath $TestEnvironment.WorkingFolder
                    Start-DscConfiguration -Path $TestEnvironment.WorkingFolder `
                        -ComputerName localhost -Wait -Verbose -Force
                } | Should not throw
            }

            It 'should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
            }

            #endregion
            
            $currentConfig = Get-DscConfiguration -Verbose -ErrorAction Stop

            It "Subcategory Should be $Subcategory" {
            
                $currentConfig.Subcategory | Should be $Subcategory
            }
            
            It "AuditFlag Should match $AuditFlag" {
            
                $currentConfig.AuditFlag | Should Match $AuditFlag
            }

            It "Ensure Should be $AuditFlagEnsure" {
            
                $currentConfig.Ensure | Should be $AuditFlagEnsure
            }
            
            It 'Should return $true' {
                { Test-DscConfiguration -Path $TestEnvironment.WorkingFolder } | Should Be $true
            }
        }

        Context 'Should disable failure audit flag' {
            #region DEFAULT TESTS
            
            $AuditFlag       = 'Failure'
            $AuditFlagEnsure = 'Absent'

            # set the system Subcategory to the incorrect state to ensure a valid test.
            & 'auditpol' '/set' "/subcategory:$Subcategory" '/failure:enable'
            
            It 'Should compile without throwing' {
                {
                    & "$($script:DSCResourceName)_Config" -Subcategory $Subcategory `
                                                          -AuditFlag $AuditFlag `
                                                          -AuditFlagEnsure $AuditFlagEnsure `
                                                          -OutputPath $TestEnvironment.WorkingFolder
                    Start-DscConfiguration -Path $TestEnvironment.WorkingFolder `
                        -ComputerName localhost -Wait -Verbose -Force
                } | Should not throw
            }

            It 'should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
            }

            #endregion
            
            $currentConfig = Get-DscConfiguration -Verbose -ErrorAction Stop

            It "Subcategory Should be $Subcategory" {
            
                $currentConfig.Subcategory | Should be $Subcategory
            }
            
            It "AuditFlag Should Not match $AuditFlag" {
            
                $currentConfig.AuditFlag | Should Not Match $AuditFlag
            }

            It "Ensure Should be $AuditFlagEnsure" {
            
                $currentConfig.Ensure | Should be $AuditFlagEnsure
            }

            It 'Should return $true' {
                { Test-DscConfiguration -Path $TestEnvironment.WorkingFolder } | Should Be $true
            }
        }

        Context 'Should enable success audit flag' {
            #region DEFAULT TESTS
            
            $AuditFlag       = 'Success'
            $AuditFlagEnsure = 'Present'

            # set the system Subcategory to the incorrect state to ensure a valid test.
            & 'auditpol' '/set' "/subcategory:$Subcategory" '/success:disable'
            
            It 'Should compile without throwing' {
                {
                    & "$($script:DSCResourceName)_Config" -Subcategory $Subcategory `
                                                          -AuditFlag $AuditFlag `
                                                          -AuditFlagEnsure $AuditFlagEnsure `
                                                          -OutputPath $TestEnvironment.WorkingFolder
                    Start-DscConfiguration -Path $TestEnvironment.WorkingFolder `
                        -ComputerName localhost -Wait -Verbose -Force
                } | Should not throw
            }

            It 'should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
            }

            #endregion
            
            $currentConfig = Get-DscConfiguration -Verbose -ErrorAction Stop

            It "Subcategory Should be $Subcategory" {
            
                $currentConfig.Subcategory | Should be $Subcategory
            }
            
            It "AuditFlag Should match $AuditFlag" {
            
                $currentConfig.AuditFlag | Should be $AuditFlag
            }

            It "Ensure Should be $AuditFlagEnsure" {
            
                $currentConfig.Ensure | Should be $AuditFlagEnsure
            }
            
            It 'Should return $true' {
                { Test-DscConfiguration -Path $TestEnvironment.WorkingFolder } | Should Be $true
            }
        }

        Context 'Should disable success audit flag' {
            #region DEFAULT TESTS
            
            $AuditFlag       = 'Success'
            $AuditFlagEnsure = 'Absent'

            # set the system Subcategory to the incorrect state to ensure a valid test.
            & 'auditpol' '/set' "/subcategory:$Subcategory" '/success:enable'
            
            It 'Should compile without throwing' {
                {
                    & "$($script:DSCResourceName)_Config" -Subcategory $Subcategory `
                                                          -AuditFlag $AuditFlag `
                                                          -AuditFlagEnsure $AuditFlagEnsure `
                                                          -OutputPath $TestEnvironment.WorkingFolder
                    Start-DscConfiguration -Path $TestEnvironment.WorkingFolder `
                        -ComputerName localhost -Wait -Verbose -Force
                } | Should not throw
            }

            It 'should be able to call Get-DscConfiguration without throwing' {
                { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
            }

            #endregion
            
            $currentConfig = Get-DscConfiguration -Verbose -ErrorAction Stop

            It "Subcategory Should be $Subcategory" {
            
                $currentConfig.Subcategory | Should be $Subcategory
            }
            
            It "AuditFlag Should Not match $AuditFlag" {
            
                $currentConfig.AuditFlag | Should Not Match $AuditFlag
            }

            It "Ensure Should be $AuditFlagEnsure" {
            
                $currentConfig.Ensure | Should be $AuditFlagEnsure
            }

            It 'Should return $true' {
                { Test-DscConfiguration -Path $TestEnvironment.WorkingFolder } | Should Be $true
            }
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
