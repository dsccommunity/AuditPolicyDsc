
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
            CSVPath  = 'C:\temp\backup.csv'
        }

        $TestCSV = Join-Path -Path $moduleRoot -ChildPath "Examples\test.csv"
        $DifferentCSV = Join-Path -Path $moduleRoot -ChildPath "Examples\different.csv"

        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            Mock -CommandName Invoke-SecurityCmdlet -MockWith { 
                return $testParameters.CsvPath } -ModuleName MSFT_AuditPolicyCsv -Verifiable
                    
            It 'Should not throw an exception' {
                { $script:getTargetResourceResult = Get-TargetResource @testParameters } | 
                    Should Not Throw
            }

            It 'Should return the correct hashtable property' {
                $script:getTargetResourceResult.CSVPath | Should match ".csv"
            }

            It 'Should call expected Mocks' {    
                Assert-VerifiableMocks
                Assert-MockCalled -CommandName Invoke-SecurityCmdlet -Exactly 1
            } 
        }

        Describe "$($script:DSCResourceName)\Test-TargetResource" {

            # mock call to the helper module to isolate Get-TargetResource
            Mock Invoke-SecurityCmdlet { param($Action, $Path)}
                                 
            It "Returns an Object of type Boolean" {
                Copy-Item -Path $TestCSV -Destination C:\Temp\test.csv -Force 
                $result = Test-TargetResource -CSVPath $TestCSV
                ($result -is [bool]) | Should Be $true
            }

            It "Returns False when CSVs are different" {
                Copy-Item -Path $TestCSV -Destination C:\Temp\test.csv -Force 
                (Test-TargetResource -CSVPath $DifferentCSV) | Should Be $False
            }

            It "Returns True when CSVs are the same" {
                Copy-Item -Path $TestCSV -Destination C:\Temp\test.csv -Force 
                (Test-TargetResource -CSVPath $TestCSV) | Should Be $True
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
