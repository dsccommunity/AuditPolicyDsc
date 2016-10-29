
$Global:DSCModuleName      = 'AuditPolicyDsc'
$Global:DSCResourceName    = 'MSFT_AuditPolicyOption'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
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
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

# Begin Testing
try
{
    #region Pester Tests

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $Global:DSCResourceName {

        #region Pester Test Initialization
        # set the audit option test strings to Mock
        $optionName  = 'CrashOnAuditFail'
        $optionState = 'Disabled'
        $optionStateSwap = @{'Disabled'='Enabled';'Enabled'='Disabled'}
        #endregion

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {

            # mock call to the helper module to isolate Get-TargetResource
            Mock Get-AuditOption { return $optionState } -ModuleName MSFT_AuditPolicyOption

            $get = Get-TargetResource -Name $optionName

            It "Return object is a hashtable" {
                $isHashtable = $get.GetType().Name -eq 'hashtable'
                $isHashtable | Should Be $true
            }

            It " that has a 'Name' key" {
                $containsNameKey = $get.ContainsKey('Name')
                $containsNameKey | Should Be $true
            }
            
            It "  with a value of '$optionName'" {
                $retrievedOptionName = $get.Name 
                $retrievedOptionName | Should Be $optionName
            }

            It " that has a 'Value' key" {
                $containsValueKey = $get.ContainsKey('Value')
                $containsValueKey | Should Be $true
            }
            
            It "  with a value of '$optionState'" {
                $get.Value | Should Be $optionState
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            
            # mock call to the helper module to isolate Test-TargetResource
            Mock Get-AuditOption { return $optionState } -ModuleName MSFT_AuditPolicyOption

            $test = Test-TargetResource -Name $optionName -Value $optionState

            It "Return object is a Boolean" {
                $isBool = $test.GetType().Name -eq "Boolean"
                $isBool | Should Be $true
            }

            It " that is true when matching" {
                $valueMatches = $test
                $valueMatches | Should Be $true
            }

            It " and is false when not matching" {
                $valueNotMatches = Test-TargetResource -Name $optionName -Value $optionStateSwap[$optionState]
                $valueNotMatches | Should Be $false
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {

            # mock call to the helper module to isolate Set-TargetResource
            Mock Set-AuditOption { return } -ModuleName MSFT_AuditPolicyOption
                
            $set = Set-TargetResource -Name $optionName -Value $optionState

            It " returns no object" {
                
                $set | Should BeNullOrEmpty
            } 
        }
        #endregion

        #region Helper Cmdlets
        Describe 'Private function Get-AuditOption' { 

            $command = Get-Command Get-AuditOption
            $parameter = 'Name'
                
            It "Should Exist" {

                $command | Should Be $command 
            }

            It 'With output type set to "String"' {

                $command.OutputType | Should Be 'System.String'
            }

            It "Has a parameter '$parameter'" {

                $command.Parameters[$parameter].Name | Should Be $parameter
            }

            It 'Of type "String"' {

                $command.Parameters[$parameter].ParameterType | Should Be 'String'
            }

            Context 'Get-AuditOption with Mock Invoke-Auditpol' {

                [string] $name  = 'CrashOnAuditFail'
                [string] $value = 'Enabled'

                Mock Invoke-Auditpol { "$env:COMPUTERNAME,,Option:$name,,$value,," }

                $auditOption = Get-AuditOption -Name $name

                It "The option $name returns $value" {

                    $auditOption | should Be $value
                }
            }
        }

        Describe 'Private function Set-AuditOption' { 

            $command = Get-Command Set-AuditOption
            $parameter = 'Name'
                
            It "Should Exist" {

                $command | Should Be $command 
            }

            It "With no output" {

                $command.OutputType | Should BeNullOrEmpty
            }

            It "Has a parameter '$parameter'" {

                $command.Parameters[$parameter].Name | Should Be $parameter
            }

            It 'Of type "String"' {

                $command.Parameters[$parameter].ParameterType | Should Be 'String'
            }

            Context "Set-AuditOption with Mock Invoke-Auditpol" {

                [string] $name  = "CrashOnAuditFail"
                [string] $value = "Disabled"

                Mock Invoke-Auditpol { }

                It "Does not thrown an error" {
                        
                    { $setAuditOption =  Set-AuditOption -Name $name -Value $value } |
                    Should Not Throw
                }    

                It "Should not return a value"  {

                    $setAuditOption | Should BeNullOrEmpty
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
