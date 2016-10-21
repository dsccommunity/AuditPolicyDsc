#requires -RunAsAdministrator

# get the root path of the resourse
[String] $moduleRoot = Split-Path -Parent ( Split-Path -Parent $PSScriptRoot ) 

# get the module name to import
[string] $sut = ( Split-Path -Leaf $MyInvocation.MyCommand.Path )  -Replace "\.tests\.ps1", ".psm1"

Import-Module "$moduleRoot\DSCResources\$sut" -Force

#region Generate data

<# 
    The auditpol utility outputs the list of categories and subcategories in a couple 
    of different ways and formats. Using the /list flag only returns the categories 
    without the associated audit setting, so it is easier to filter on.
#>

function Get-AuditpolCategories
{
    $auditpol = auditpol /list /subcategory:*
    $Categories = @()
    $SubCategories = @()
    $auditpol | Where-Object {$_ -notlike 'Category/Subcategory*'} | ForEach-Object `
    {
        # the categories do not have any space in front of them, but the subcategories do.
        if ( $_ -notlike " *" )
        {
            $Categories += $_.Trim()
        }
        else
        {
            $SubCategories += $_.trim()
        }
    } 
    $Categories, $SubCategories
} 

$Categories, $SubCategories = Get-AuditpolCategories

#endregion

Describe 'Prereq' `
-Tags Setup {

    # There are several dependencies for both Pester and auditpol resource that need to be validated.

    It "Checks if the tests are running as admin" {

        # the tests need to run as admin to have access to the auditpol data
        ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator") | Should Be $true
    }

    It "Checks auditpol.exe exists in System32  " {

        # if the auditpol is not located on the system, the entire module will fail
        Test-Path "$env:SystemRoot\system32\auditpol.exe" | Should Be $true
    }
}

Describe 'auditpol.exe output' `
-Tags Setup {

    # verify the raw auditpol output format has not changed across different OS versions and types.
    
    It "Checks auditpol default return with no parameters      " {

        ( auditpol.exe )[0] | should BeExactly 'Usage: AuditPol command [<sub-command><options>]'
    }

    It "Checks auditpol CSV header format with the /r switch   " {

        ( auditpol.exe /get /subcategory:logon /r )[0] | 
        should BeExactly "Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting"
    }

    # loop through the raw output of every category option to validate the auditpol /category subcommand
    Foreach( $Category in $Categories ) 
    {
        Context "Category: $Category" {
        
            $auditpolCategory = auditpol.exe /get /category:$Category /r
          
            It "Checks auditpol category returns empty string on line 1 " {

                $auditpolCategory[1] | should Be ""
            }

            It "Checks auditpol category returns first entry  on line 2 " {

                # the auditpol /r output starts with the computer name on each entry
                $auditpolCategory[2] | should Match "$env:ComputerName"
            }
        }
    }

    # loop through the filtered output of every category option to validate the auditpol /category subcommand
    Foreach( $Category in $Categories ) 
    {
        Context "Category: $Category Filtered 'Select-String -Pattern `$env:ComputerName'" {
        
            # Reuse the same command as the raw output context, only this time filter out the entries.
            # this is to verify the row indexing is not broken in later formatting actions
            $auditpolCategory = auditpol.exe /get /category:$Category /r | 
            Select-String -Pattern $env:ComputerName
            $auditpolCategoryCount = ($auditpolCategory | Measure-Object).Count
        
            It "Checks auditpol category returns $auditpolCategoryCount items  " { 

                # The header row has been stripped, so greater than 1 is required to account for multiple subcategories
                $auditpolCategoryCount | should BeGreaterThan 1
            }

            # loop through the subcategories returned by the current category that was queried
            for ( $i=0;$i -lt $auditpolCategoryCount;$i++ )
            {
                It "Checks auditpol category returns entry on line $i " {

                    # Verify that each filtered row that is returned, is in the expected format 
                    $auditpolCategory[$i] | should Match "$env:ComputerName,System,"                   # <- Add more specific regexto account for positional GUID
                }
            }

            It "Checks auditpol category returns `$null on line $auditpolCategoryCount " {

                # with a zero base, the count of the subcategories should index to the end of the list
                $auditpolCategory[$auditpolCategoryCount] | should BeNullOrEmpty
            }
        }
    }

    # loop through the raw output of every subcategory to validate the auditpol /subcategory subcommand
    Foreach( $Subcategory in $Subcategories ) 
    {
        Context "Subcategory: $Subcategory" {

            $auditpolSubcategory = auditpol.exe /get /subcategory:$Subcategory /r

            It "Checks auditpol Subcategory returns empty string on line 1 " {

                # verify the raw auditpol CSV header format has not changed across different OS versions and types. 
                $auditpolSubcategory[1] | should BeNullOrEmpty
            }
        
            It "Checks auditpol Subcategory returns first entry  on line 2 " {

                # verify the raw auditpol CSV header format has not changed across different OS versions and types. 
                $auditpolSubcategory[2] | should Match "$env:ComputerName"
            }

            # add a regex for the entire string format to get an exact answer
        }
    }

    # loop through the filtered output of every subcategory to validate the auditpol /subcategory subcommand
    Foreach( $Subcategory in $Subcategories ) 
    {
        Context "Subcategory: $Subcategory Filtered 'Select-String -Pattern `$env:ComputerName'" {
        
            # Reuse the same command as the raw output context, only this time filter out the entries.
            # this is to verify the row indexing is not broken in the formatting function
            $auditpolSubcategory = auditpol.exe /get /subcategory:$Subcategory /r | 
            Select-String -Pattern $env:ComputerName

            It "Checks auditpol Subcategory returns one item         " {

                # verify the raw auditpol CSV header format has not changed across different OS versions and types. 
                ($auditpolSubcategory | Measure-Object).Count | should Be 1
            }

            It "Checks auditpol Subcategory returns entry on line 0  " {

                    # Verify that each filtered row that is returned, is in the expected format 
                    $auditpolSubcategory[0] | should Match "$env:ComputerName,System,"                   # <- Add more specific regex
           }

            It "Checks auditpol Subcategory returns `$null on line 1  " {

                # verify the raw auditpol CSV header format has not changed across different OS versions and types. 
                $auditpolSubcategory[1]| should BeNullOrEmpty
            }
        }
    }
}

