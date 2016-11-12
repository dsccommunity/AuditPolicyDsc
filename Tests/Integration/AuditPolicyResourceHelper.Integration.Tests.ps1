#requires -RunAsAdministrator

# Get the root path of the resourse
[String] $script:moduleRoot = Split-Path -Parent ( Split-Path -Parent $PSScriptRoot )

Import-Module -Name (Join-Path -Path $moduleRoot `
                               -ChildPath 'DSCResources\AuditPolicyResourceHelper\AuditPolicyResourceHelper.psm1' ) `
                               -Force
#region Generate data

<# 
    The auditpol utility outputs the list of categories and subcategories in a couple of different 
    ways. Using the /list flag only returns the categories without the associated audit setting, 
    so it is easier to filter later on.
#>

$script:categories = @()
$script:subcategories = @()

auditpol /list /subcategory:* | 
Where-Object { $_ -notlike 'Category/Subcategory*' } | ForEach-Object `
{
    # The categories do not have any space in front of them, but the subcategories do.
    if ( $_ -notlike " *" )
    {
        $categories += $_.Trim()
    }
    else
    {
        $subcategories += $_.trim()
    }
} 

#endregion

Describe 'Prerequisites' {

    # There are several dependencies for both Pester and AuditPolicyDsc that need to be validated.
    It "Should be running as admin" {
        # The tests need to run as admin to have access to the auditpol data
        ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator") | Should Be $true
    }

    It "Should find auditpol.exe in System32" {
        # If the auditpol is not located on the system, the entire module will fail
        Test-Path "$env:SystemRoot\system32\auditpol.exe" | Should Be $true
    }
}

Describe 'auditpol.exe output' {

    # Verify the raw auditpol output format has not changed across different OS versions and types.
    It 'Should get auditpol default return with no parameters' {
        ( auditpol.exe )[0] | Should BeExactly 'Usage: AuditPol command [<sub-command><options>]'
    }

    It 'Should get CSV format with the /r switch' {
        ( auditpol.exe /get /subcategory:logon /r )[0] | 
        Should BeExactly "Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting"
    }

    # Loop through the raw output of every category option to validate the auditpol /category subcommand
    foreach ( $category in $categories ) 
    {
        Context "Category: $category" {
        
            $auditpolCategory = auditpol.exe /get /category:$category /r
          
            It 'Should return an empty string on line 1' {

                $auditpolCategory[1] | Should Be ""
            }

            It 'Should return the category contents on line 2' {

                # the auditpol /r output starts with the computer name on each entry
                $auditpolCategory[2] | Should Match "$env:ComputerName"
            }
        }
    }

    # Loop through the filtered output of every category option to validate the auditpol /category subcommand
    foreach ( $category in $categories ) 
    {
        Context "Category: $category Filtered 'Select-String -Pattern `$env:ComputerName'" {
            # Reuse the same command as the raw output context, only this time filter out the entries.
            # This is to verify the row indexing is not broken in later formatting actions

            $auditpolCategory = auditpol.exe /get /category:$category /r | 
                Select-String -Pattern $env:ComputerName
            $auditpolCategoryCount = ($auditpolCategory | Measure-Object).Count
        
            It 'Should return more than one item' { 
                # The header row has been stripped, so there should be more than one category to 
                # account for multiple subcategories
                $auditpolCategoryCount | Should BeGreaterThan 1
            }

            # Loop through the subcategories returned by the current category that was queried
            for ( $i = 0; $i -lt $auditpolCategoryCount; $i++ )
            {
                It "Should return a subcategory on line $i" {
                    # Verify that each filtered row that is returned, is in the expected format 
                    $auditpolCategory[$i] | Should Match "$env:ComputerName,System,"
                }
            }

            It 'Should return a null on the last line' {
                # With a zero base, the count of the subcategories should index to the end of the list
                $auditpolCategory[$auditpolCategoryCount] | Should BeNullOrEmpty
            }
        }
    }

    # Loop through the raw output of every subcategory to validate the auditpol /subcategory subcommand
    foreach ( $subcategory in $subcategories ) 
    {
        Context "Subcategory: $subcategory" {

            $auditpolSubcategory = auditpol.exe /get /subcategory:$subcategory /r

            It 'Should return an empty string on line 1there should be more than one category to account for multiple subcategories' {
                # Verify the raw auditpol CSV header format has not changed across different OS versions and types. 
                $auditpolSubcategory[1] | Should BeNullOrEmpty
            }
        
            It 'Should return the subcategory on line 2' {
                # Verify the raw auditpol CSV header format has not changed across different OS versions and types. 
                $auditpolSubcategory[2] | Should Match "$env:ComputerName"
            }
        }
    }

    # Loop through the filtered output of every subcategory to validate the auditpol /subcategory subcommand
    foreach ( $subcategory in $subcategories ) 
    {
        Context "Subcategory: $subcategory Filtered 'Select-String -Pattern `$env:ComputerName'" {
            # Reuse the same command as the raw output context, only this time filter out the entries.
            # This is to verify the row indexing is not broken in the formatting function
            $auditpolSubcategory = auditpol.exe /get /subcategory:$subcategory /r | 
                Select-String -Pattern $env:ComputerName

            It 'Should return a single subcategory' {
                # Verify the raw auditpol CSV header format has not changed across different OS versions and types. 
                ($auditpolSubcategory | Measure-Object).Count | Should Be 1
            }

            It 'Should return the Subcategory on line 0' {
                # Verify that each filtered row that is returned is in the expected format 
                $auditpolSubcategory[0] | Should Match "$env:ComputerName,System,"
           }

            It 'Should return null on line 1' {
                # Verify the raw auditpol CSV header format has not changed across different OS versions and types. 
                $auditpolSubcategory[1]| Should BeNullOrEmpty
            }
        }
    }
}

