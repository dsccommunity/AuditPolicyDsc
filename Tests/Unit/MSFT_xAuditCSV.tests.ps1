<#
.Synopsis
   Template for creating DSC Resource Unit Tests
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Unit\ folder and rename MSFT_x<ResourceName>.tests.ps1
     2. Customize TODO sections.

.NOTES
   Code in HEADER and FOOTER regions are standard and may be moved into DSCResource.Tools in
   Future and therefore should not be altered if possible.
#>

$Global:DSCModuleName      = 'xAuditPolicy'
$Global:DSCResourceName    = 'MSFT_xAuditCSV'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\MSFT_xAuditCSV'))) )
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

# the audit option to use in the tests
$Subcategory   = 'logon'
$AuditFlag     = 'Failure'
$MockAuditFlags = 'Success','Failure','SuccessandFailure','NoAuditing'
$AuditFlagSwap = @{'Failure'='Success';'Success'='Failure'}

if (!(Test-Path C:\Temp))
{
     New-Item -ItemType Directory -path "c:\temp\"
}

# Begin Testing
try
{
    #region Pester Tests

    InModuleScope $Global:DSCResourceName {

    [String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
    $TestCSV = Join-Path -Path $moduleRoot -ChildPath "Examples\test.csv"
    $DifferentCSV = Join-Path -Path $moduleRoot -ChildPath "Examples\different.csv"
    $BlankCSV = Join-Path -Path $moduleRoot -ChildPath "Examples\blank.csv"
        #region Get/Set/Test Common
        Describe "$($Global:DSCResourceName)Get/Set/Test-TargetResource Common" {
            
            # mock call to the helper module to isolate Get-TargetResource
            Mock Invoke-SecurityCmdlet { param($Action, $Path)}
            
            Context 'Mandatory parameters' {
                
                <#It 'Set-TargetResource CSVPath is mandatory ' {
                    Set-TargetResource | Should Throw
                }

                It 'Get-TargetResource CSVPath is mandatory ' {
                    Get-TargetResource | Should Throw
                }

                It 'Test-TargetResource CSVPath is mandatory ' {
                    Test-TargetResource | Should Throw
                }#>
            }
        }
        #endregion

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            
            Mock Invoke-SecurityCmdlet { param($Action, $Path)}
            
            Context "Returns properly formatted hashtable " {
               
                $Get = Get-TargetResource -CSVPath $TestCSV -Force $true

                    It " is a hashtable" {
                        $isHashtable = $Get.GetType().Name -eq 'hashtable'

                        $isHashtable | Should Be $true
                    }

                    It "'s keys match the parameters" {
                       $Get.ContainsKey("CSVPath")  | Should Be $true
                       $Get.ContainsKey("Force")  | Should Be $true
                       $Get.ContainsKey("Ensure")  | Should Be $true
                    }
                
                Assert-MockCalled Invoke-SecurityCmdlet -Exactly 1 -Scope Describe
            }

            Context "Ensure works properly" {
               
                It "Ensure='Present' works" {
                    Copy-Item -Path $TestCSV -Destination C:\Temp\test.csv -Force 
                    $Get = Get-TargetResource -CSVPath $TestCSV
                    $Get.Ensure | Should Be "Present"
                    Assert-MockCalled Invoke-SecurityCmdlet -Exactly 1 -Scope It
                }
                
                It "Ensure='Absent' works" {
                    Copy-Item -Path $BlankCSV -Destination C:\Temp\test.csv -Force 
                    $Get = Get-TargetResource -CSVPath $TestCSV
                    $Get.Ensure | Should Be "Absent"
                    Assert-MockCalled Invoke-SecurityCmdlet -Exactly 1 -Scope It
                }
            }

        }
        #endregion


        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {

            # mock call to the helper module to isolate Get-TargetResource
            Mock Invoke-SecurityCmdlet { param($Action, $Path)}
                                 
            It "Returns an Object of type Boolean" {
                Copy-Item -Path $TestCSV -Destination C:\Temp\test.csv -Force 
                $result = Test-TargetResource -CSVPath $TestCSV
                ($result -is [bool]) | Should Be $true
                Assert-MockCalled Invoke-SecurityCmdlet -Exactly 1 -Scope It
            }

            It "Returns False when CSVs are different" {
                Copy-Item -Path $TestCSV -Destination C:\Temp\test.csv -Force 
                (Test-TargetResource -CSVPath $DifferentCSV)  | Should Be $False
                Assert-MockCalled Invoke-SecurityCmdlet -Exactly 1 -Scope It
            }

            It "Returns True when CSVs are the same" {
                Copy-Item -Path $TestCSV -Destination C:\Temp\test.csv -Force 
                (Test-TargetResource -CSVPath $TestCSV)  | Should Be $True
                Assert-MockCalled Invoke-SecurityCmdlet -Exactly 1 -Scope It
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)Set-TargetResource" {
            
            # mock call to the helper module to isolate Get-TargetResource
            Mock Invoke-SecurityCmdlet { param($Action, $Path)}
            
            It 'Calls Invoke-SecurityCmdlet 1 time' {
                Set-TargetResource -CSVPath $TestCSV -Ensure "Present" -Force $false

                Assert-MockCalled Invoke-SecurityCmdlet -Exactly 1 -Scope It
            }
        }
        #endregion

        # Pester Tests for any Helper Cmdlets

    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion

    # TODO: Other Optional Cleanup Code Goes Here...
}