Describe "Private function Invoke-Auditpol" `
-Tags Private, Get, Set  {

    InModuleScope Helper {

        $command = Get-Command Invoke-Auditpol
        # parameters listed in the Hashtable name = type, Mandatory, validateSet
        $parameters = @{
                            'Command'    = @('String',@('set','get'))
                            'Subcommand' = @('String')
                        }

        It "Should Exist" {

            $command | Should Be $command 
        }

        It 'With output type "String"' {

            $command.OutputType | Should Be 'System.String'
        }

        # this test verifes that the /r switch is passed to auditpol 
        It 'In a CSV format' {

            ( Invoke-Auditpol -Command "Get" -SubCommand "Subcategory:Logoff" )[0] | 
            Should match ".,."
        }

        # verify all of ther parameters are correct
        foreach( $parameter in $parameters.GetEnumerator() )
        {
            $name = $parameter.key
            It "Has a parameter '$name'" {

                $command.Parameters[$name].Name | Should Be $name
            }

            $type = $parameter.value[0]
            It "Of type '$type'" {

                $command.Parameters[$name].ParameterType | Should Be $type
            }

            $validateSet = $parameter.value[1]

            if ( $validateSet -ne $null )
            {
                It "With a validateSet '$validateSet'" {

                    $command.Parameters[$name].Attributes.ValidValues | Should Be $validateSet
                }
            }
        }
    }
}

Describe "Private function Get-AuditCategoryCommand" `
-Tags Private, Get, Category {  

    InModuleScope Helper {

        $command = Get-Command Get-AuditCategoryCommand
        $parameter = 'SubCategory'
        
        It "Should Exist" {

            $command | Should Be $command 
        }

        It 'With output type "String"' {

            $command.OutputType | Should Be 'System.String'
        }

        It "Has a parameter '$parameter'" {

            $command.Parameters[$parameter].Name | Should Be $parameter
        }

        It 'Of type "String"' {

            $command.Parameters[$parameter].ParameterType | Should Be 'String'
        }

        Context "Get-AuditCategoryCommand with Mock Invoke-Auditpol" {

            # subcategory to search for
            $SubCategory = 'logon'
            # partial result from auditpol, but in the correct multi line format
            [string[]] $auditpolReturn = "Machine Name,Policy Target,Subcategory,"
            $auditpolReturn += " "
            $auditpolReturn += "$env:COMPUTERNAME,System,$SubCategory,"

            mock Invoke-Auditpol { $auditpolReturn }
            mock Invoke-Auditpol { @('','','Leading Backslash') } `
                 -ParameterFilter { $Subcommand.StartsWith("/") }
            
            $AuditCategoryCommand = Get-AuditCategoryCommand -SubCategory "$SubCategory"

            It 'Calls Invoke-Auditpol exactly once'  {

                Assert-MockCalled Invoke-Auditpol -Exactly 1 -Scope Context  
            }

            It "Does not send a leading backslash('/') to Invoke-Auditpol -Subcommand" {

               $AuditCategoryCommand | Should Not Be 'Leading Backslash'
            }

            It "Gets the string with the correct subcategory back from Invoke-Auditpol" {

                $AuditCategoryCommand | Should BeExactly $auditpolReturn[2] 
            }
        }
    }
}

Describe 'Public function Get-AuditCategory' `
-Tags Public, Get, Category  {
    
    $command = Get-Command Get-AuditCategory
    $parameter = 'SubCategory'
        
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

    InModuleScope Helper {

        Context 'Get-AuditCategory with Mock ( Get-AuditCategoryCommand -SubCategory "Logon" ) returning "Success"' {

            [string] $subCategory = 'Logon'
            [string] $auditFlag   = 'Success'
            # the return format is ComputerName,System,Subcategory,GUID,AuditFlags
            [string] $returnString = "$env:ComputerName,system,$subCategory,[GUID],$auditFlag"

            Mock Get-AuditCategoryCommand { return $returnString } 

            $AuditCategory = Get-AuditCategory -SubCategory $subCategory

            It 'Calls Get-AuditCategoryCommand exactly once'  {

                Assert-MockCalled Get-AuditCategoryCommand -Exactly 1 -Scope Context  
            }

            It "The return object is a String" {

                $AuditCategory.GetType() | Should Be 'String'
            }

            It "with the value '$auditFlag'" {

                $AuditCategory | Should BeExactly $auditFlag
            }
        }
    }
}

Describe "Private function Get-AuditOptionCommand" `
-Tags Private, Get, Option {

    InModuleScope Helper {

        $command = Get-Command Get-AuditOptionCommand
        $parameter = 'Option'
        
        It "Should Exist" {

            $command | Should Be $command 
        }
        
        It 'With output type "String"' {

            $command.OutputType | Should Be 'System.String'
        }
        It "Has a parameter '$parameter'" {

            $command.Parameters[$parameter].Name | Should Be $parameter
        }

        It 'Of type "String"' {

            $command.Parameters[$parameter].ParameterType | Should Be 'String'
        }


        Context "Get-AuditOptionCommand with Mock Invoke-Auditpol" {
            
            # create a string array to mimic the auditpol output with the /r switch
            [string[]] $returnString =  "Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting"
                       $returnString += ""
                       $returnString += "$env:COMPUTERNAME,,Option:CrashonAuditFail,,Disabled,,"

            Mock Invoke-Auditpol { return $returnString }
            mock Invoke-Auditpol { @('','','Leading Backslash') } `
                 -ParameterFilter { $Subcommand.StartsWith("/") }

            [string] $AuditOptionCommand = Get-AuditOptionCommand -Option CrashOnAuditFail 
            
            It 'Calls Invoke-Auditpol exactly once'  {

                Assert-MockCalled Invoke-Auditpol -Exactly 1 -Scope Context  
            }

            It "Does not send a leading backslash('/') to Invoke-Auditpol -Subcommand" {

               $AuditOptionCommand | Should Not Be 'Leading Backslash'
            }

            It "Gets the string with the correct option back from Invoke-Auditpol" {

                $AuditOptionCommand | Should BeExactly $returnString[2]
            }
        }
    }
}