Describe "Function Invoke-Auditpol" {

    InModuleScope AuditPolicyResourceHelper {

        $command = Get-Command -Name Invoke-Auditpol

        It "Should find command Invoke-Auditpol" {
            $command.Name | Should Be 'Invoke-Auditpol' 
        }

        It 'Should have a parameter Command' {
            $command.Parameters.Command | Should Not BeNullOrEmpty
        }

        It 'Should have a ValidSet (Set|Get|List|Backup|Restore)' {
            $command.Parameters.Command.Attributes.ValidValues | 
            Should Be @('Set','Get','List','Backup','Restore')
        }

        It 'Should have a parameter Subcommand' {
            $command.Parameters.Subcommand | Should Not BeNullOrEmpty
        }

        # These tests verify that the /r switch is passed to auditpol 
        It 'Should return a CSV format when a single word subcategory is passed in' {
            ( Invoke-Auditpol -Command "Get" -SubCommand "Subcategory:Logoff" )[0] | 
            Should match ".,."
        }

        It 'Should return a CSV format when a multi-word subcategory is passed in' {
            ( Invoke-Auditpol -Command "Get" -SubCommand "Subcategory:""Credential Validation""" )[0] | 
            Should match ".,."
        }

        It 'Should return a CSV format when an option is passed in' {
            ( Invoke-Auditpol -Command "Get" -SubCommand "option:CrashOnAuditFail" )[0] | 
            Should match ".,."
        }

        Context 'Backup' {

            $path = ([system.IO.Path]::GetTempFileName()).Replace('tmp','csv') 
            
            It 'Should be able to call Invoke-Audtipol with backup and not throw' {    
                {Invoke-AuditPol -Command 'Backup' -SubCommand "file:$path"} | 
                Should Not Throw
            }       

            It 'Should not return anything when a backup is requested' {    
                (Invoke-AuditPol -Command 'Backup' -SubCommand "file:$path") | 
                Should BeNullOrEmpty
            }

            It 'Should produce a valid CSV to a temp file when the backup switch is used' {
                (Import-csv -Path $path)[0] | 
                Should BeExactly "Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting"
            }
        }
        
        Context 'Restore' {

            It 'Should be able to call Invoke-Audtipol with backup and not throw' {    
                {Invoke-AuditPol -Command 'Restore' -SubCommand "file:$path"} | 
                Should Not Throw
            } 
            
            It 'Should not return anything when a restore is requested' {
                (Invoke-AuditPol -Command 'Restore' -SubCommand "file:$path") | 
                Should BeNullOrEmpty
            }
        }
    }
}

Describe 'Test-ValidSubcategory' {

    InModuleScope AuditPolicyResourceHelper {

        $command = Get-Command -Name Test-ValidSubcategory

        It "Should find command Test-ValidSubcategory" {
            $command.Name | Should Be 'Test-ValidSubcategory' 
        }

        It 'Should return false when an invalid Subcategory is passed ' {
            Test-ValidSubcategory -Name 'Invalid' | Should Be $false
        }

        It 'Should return true when a valid Subcategory is passed ' {
            Test-ValidSubcategory -Name 'logon' | Should Be $true
        }
    }
}
