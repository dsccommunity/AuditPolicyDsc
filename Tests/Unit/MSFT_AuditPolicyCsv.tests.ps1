
$script:DSCModuleName   = 'AuditPolicyDsc'
$script:DSCResourceName = 'MSFT_AuditPolicyCsv'

#region HEADER
[String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $script:MyInvocation.MyCommand.Path))
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

# the audit option to use in the tests
$Subcategory    = 'logon'
$AuditFlag      = 'Failure'
$MockAuditFlags = 'Success','Failure','SuccessandFailure','NoAuditing'
$AuditFlagSwap  = @{'Failure'='Success';'Success'='Failure'}

if (-not (Test-Path C:\Temp))
{
     New-Item -ItemType Directory -path "c:\temp\"
}

# Begin Testing
try
{
    #region Pester Tests

    InModuleScope $script:DSCResourceName {

    [String] $moduleRoot = Split-Path -Parent (
        Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)
    )
    $TestCSV = Join-Path -Path $moduleRoot -ChildPath "Examples\test.csv"
    $DifferentCSV = Join-Path -Path $moduleRoot -ChildPath "Examples\different.csv"
    $BlankCSV = Join-Path -Path $moduleRoot -ChildPath "Examples\blank.csv"

        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            
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

        Describe "$($script:DSCResourceName)\Test-TargetResource" {

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

        Describe "$($script:DSCResourceName)Set-TargetResource" {
            
            # mock call to the helper module to isolate Get-TargetResource
            Mock Invoke-SecurityCmdlet { param($Action, $Path)}
            
            It 'Should call Invoke-SecurityCmdlet 1 time' {
                Set-TargetResource -CSVPath $TestCSV -Ensure "Present" -Force $false

                Assert-MockCalled Invoke-SecurityCmdlet -Exactly 1 -Scope It
            }
        }

        Describe 'Function Invoke-SecurityCmdlet' {
            
            Context 'Seucrity cmdlets are available' {
                Mock Get-Module -ParameterFilter {Name -eq "SecurityCmdlets"} `
                                -MockWith {"SecurityCmdlets"} -Verifiable
                Mock Restore-AuditPolicy -MockWith {}
                
                It 'Should call ' {

                }
            }

            Context 'Seucrity cmdlets are NOT available' {

                Mock Get-Module -ParameterFilter {Name -eq "SecurityCmdlets"} `
                                -MockWith {} -Verifiable
                
                Mock Invoke-AuditPol -MockWith {} -Verifiable

                It 'Should call Invoke-AuditPol' {
                
                }
            }
        }

        Describe 'Function Remove-BackupFile' {

            Mock Remove-Item -MockWith {} -Verifiable

            It 'Should call Remove-Item' {
                {Remove-BackupFile} | Should BeNullOrEmpty
                Assert-MockCalled Remove-Item -Times 1 -Scope It
            }

        }

        Describe 'Function Test-AuditFlagState' {
            
            $force = $false

            Context 'No Auditing with force Flag Set to False' {

                It "Should return true when 'No Auditing' is tested against 'No Auditing'" {
                    Test-AuditFlagState -CurrentSetting 0 -DesiredSetting 0 -Force $force |
                    Should be $true
                }

                It "Should return false when 'Success' is tested against 'No Auditing'" {
                    Test-AuditFlagState -CurrentSetting 0 -DesiredSetting 1 -Force $force |
                    Should be $false
                }

                It "Should return false when 'Failure' is tested against 'No Auditing'" {
                    Test-AuditFlagState -CurrentSetting 0 -DesiredSetting 2 -Force $force |
                    Should be $false
                }

                It "Should return false when 'Success and Failure' is tested against 'No Auditing'" {
                    Test-AuditFlagState -CurrentSetting 0 -DesiredSetting 3 -Force $force |
                    Should be $false
                }
            }

            Context 'Success with force Flag Set to False' {

                It "Should return false when 'No Auditing' is tested against 'Success'" {
                    Test-AuditFlagState -CurrentSetting 1 -DesiredSetting 0 -Force $force |
                    Should be $false
                }
                
                It "Should return true when 'Success' is tested against 'Success'" {
                    Test-AuditFlagState -CurrentSetting 1 -DesiredSetting 1 -Force $force |
                    Should be $true
                }

                It "Should return false when 'Failure' is tested against 'Success'" {
                    Test-AuditFlagState -CurrentSetting 1 -DesiredSetting 2 -Force $force |
                    Should be $false
                }

                It "Should return false when 'Success and Failure' are tested against 'Success'" {
                    Test-AuditFlagState -CurrentSetting 1 -DesiredSetting 3 -Force $force |
                    Should be $false
                }
            }

            Context 'Failure with force Flag Set to False' {

                It "Should return false when 'No Auditing' is tested against 'Failure'" {
                    Test-AuditFlagState -CurrentSetting 2 -DesiredSetting 0 -Force $force |
                    Should be $false
                }
                
                It "Should return false when 'Success' is tested against 'Failure'" {
                    Test-AuditFlagState -CurrentSetting 2 -DesiredSetting 1 -Force $force |
                    Should be $false
                }

                It "Should return true when 'Failure' is tested against 'Failure'" {
                    Test-AuditFlagState -CurrentSetting 2 -DesiredSetting 2 -Force $force |
                    Should be $true
                }

                It "Should return false when 'Success and Failure' are tested against 'Failure'" {
                    Test-AuditFlagState -CurrentSetting 2 -DesiredSetting 3 -Force $force |
                    Should be $false
                }
            }

            Context 'Success and Failure with force Flag Set to False' {

                It "Should return false when 'No Auditing' is tested against 'Success and Failure'" {
                    Test-AuditFlagState -CurrentSetting 3 -DesiredSetting 0 -Force $force |
                    Should be $false
                }
                
                It "Should return true when 'Success' is tested against 'Success and Failure'" {
                    Test-AuditFlagState -CurrentSetting 3 -DesiredSetting 1 -Force $force |
                    Should be $true
                }

                It "Should return true when 'Failure' is tested against 'Success and Failure'" {
                    Test-AuditFlagState -CurrentSetting 3 -DesiredSetting 2 -Force $force |
                    Should be $true
                }

                It "Should return true when 'Success and Failure' are tested against 'Success and Failure'" {
                    Test-AuditFlagState -CurrentSetting 3 -DesiredSetting 3 -Force $force |
                    Should be $true
                }
            }

            $force = $true
            
            Context 'No Auditing with force flag Set to True' {
                $currentSetting = 2

                It "Should return true when 'No Auditing' is tested against 'No Auditing'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 0 -Force $force |
                    Should be $true
                }
                
                It "Should return false when 'Success' is tested against 'No Auditing'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 1 -Force $force |
                    Should be $false
                }

                It "Should return false when 'Failure' is tested against 'No Auditing'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 2 -Force $force |
                    Should be $false
                }

                It "Should return false when 'Success and Failure' are tested against 'No Auditing'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 3 -Force $force |
                    Should be $false
                }             
            }

            Context 'Success with force flag Set to True' {

                $currentSetting = 1

                It "Should return false when 'No Auditing' is tested against 'Success'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 0 -Force $force |
                    Should be $false
                }
                
                It "Should return true when 'Success' is tested against 'Success'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 1 -Force $force |
                    Should be $true
                }

                It "Should return false when 'Failure' is tested against 'Success'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 2 -Force $force |
                    Should be $false
                }

                It "Should return false when 'Success and Failure' are tested against 'Success'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 3 -Force $force |
                    Should be $false
                }             
            }

            Context 'Failure with force Flag Set to True' {

                $currentSetting = 2

                It "Should return false when 'No Auditing' is tested against 'Failure'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 0 -Force $force |
                    Should be $false
                }
                
                It "Should return false when 'Success' is tested against 'Failure'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 1 -Force $force |
                    Should be $false
                }

                It "Should return true when 'Failure' is tested against 'Failure'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 2 -Force $force |
                    Should be $true
                }

                It "Should return false when 'Success and Failure' are tested against 'Failure'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 3 -Force $force |
                    Should be $false
                }             
            }

            Context 'Success and Failure with force Flag Set to True' {
                
                $currentSetting = 3

                It "Should return false when 'No Auditing' is tested against 'Success and Failure'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 0 -Force $force |
                    Should be $false
                }
                
                It "Should return false when 'Success' is tested against 'Success and Failure'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 1 -Force $force |
                    Should be $false
                }

                It "Should return false when 'Failure' is tested against 'Success and Failure'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 2 -Force $force |
                    Should be $false
                }

                It "Should return true when 'Success and Failure' are tested against 'Success and Failure'" {
                    Test-AuditFlagState -CurrentSetting $currentSetting `
                                        -DesiredSetting 3 -Force $force |
                    Should be $true
                }
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