Describe 'Public function Get-AuditOption' `
-Tags Public, Get, Option  { 

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

    InModuleScope Helper {

        Context 'Get-AuditOption with Mock ( Get-AuditOptionCommand -Name "CrashOnAuditFail" ) returning "Enabled"' {

            [string] $name  = 'CrashOnAuditFail'
            [string] $value = 'Enabled'

            Mock Get-AuditOptionCommand { "$env:COMPUTERNAME,,Option:$name,,$value,," }

            $auditOption = Get-AuditOption -Name $name

            It 'Calls Get-AuditOptionCommand exactly once'  {

                Assert-MockCalled Get-AuditOptionCommand -Exactly 1 -Scope Context  
            }

            It "The option $name returns $value" {

                $auditOption | should Be $value
            }
        }
    }
}

Describe 'Private function Set-AuditCategoryCommand' `
-Tags Private, Set, Category {

    InModuleScope Helper {  

        $command = Get-Command Set-AuditCategoryCommand

        # parameters listed in the Hashtable name = type, Mandatory, validateSet
        $parameters = @{
                            'SubCategory' = @('String')
                            'AuditFlag'   = @('String')
                            'Ensure'      = @('String')
                        }  

        It "Should Exist" {

            $command | Should Be $command 
        }

        It "With no output" {

            $command.OutputType | Should BeNullOrEmpty
        }

        # verify all of ther parameters are correct
        foreach( $parameter in $parameters.GetEnumerator() )
        {
            $name = $parameter.key
            It "Has a parameter '$name'" {

                $command.Parameters[$name].Name | Should Be $name
            }

            $type = $parameter.value[0]
            It "Of type '$type'" {

                $command.Parameters[$name].ParameterType | Should Be $type
            }
        }

        context 'Set-AuditCategoryCommand with Mock ( Invoke-Auditpol )' {

            $auditState = @{
                'Present' = 'enable'
                'Absent'  = 'disable'
            }
            # parameters to splat 
            $comamnd = @{
                SubCategory = "Logon"
                AuditFlag = "success"
                Ensure = "Present"
            }

            Mock Invoke-Auditpol { } -Verifiable -ParameterFilter { 
                $Command.Equals("Set") -and `
                $SubCommand.Equals("Subcategory:$($comamnd.subcategory) /$($comamnd.AuditFlag):$($auditState[$comamnd.Ensure])") 
            }

            It "Does not thrown an error" {

                { $AuditCategory = Set-AuditCategoryCommand @comamnd } | Should Not Throw
            }

            It "Should not return a value" {

                $AuditCategory | Should BeNullOrEmpty
            }

            It 'Calls Invoke-Auditpol exactly once' {

                Assert-MockCalled Invoke-Auditpol -Exactly 1 -Scope Context
            }

            It "Calls Invoke-Auditpol in the correct format ( 'Subcategory:`$Subcategory /Success:`$AuditFlag' )" {

                Assert-VerifiableMocks
            }
        }
    }
}

Describe 'Public function Set-AuditCategory' `
-Tags Public, Set, Category {

    $command = Get-Command Set-AuditCategory
    $parameter = 'SubCategory'
        
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

    Context 'Set-AuditCategory with Mock ( Set-AuditCategoryCommand -SubCategory "Logon" ) returning "Success"' {
        
        InModuleScope Helper {  

            Mock Set-AuditCategoryCommand { } 
            
            $comamnd = @{
                SubCategory = "Logon"
                AuditFlag = "Success"
                Ensure = "Present"
            }

            It 'Should not throw an error' {

                { $AuditCategory = Set-AuditCategory @comamnd } | Should Not Throw 
            }

            It "Should not return a value"  {

                $AuditCategory | Should BeNullOrEmpty
            }

            It 'Calls Set-AuditCategoryCommand exactly once'  {

                Assert-MockCalled Set-AuditCategoryCommand -Exactly 1 -Scope Context  
            }
        }
    }

}

Describe 'Private function Set-AuditOptionCommand' `
-Tags Private, Set, Option { 

    InModuleScope Helper {  

        $command = Get-Command Set-AuditOptionCommand
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

        Context "Set-AuditOptionCommand with Mock ( Invoke-Auditpol )" {

            $valueHashTable = @{
                "Enabled"="enable";
                "Disabled"="disable"
            }

            [string] $name  = "CrashOnAuditFail"
            [string] $value = "Disable"

            Mock Invoke-Auditpol { } -Verifiable -ParameterFilter { 
                $command.Equals("Set") -and `
                $SubCommand.Equals("Option:$Name /value:$($valueHashTable[$value])") 
            }

            It "Does not thrown an error"  {

                { $AuditOption = Set-AuditOptionCommand -Name $name -Value $value } | 
                Should Not Throw
            }

            It "Should not return a value"  {

                $AuditOption | Should BeNullOrEmpty
            }

            It 'Calls Invoke-Auditpol exactly once'  {

                Assert-MockCalled Invoke-Auditpol -Exactly 1 -Scope Context
            }

            It "Calls Invoke-Auditpol in the correct format ( 'Option:`$Name /value:`$value' )"  {

                Assert-VerifiableMocks
            }
        }
    }
}

Describe 'Public function Set-AuditOption' `
-Tags Public, Set, Option { 

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

    InModuleScope Helper {

        Context "Set-AuditOption with Mock ( Set-AuditOptionCommand -Name 'CrashOnAuditFail' -Value 'disable' )" {

            [string] $name  = "CrashOnAuditFail"
            [string] $value = "Disable"

            Mock Set-AuditOptionCommand { } 

            It "Does not thrown an error" {
                
                { $setAuditOption =  Set-AuditOption -Name $name -Value $value } |
                Should Not Throw
            }    

            It "Should not return a value"  {

                $setAuditOption | Should BeNullOrEmpty
            }

            It 'Calls Set-AuditOptionCommand exactly once'  {

                Assert-MockCalled Set-AuditOptionCommand -Exactly 1 -Scope Context  
            }
        }
    }
}
