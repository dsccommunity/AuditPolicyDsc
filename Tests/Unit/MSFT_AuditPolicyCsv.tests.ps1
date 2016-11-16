
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

# Begin Testing
try
{
    #region Pester Tests

    InModuleScope $script:DSCResourceName {

        $testParameters = @{
            CSVPath  = 'C:\projects\testBackup.csv'
        }

        # Create the auditpol backup file to use in testing. 
        @(@("Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting,Setting Value")
        @(",System,IPsec Driver,{0CCE9213-69AE-11D9-BED3-505054503030},Failure,,2")
        @(",System,System Integrity,{0CCE9212-69AE-11D9-BED3-505054503030},Success,,1")
        @(",System,Security System Extension,{0CCE9211-69AE-11D9-BED3-505054503030},No Auditing,,0")
        @(",,Option:CrashOnAuditFail,,Disabled,,0")
        @(",,RegistryGlobalSacl,,,,")) | Out-File $testParameters.CSVPath -Encoding utf8 -Force

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            $tempCsv = ([system.IO.Path]::GetTempFileName()).Replace('.tmp','.csv')

            Mock -CommandName Invoke-SecurityCmdlet -MockWith { return $tempCsv } `
                 -ModuleName MSFT_AuditPolicyCsv -Verifiable
                    
            It 'Should not throw an exception' {
                { $script:getTargetResourceResult = Get-TargetResource @testParameters } | 
                    Should Not Throw
            }

            It 'Should return the correct hashtable property' {
                $script:getTargetResourceResult.CSVPath | Should Be $tempCsv
            }

            It 'Should call expected Mocks' {    
                Assert-VerifiableMocks
                Assert-MockCalled -CommandName Invoke-SecurityCmdlet -Exactly 1
            } 
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {

            Mock -CommandName Invoke-SecurityCmdlet -MockWith { param($Action, $Path)}

            Context 'CSVs are different' {

                It 'Should not throw an exception' {
                    { $script:testTargetResourceResult = Test-TargetResource @testParameters } | 
                        Should Not Throw
                }            

                It 'Should return false' {
                    $script:testTargetResourceResult | Should Be $false
                }
            }

            Context 'CSVs are the same' {
                
                It 'Should not throw an exception' {
                    { $script:testTargetResourceResult = Test-TargetResource @testParameters } | 
                        Should Not Throw
                }            

                It 'Should return true' {
                    $script:testTargetResourceResult | Should Be $true
                }
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
                Remove-BackupFile | Should BeNullOrEmpty
                Assert-MockCalled Remove-Item -Times 1 -Scope It
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
