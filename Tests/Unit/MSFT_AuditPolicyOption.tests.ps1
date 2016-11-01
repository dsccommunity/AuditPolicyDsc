
$script:DSCModuleName      = 'AuditPolicyDsc'
$script:DSCResourceName    = 'MSFT_AuditPolicyOption'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit 
#endregion

# Begin Testing
try
{
    #region Pester Tests

    InModuleScope $script:DSCResourceName {

        #region Pester Test Initialization

        # set the audit option test strings to Mock
        $optionName  = 'CrashOnAuditFail'
        $optionState = 'Disabled'
        
        #endregion

        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            context 'Option Enabled' {

                $optionState = 'Enabled'
                Mock -CommandName Get-AuditOption -MockWith { return $optionState } -ModuleName MSFT_AuditPolicyOption
                $getTargetResourceResult = Get-TargetResource -Name $optionName

                It 'Should return the correct hashtable properties' {
                    $getTargetResourceResult.Name  | Should Be $optionName
                    $getTargetResourceResult.Value | Should Be $optionState
                }
            }

            context 'Option Disabled' {

                $optionState = 'Disabled'
                Mock -CommandName Get-AuditOption -MockWith { return $optionState } -ModuleName MSFT_AuditPolicyOption
                $getTargetResourceResult = Get-TargetResource -Name $optionName

                It 'Should return the correct hashtable properties' {
                    $getTargetResourceResult.Name  | Should Be $optionName
                    $getTargetResourceResult.Value | Should Be $optionState
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {

            $optionStateSwap = @{
                'Disabled' = 'Enabled';
                'Enabled'  = 'Disabled'
            }

            Context 'Option enabled' {

                $optionState = 'Enabled'
                Mock -CommandName Get-AuditOption -MockWith { return $optionState } -ModuleName MSFT_AuditPolicyOption

                It "Should be true when testing for enabled" {
                    $testTargetResourceResult = Test-TargetResource -Name $optionName -Value $optionState
                    $testTargetResourceResult | Should Be $true
                }

                It "Should be false when testing for disabled" {
                    $testTargetResourceResult = Test-TargetResource -Name $optionName -Value $optionStateSwap[$optionState]
                    $testTargetResourceResult | Should Be $false
                }
            }

            Context 'Option disabled' {

                $optionState = 'Disabled'
                Mock -CommandName Get-AuditOption -MockWith { return $optionState } -ModuleName MSFT_AuditPolicyOption

                It "Should be true when disabled and test for disabled" {
                    $testTargetResourceResult = Test-TargetResource -Name $optionName -Value $optionState
                    $testTargetResourceResult | Should Be $true
                }

                It "Should be false when disabled and test for enabled" {
                    $testTargetResourceResult = Test-TargetResource -Name $optionName -Value $optionStateSwap[$optionState]
                    $testTargetResourceResult | Should Be $false
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {

            # mock call to the helper module to isolate Set-TargetResource
            Mock -CommandName Set-AuditOption -MockWith { } -ModuleName MSFT_AuditPolicyOption -Verifiable
                
            $setTargetResourceResult = Set-TargetResource -Name $optionName -Value $optionState

            It 'Should call expected Mocks' {    
                Assert-VerifiableMocks
                Assert-MockCalled -CommandName Set-AuditOption -Exactly 1
            } 
        }
        #endregion

        #region Helper Cmdlets
        Describe 'Private function Get-AuditOption' { 

            Context 'Get-AuditOption with Mock Invoke-Auditpol' {

                [string] $name  = 'CrashOnAuditFail'
                [string] $value = 'Enabled'
                # the return is 3 lines Header, blank line, data
                # ComputerName,System,Subcategory,GUID,AuditFlags
                Mock -CommandName Invoke-Auditpol -MockWith { 
                    @("","","$env:COMPUTERNAME,,Option:$name,,$value,,") 
                }

                $auditOption = Get-AuditOption -Name $name

                It "Should return the correct value" {
                    $auditOption | should Be $value
                }
            }
        }

        Describe 'Private function Set-AuditOption' { 

            Context "Set-AuditOption to enabled" {

                [string] $name  = "CrashOnAuditFail"
                [string] $value = "Enabled"

                Mock -CommandName Invoke-Auditpol -MockWith { } -Verifiable

                It 'Should not throw an exception' {
                    { Set-AuditOption -Name $name -Value $value } | Should Not Throw
                }   

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Invoke-Auditpol -Exactly 1
                } 
            }

            Context "Set-AuditOption to disabled" {

                [string] $name  = "CrashOnAuditFail"
                [string] $value = "Disabled"

                Mock -CommandName Invoke-Auditpol -MockWith { } -Verifiable

                It 'Should not throw an exception' {
                    { Set-AuditOption -Name $name -Value $value } | Should Not Throw
                }   

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Invoke-Auditpol -Exactly 1
                } 
            }
        }
        #endregion
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
