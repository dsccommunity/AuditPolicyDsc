
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

        $script:currentAuditpolicyCsv = ([system.IO.Path]::GetTempFileName()).Replace('.tmp','.csv')
        $script:desiredAuditpolicyCsv = ([system.IO.Path]::GetTempFileName()).Replace('.tmp','.csv')

        $script:testParameters = @{
            CSVPath  = $script:currentAuditpolicyCsv
        }

        # Create the auditpol backup file to use in testing. 
        @(@("Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting,Setting Value")
        @(",System,IPsec Driver,{0CCE9213-69AE-11D9-BED3-505054503030},Failure,,2")
        @(",System,System Integrity,{0CCE9212-69AE-11D9-BED3-505054503030},Success,,1")
        @(",System,Security System Extension,{0CCE9211-69AE-11D9-BED3-505054503030},No Auditing,,0")
        @(",,Option:CrashOnAuditFail,,Disabled,,0")
        @(",,RegistryGlobalSacl,,,,")) | Out-File $script:currentAuditpolicyCsv -Encoding utf8 -Force

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Mock -CommandName Invoke-SecurityCmdlet -MockWith { } -Verifiable
                    
            It 'Should not throw an exception' {
                { $script:getTargetResourceResult = Get-TargetResource @testParameters } | 
                    Should Not Throw
            }

            It 'Should return the correct hashtable property' {
                $script:getTargetResourceResult.CSVPath | Should Not Be $script:testParameters.CSVPath
            }

            It 'Should call expected Mocks' {    
                Assert-VerifiableMocks
                Assert-MockCalled -CommandName Invoke-SecurityCmdlet -Exactly 1
            } 
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            
            $script:testParameters.CSVPath  = $script:desiredAuditpolicyCsv

            # Create the auditpol desired state backup file testing. 
            @(@("Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting,Setting Value")
            @(",System,IPsec Driver,{0CCE9213-69AE-11D9-BED3-505054503030},Success,,1")
            @(",System,System Integrity,{0CCE9212-69AE-11D9-BED3-505054503030},Failure,,2")
            @(",System,Security System Extension,{0CCE9211-69AE-11D9-BED3-505054503030},No Auditing,,0")
            @(",,Option:CrashOnAuditFail,,Enabled,,1")
            @(",,RegistryGlobalSacl,,,,")) | Out-File $script:desiredAuditpolicyCsv -Encoding utf8 -Force
            
            Mock -CommandName Invoke-SecurityCmdlet -MockWith { }

            Context 'CSVs are different' {
               
                Mock -CommandName Get-TargetResource -MockWith { $script:currentAuditpolicyCsv }

                It 'Should not throw an exception' {
                    { $script:testTargetResourceResult = Test-TargetResource @testParameters } | 
                        Should Not Throw
                }            

                It 'Should return false' {
                    $script:testTargetResourceResult | Should Be $false
                }
            }

            Context 'CSVs are the same' {
                Mock -CommandName Get-TargetResource -MockWith { $script:desiredAuditpolicyCsv }

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
            
            $script:testParameters.CSVPath  = $script:desiredAuditpolicyCsv

            Mock -CommandName Invoke-SecurityCmdlet { }
            
            It 'Should call Invoke-SecurityCmdlet 1 time' {
                Set-TargetResource @testParameters
                Assert-MockCalled Invoke-SecurityCmdlet -Exactly 1 -Scope It
            }
        }

        Describe 'Function Invoke-SecurityCmdlet' {
            
            # Create function to mock since security cmdlets are not in appveyor yet 
            function Restore-AuditPolicy
            {

            }

            Context 'Seucrity cmdlets are available' {

                Mock -CommandName Get-Module -ParameterFilter {Name -eq "SecurityCmdlets"} `
                     -MockWith {"SecurityCmdlets"} -Verifiable

                Mock -CommandName Restore-AuditPolicy -MockWith {}
                
                It 'Should call Restore-AuditPolicy' {

                }
            }

            Context 'Backup when seucrity cmdlets are NOT available' {

                Mock -CommandName Get-Module -ParameterFilter {Name -eq "SecurityCmdlets"} `
                     -MockWith {} -Verifiable
                
                Mock -CommandName Invoke-AuditPol -ParameterFilter {Command -eq "Backup"} `
                     -MockWith { } -Verifiable

                It 'Should call Invoke-AuditPol backup' {
                    Invoke-SecurityCmdlet -Action 'Export' -Path $script:desiredAuditpolicyCsv 
                    Assert-VerifiableMocks -Exactly 1 -Scope It
                }
            }

            Context 'Restore when seucrity cmdlets are NOT available' {

                Mock -CommandName Get-Module -ParameterFilter {Name -eq "SecurityCmdlets"} `
                     -MockWith {} -Verifiable
                
                Mock -CommandName Invoke-AuditPol -ParameterFilter {Command -eq "Restore"} `
                     -MockWith { } -Verifiable

                It 'Should call Invoke-AuditPol restore' {
                    Invoke-SecurityCmdlet -Action 'Import' -Path $script:desiredAuditpolicyCsv 
                    Assert-VerifiableMocks -Exactly 1 -Scope It
                }
            }
        }

        Describe 'Function Remove-BackupFile' {

            $script:testParameters.CSVPath  = $script:currentAuditpolicyCsv

            Mock -CommandName Remove-Item -ParameterFilter {Path -eq "$script:currentAuditpolicyCsv"} `
                -MockWith { } -Verifiable

            It 'Should call Remove-Item to clean up temp file' {
                Remove-BackupFile @testParameters | Should BeNullOrEmpty
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
