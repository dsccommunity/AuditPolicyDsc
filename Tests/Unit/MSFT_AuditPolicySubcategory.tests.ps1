
$script:DSCModuleName      = 'AuditPolicyDsc'
$script:DSCResourceName    = 'MSFT_AuditPolicySubcategory'

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

    # The InModuleScope command allows you to perform white-box unit testing on the internal
    # (non-exported) code of a Script Module.
    InModuleScope $script:DSCResourceName {

        #region Pester Test Initialization
        # the audit option to use in the tests


        #endregion

        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {
            
            $target = @{
                Subcategory = $null
                AuditFlag   = $null
            }

            $target.Subcategory = 'Logon'
            $target.AuditFlag   = 'Success'

            Context "Single word subcategory submit 'Success' and return 'Success'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'Success' } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'Success'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
                }
            }

            Context "Single word subcategory submit 'Success' and return 'Failure'" {
                
                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'Failure' } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Single word subcategory should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'Failure'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Absent'
                }
            }

            Context "Single word subcategory submit 'Success' and return 'NoAuditing'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'NoAuditing' } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'NoAuditing'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Absent'
                }
            }

            Context "Single word subcategory submit 'Success' and return 'SuccessandFailure'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                   return 'SuccessandFailure' } -ModuleName MSFT_AuditPolicySubcategory
            
                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'SuccessandFailure'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
                }
            }

            $target.AuditFlag = 'Failure'

            Context "Single word subcategory submit 'Failure' and return 'Success'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'Success' } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'Success'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Absent'
                }
            }

            Context "Single word subcategory submit 'Failure' and return 'Failure'" {
                
                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'Failure' } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Single word subcategory should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'Failure'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
                }
            }

            Context "Single word subcategory submit 'Failure' and return 'NoAuditing'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'NoAuditing' } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'NoAuditing'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Absent'
                }
            }

            Context "Single word subcategory submit 'Failure' and return 'SuccessandFailure'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                   return 'SuccessandFailure' } -ModuleName MSFT_AuditPolicySubcategory
            
                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'SuccessandFailure'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
                }
            }

            $target.Subcategory = 'Credential Validation'
            $target.AuditFlag   = 'Success'

            Context "Mulit-word subcategory submit 'Success' and return 'Success'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                    return $'Success' } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'Success'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
                }
            }

            Context "Mulit-word subcategory submit 'Success' and return 'Failure'" {
                
                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'Failure' } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'Failure'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Absent'
                }
            }

            Context "Mulit-word subcategory submit 'Success' and return 'NoAuditing'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'NoAuditing' } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'NoAuditing'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Absent'
                }
            }

            Context "Mulit-word subcategory submit 'Success' and return 'SuccessandFailure'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                   return 'SuccessandFailure' } -ModuleName MSFT_AuditPolicySubcategory
            
                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'SuccessandFailure'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
                }
            }

            $target.AuditFlag = 'Failure'

            Context "Mulit-word subcategory submit 'Failure' and return 'Success'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'Success' } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'Success'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Absent'
                }
            }

            Context "Mulit-word subcategory submit 'Failure' and return 'Failure'" {
                
                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'Failure' } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Single word subcategory should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'Failure'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
                }
            }

            Context "Mulit-word subcategory submit 'Failure' and return 'NoAuditing'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'NoAuditing' } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'NoAuditing'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Absent'
                }
            }

            Context "Mulit-word subcategory submit 'Failure' and return 'SuccessandFailure'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                   return 'SuccessandFailure' } -ModuleName MSFT_AuditPolicySubcategory
            
                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be 'SuccessandFailure'
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            
            $target = @{
                Subcategory = 'Logon'
                AuditFlag   = 'Success'
                Ensure      = 'Present'
            }    

            Context 'Single word subcategory Success flag present and should be' {
                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'Success' } -ModuleName MSFT_AuditPolicySubcategory -Verifiable

                It 'Should not throw an exception' {
                    { $script:testTargetResourceResult = Test-TargetResource @target } |
                        Should Not Throw
                }

                It "Should return true" {
                    $script:testTargetResourceResult | Should Be $true
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-AuditCategory -Exactly 1
                } 
            }

            Context 'Single word subcategory Success flag present and should not be' {
                
                $target.Ensure = 'Absent'
                Mock -CommandName Get-AuditCategory -MockWith { 
                    return 'Success' } -ModuleName MSFT_AuditPolicySubcategory 

                It 'Should not throw an exception' {
                    { $script:testTargetResourceResult = Test-TargetResource @target } | Should Not Throw
                }

                It "Should return false" {
                    $script:testTargetResourceResult | Should Be $false
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Get-AuditCategory -Exactly 1
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            
            $target = @{
                Subcategory = 'Logon'
                AuditFlag   = 'Success'
            }  

            Context 'Set single word subcategory success flag to present' {

                Mock -CommandName Set-AuditCategory -MockWith { } -Verifiable

                It 'Should not throw an exception' {
                    { Set-TargetResource @target } | Should Not Throw
                }   

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Set-AuditCategory -Exactly 1
                } 
            }

            Context 'Set single word subcategory failure flag to present' {
                
                $target.AuditFlag = 'Failure'
                Mock -CommandName Set-AuditCategory -MockWith { } -Verifiable

                It 'Should not throw an exception' {
                    { Set-TargetResource @target } | Should Not Throw
                }   

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Set-AuditCategory -Exactly 1
                } 
            }

            Context 'Set multi-word subcategory success flag to present' {
                $target.Subcategory = 'Credential Validation'
                $target.AuditFlag   = 'Success'
                Mock -CommandName Set-AuditCategory -MockWith { } -Verifiable

                It 'Should not throw an exception' {
                    { Set-TargetResource @target } | Should Not Throw
                }   

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Set-AuditCategory -Exactly 1
                } 
            }

            Context 'Set multi-word subcategory failure flag to present' {
                
                $target.AuditFlag = 'Failure'
                Mock -CommandName Set-AuditCategory -MockWith { } -Verifiable

                It 'Should not throw an exception' {
                    { Set-TargetResource @target } | Should Not Throw
                }   

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Set-AuditCategory -Exactly 1
                } 
            }
        }
        #endregion

        #region Helper Cmdlets
        Describe 'Private function Get-AuditCategory'  {
            
            [String] $subCategory = 'Logon'
            
            Context 'Get single word audit category success flag' {
    
                [String] $auditFlag   = 'Success'
                # the return is 3 lines Header, blank line, data
                # ComputerName,System,Subcategory,GUID,AuditFlags
                 Mock -CommandName Invoke-Auditpol -MockWith { 
                     @("","","$env:ComputerName,system,$subCategory,[GUID],$auditFlag") } `
                     -ParameterFilter { $Command -eq 'Get' } -Verifiable

                It 'Should not throw an exception' {
                    { $script:getAuditCategoryResult = Get-AuditCategory -SubCategory $subCategory } | 
                        Should Not Throw
                } 
                
                It "with the value '$auditFlag'" {
                    $script:getAuditCategoryResult | Should Be $auditFlag
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Invoke-Auditpol -Exactly 1
                } 
            }

            Context 'Get single word audit category failure flag' {

                [String] $auditFlag   = 'failure'
                # the return is 3 lines Header, blank line, data
                # ComputerName,System,Subcategory,GUID,AuditFlags
                 Mock -CommandName Invoke-Auditpol -MockWith { 
                     @("","","$env:ComputerName,system,$subCategory,[GUID],$auditFlag") } `
                     -ParameterFilter { $Command -eq 'Get' } -Verifiable

                It 'Should not throw an exception' {
                    { $script:getAuditCategoryResult = Get-AuditCategory -SubCategory $subCategory } | 
                        Should Not Throw
                } 
                
                It "with the value '$auditFlag'" {
                    $script:getAuditCategoryResult | Should Be $auditFlag
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Invoke-Auditpol -Exactly 1
                } 
            }

            [String] $subCategory = 'Credential Validation'

            Context 'Get single word audit category success flag' {

                [String] $auditFlag   = 'Success'
                # the return is 3 lines Header, blank line, data
                # ComputerName,System,Subcategory,GUID,AuditFlags
                 Mock -CommandName Invoke-Auditpol -MockWith { 
                     @("","","$env:ComputerName,system,$subCategory,[GUID],$auditFlag") } `
                     -ParameterFilter { $Command -eq 'Get' } -Verifiable

                It 'Should not throw an exception' {
                    { $script:getAuditCategoryResult = Get-AuditCategory -SubCategory $subCategory } | 
                        Should Not Throw
                } 
                
                It "with the value '$auditFlag'" {
                    $script:getAuditCategoryResult | Should Be $auditFlag
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Invoke-Auditpol -Exactly 1
                } 
            }

            Context 'Get single word audit category failure flag' {

                [String] $auditFlag   = 'failure'
                # the return is 3 lines Header, blank line, data
                # ComputerName,System,Subcategory,GUID,AuditFlags
                 Mock -CommandName Invoke-Auditpol -MockWith { 
                     @("","","$env:ComputerName,system,$subCategory,[GUID],$auditFlag") } `
                     -ParameterFilter { $Command -eq 'Get' } -Verifiable

                It 'Should not throw an exception' {
                    { $script:getAuditCategoryResult = Get-AuditCategory -SubCategory $subCategory } | 
                        Should Not Throw
                } 
                
                It "with the value '$auditFlag'" {
                    $script:getAuditCategoryResult | Should Be $auditFlag
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Invoke-Auditpol -Exactly 1
                } 
            }
        }

        Describe 'Private function Set-AuditCategory' {

            Context 'Set single word audit category Success flag to Present' {
                
                Mock -CommandName Invoke-Auditpol -MockWith { } -ParameterFilter {
                    $Command -eq 'Set' } -Verifiable
                    
                $comamnd = @{
                    SubCategory = "Logon"
                    AuditFlag = "Success"
                    Ensure = "Present"
                }

                It 'Should not throw an error' {
                    { Set-AuditCategory @comamnd } | Should Not Throw 
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Invoke-Auditpol -Exactly 1
                } 
            }

            Context 'Set single word audit category Success flag to Absent' {
                
                Mock -CommandName Invoke-Auditpol -MockWith { } -ParameterFilter {
                    $Command -eq 'Set' } -Verifiable
                    
                $comamnd = @{
                    SubCategory = "Logon"
                    AuditFlag = "Success"
                    Ensure = "Absent"
                }

                It 'Should not throw an exception' {
                    { Set-AuditCategory @comamnd } | Should Not Throw 
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Invoke-Auditpol -Exactly 1
                } 
            }

            Context 'Set multi-word audit category Success flag to Present' {
                
                Mock -CommandName Invoke-Auditpol -MockWith { } -ParameterFilter {
                    $Command -eq 'Set' } -Verifiable
                    
                $comamnd = @{
                    SubCategory = "Object Access"
                    AuditFlag = "Success"
                    Ensure = "Present"
                }

                It 'Should not throw an exception' {
                    { Set-AuditCategory @comamnd } | Should Not Throw 
                }

                It 'Should call expected Mocks' {    
                    Assert-VerifiableMocks
                    Assert-MockCalled -CommandName Invoke-Auditpol -Exactly 1
                } 
            }

            Context 'Set multi-word audit category Success flag to Absent' {
                
                Mock -CommandName Invoke-Auditpol -MockWith { } -ParameterFilter {
                    $Command -eq 'Set' } -Verifiable
                    
                $comamnd = @{
                    SubCategory = "Object Access"
                    AuditFlag = "Success"
                    Ensure = "Absent"
                }

                It 'Should not throw an exception' {
                    { Set-AuditCategory @comamnd } | Should Not Throw 
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
