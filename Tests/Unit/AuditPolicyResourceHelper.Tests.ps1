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

Describe 'Prereq' {

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

Describe 'auditpol.exe output' {

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

Describe "Private function Invoke-Auditpol" {

    InModuleScope AuditPolicyResourceHelper {

        $command = Get-Command Invoke-Auditpol
        # parameters listed in the Hashtable name = type, Mandatory, validateSet
        $parameters = @{
                            'Command'    = @('String',@('set','get'))
                            'Subcommand' = @('String[]')
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
