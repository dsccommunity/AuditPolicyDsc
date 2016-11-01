
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
        $script:target = @{
            Subcategory   = $null
        }

        #endregion

        #region Function Get-TargetResource
        Describe "$($script:DSCResourceName)\Get-TargetResource" {

            $script:target.Subcategory = 'Logon'

            Context "Single word subcategory submit 'Success' and return 'Success'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                    return $AuditFlag } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
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
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
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
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
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
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
                }
            }

            $script:target.AuditFlag = 'Failure'

            Context "Single word subcategory submit 'Failure' and return 'Success'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                    return $AuditFlag } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
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
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
                    $script:getTargetResourceResult.Ensure      | Should Be 'Absent'
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
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
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
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
                }
            }


            $script:target.Subcategory = 'Credential Validation'
            $script:target.AuditFlag = 'Success'

            Context "Mulit-word subcategory submit 'Success' and return 'Success'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                    return $AuditFlag } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
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
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
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
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
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
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
                }
            }

            $script:target.AuditFlag = 'Failure'

            Context "Mulit-word subcategory submit 'Failure' and return 'Success'" {

                Mock -CommandName Get-AuditCategory -MockWith { 
                    return $AuditFlag } -ModuleName MSFT_AuditPolicySubcategory

                It 'Should not throw an exception' {
                    { $script:getTargetResourceResult = Get-TargetResource @target } | 
                        Should Not Throw
                }

                It 'Should return the correct hashtable properties' {
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
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
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
                    $script:getTargetResourceResult.Ensure      | Should Be 'Absent'
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
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
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
                    $script:getTargetResourceResult.Subcategory | Should Be $script:target.Subcategory
                    $script:getTargetResourceResult.AuditFlag   | Should Be $script:target.AuditFlag
                    $script:getTargetResourceResult.Ensure      | Should Be 'Present'
                }
            }
        }
        #endregion

        #region Function Test-TargetResource
        Describe "$($script:DSCResourceName)\Test-TargetResource" {
            
            $script:target = @{
                Subcategory  = $Subcategory 
                AuditFlag = $AuditFlag
                Ensure = $null
            }    

            Context 'Subcategory Success flag present and should be' {
                Mock -CommandName Get-AuditCategory -MockWith { 
                    return $AuditFlag } -ModuleName MSFT_AuditPolicySubcategory 

                It 'Should not throw an exception' {
                    { $script:testTargetResourceResult = Test-TargetResource @target } | Should Not Throw
                }

                It "Should return true" {
                    $script:testTargetResourceResult | Should Be $true
                }
            }

            Context 'Subcategory Success flag present and should not be' {
                Mock -CommandName Get-AuditCategory -MockWith { 
                    return $AuditFlag } -ModuleName MSFT_AuditPolicySubcategory 

                It 'Should not throw an exception' {
                    { $script:testTargetResourceResult = Test-TargetResource @target } | Should Not Throw
                }

                It "Should return false" {
                    $script:testTargetResourceResult | Should Be $false
                }
            }
        }
        #endregion

        #region Function Set-TargetResource
        Describe "$($script:DSCResourceName)\Set-TargetResource" {
            
            Mock Set-AuditCategory { return }

            Context 'Return object' {
                $set = Set-TargetResource -Subcategory $Subcategory -AuditFlag $AuditFlag

                It 'is Empty' {
                    $set | Should BeNullOrEmpty
                }
            }

            Context 'Mandatory parameters' {
                
                It 'AuditFlag is mandatory ' {
                    {
                        Set-TargetResource -Subcategory $Subcategory -AuditFlag
                    } | Should Throw
                }

                It 'Subcategory is mandatory ' {
                    {
                        Set-TargetResource -Subcategory  -AuditFlag $AuditFlag
                    } | Should Throw
                }
            }

            Context "Validate support function" {
                
                $functionName = 'Set-AuditCategory'
                $Function = Get-Command $functionName

                It " Found function $functionName" {
                    $FunctionName = $Function.Name
        
                    $FunctionName | Should Be $functionName
                }

                It " Found parameter 'Subcategory'" {
                    $Subcategory = $Function.Parameters['Subcategory'].name
        
                    $Subcategory | Should Be 'Subcategory'
                }
            }
        }
        #endregion

        #region Helper Cmdlets
        Describe 'Private function Get-AuditCategory'  {

            Context 'Get single word audit category' {

                [string] $subCategory = 'Logon'
                [string] $auditFlag   = 'Success'
                # the return is 3 lines Header, blank line, data
                # ComputerName,System,Subcategory,GUID,AuditFlags
                Mock Invoke-Auditpol { @("","","$env:ComputerName,system,$subCategory,[GUID],$auditFlag") }

                $AuditCategory = Get-AuditCategory -SubCategory $subCategory 

                It "The return object is a String" {
                    $AuditCategory.GetType() | Should Be 'String'
                }
                
                It "with the value '$auditFlag'" {
                    $AuditCategory | Should BeExactly $auditFlag
                }
            }
        }

        Describe 'Private function Set-AuditCategory' {

            Context 'Set single word audit category Success flag to Present' {
                
                Mock Invoke-Auditpol { }
                    
                $comamnd = @{
                    SubCategory = "Logon"
                    AuditFlag = "Success"
                    Ensure = "Present"
                }

                It 'Should not throw an error' {
                    { Set-AuditCategory @comamnd } | Should Not Throw 
                }

                It "Should not return a value"  {
                    $AuditCategory | Should BeNullOrEmpty
                }
            }

            Context 'Set single word audit category Success flag to Absent' {
                
                Mock Invoke-Auditpol { }
                    
                $comamnd = @{
                    SubCategory = "Logon"
                    AuditFlag = "Success"
                    Ensure = "Absent"
                }

                It 'Should not throw an error' {
                    { Set-AuditCategory @comamnd } | Should Not Throw 
                }

                It "Should not return a value"  {
                    $AuditCategory | Should BeNullOrEmpty
                }
            }

            Context 'Set multi-word audit category Success flag to Present' {
                
                Mock Invoke-Auditpol { }
                    
                $comamnd = @{
                    SubCategory = "Object Access"
                    AuditFlag = "Success"
                    Ensure = "Present"
                }

                It 'Should not throw an error' {
                    { Set-AuditCategory @comamnd } | Should Not Throw 
                }

                It "Should not return a value"  {
                    $AuditCategory | Should BeNullOrEmpty
                }
            }

            Context 'Set multi-word audit category Success flag to Absent' {
                
                Mock Invoke-Auditpol { }
                    
                $comamnd = @{
                    SubCategory = "Object Access"
                    AuditFlag = "Success"
                    Ensure = "Absent"
                }

                It 'Should not throw an error' {
                    { Set-AuditCategory @comamnd } | Should Not Throw 
                }

                It "Should not return a value"  {
                    $AuditCategory | Should BeNullOrEmpty
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
