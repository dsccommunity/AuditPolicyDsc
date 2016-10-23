#Requires -Version 4.0

<# 
    This PS module contains functions for Desired State Configuration (DSC) AuditPolicyDsc provider. 
    It enables querying, creation, removal and update of Windows advanced audit policies through 
    Get, Set, and Test operations on DSC managed nodes.
#>

Import-LocalizedData -BindingVariable LocalizedData -Filename helper.psd1

<#
 .SYNOPSIS
    Invoke-AuditPol is a private function that wraps auditpol.exe providing a 
    centralized function to mange access to and the output of auditpol.exe.    
 .DESCRIPTION
    The function will accept a string to pass to auditpol.exe for execution. Any 'get' or
    'set' opertions can be passed to the central wrapper to execute. All of the 
    nuances of auditpol.exe can be further broken out into specalized functions that 
    call Invoke-AuditPol.   
    
    Since the call operators is being used to run auditpol, the input is restricted to only execute
    against auditpol.exe. Any input that is an invalid flag or parameter in 
    auditpol.exe will return an error to prevent abuse of the call.
    The call operator will not parse the parameters, so they are split in the fuction. 
 .PARAMETER Command 
    The action that audtipol should take on the subcommand.
 .PARAMETER SubCommand 
    The The subcommand the execute.
 .OUTPUTS
    The raw string output of auditpol.exe with the /r switch to return a CSV string. 
 .EXAMPLE
    Invoke-AuditPol -Command 'Get' -SubCommand 'Subcategory:Logon'
#>
function Invoke-AuditPol
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Get', 'Set')]
        [System.String]
        $Command,

        [parameter(Mandatory = $true)]
        [System.String[]]
        $SubCommand
    )

    <# 
        The raw auditpol data with the /r switch is a 3 line CSV
        0 - header row
        1 - blank row
        2 - the data row we are interested in
    #>

    # set the base commands to execute
    if ( $Command -eq 'Get') 
    { 
        $commandString = @("/$Command","/$SubCommand","/r" )
    }
    else
    {
        # the set subcommand comes in an array of the subcategory and flag 
        $commandString = @("/$Command","/$($SubCommand[0])",$SubCommand[1] )
    }

    Write-Debug -Message ( $localizedData.ExecuteAuditpolCommand -f $commandString )

    try
    {
        # Use the call operator to process the auditpol command
        $return = & "auditpol.exe" $commandString 2>&1

        # auditpol does not thrown exceptions, so test the results and throw if needed
        if ( $LASTEXITCODE -ne 0 )
        {
            throw New-Object System.ArgumentException
        }

        $return
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        # catch error if the auditpol command is not found on the system
        Write-Error -Message $localizedData.AuditpolNotFound
    }
    catch [System.ArgumentException]
    {
        # catch the error thrown if the lastexitcode is not 0 
        [string] $errorString = $error[0].Exception
        $errorString = $errorString + "`$LASTEXITCODE = $LASTEXITCODE;"
        $errorString = $errorString + " Command = auditpol $commandString"
        
        Write-Error -Message $errorString
    }
    catch
    {
        # catch any other errors
        Write-Error -Message ( $localizedData.UnknownError -f $error[0] )
    }
}


<#
 .SYNOPSIS
    Get-AuditCategoryCommand is a private function that generates the specifc parameters 
    and switches to be passed to Invoke-AuditPol to Get a specific audit category.    
 .DESCRIPTION
     In the absense of a PS module, this function is designed to extract the most 
     precise string from the advanced audit policy in Windows using auditpol.exe.

    While this function does not use aduitpol directly, it does generate a string that
    auditpol.exe will consume in Invoke-AuditPol.
 .PARAMETER SubCategory 
    The name of the subcategory to get the audit flags from.
 .OUTPUTS
    The third string of the auditpol results 
#>
function Get-AuditCategoryCommand
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $SubCategory
    )
    
    # For auditpol format deatils see Invoke-AuditPol
    ( Invoke-AuditPol -Command "Get" -SubCommand "Subcategory:""$SubCategory""" )[2]
}


<#
 .SYNOPSIS 
    Gets the audit flag state for a specifc subcategory. 
 .DESCRIPTION
    Ths is the public function that calls into Get-AuditCategoryCommand. This function enforces
    parameters that will be passed to Get-AuditCategoryCommand. 
 .PARAMETER SubCategory 
    The name of the subcategory to get the audit flags from.
 .OUTPUTS
    A string with the flags that are set for the specificed subcategory 
 .EXAMPLE
    Get-AuditCategory -SubCategory 'Logon'
#>
function Get-AuditCategory
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $SubCategory
    )

    <#
        When PowerShell cmdlets are released for individual audit policy settings
        a condition will be placed here to use native PowerShell cmdlets to return
        the category details. 
    #>

    <# 
        Get-AuditCategoryCommand returns a single string in the following CSV format 
        Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting
    #>
    $split = ( Get-AuditCategoryCommand @PSBoundParameters ) -split ','

    # remove the spaces from 'Success and Failure' to prevent any wierd string problems later
    [string] $auditFlag = $split[4] -replace ' ',''
    
    $auditFlag
}


<#
 .SYNOPSIS
    Get-AuditOptionCommand is a private function that generates the specifc parameters 
    and switches to be passed to Invoke-AuditPol to Get a specific audit option.    
 .DESCRIPTION
     In the absense of a PS module, this function is designed to extract the most 
     precise string from the advanced audit policy in Windows using auditpol.exe.

    While this function does not use aduitpol directly, it does generate a string that
    auditpol.exe will consume in Invoke-AuditPol.
 .PARAMETER Option 
    The name of an audit option in the form of a String that has be validated
    by the public function  
 .OUTPUTS
    A string that is further processed by the public version of this function. 
#>
function Get-AuditOptionCommand
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Option
    )
    
    # For auditpol format deatils see Invoke-AuditPol
    ( Invoke-AuditPol -Command "Get" -SubCommand "Option:$Option" )[2]   
}


<#
 .SYNOPSIS
    Gets the audit policy option state.
 .DESCRIPTION
    Ths is one of the public functions that calls into Get-AuditOptionCommand.
    This function enforces parameters that will be passed through to the 
    Get-AuditOptionCommand function and aligns to a specifc parameterset. 
 .PARAMETER Option 
    The name of an audit option.
 .OUTPUTS
    A string that is the state of the option (Enabled|Disables). 
#>
function Get-AuditOption
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name
    )

    <#
        When PowerShell cmdlets are released for individual audit policy settings
        a condition will be placed here to use native PowerShell cmdlets to return
        the option details. 
    #>

    <# 
        Get-AuditOptionCommand returns a single string with the Option in a CSV list, so 
        get the 5th item in the list and return it
    #>
    ( ( Get-AuditOptionCommand -Option $Name ) -split ',' )[4]
}


<#
 .SYNOPSIS
    Set-AuditCategoryCommand is a private function that generates the specifc parameters 
    and switches to be passed to Invoke-AuditPol to Set a specific audit category.    
 .DESCRIPTION
     In the absense of a PS module, this function is designed to extract the most 
     precise string from the advanced audit policy in Windows using auditpol.exe.

    While this function does not use aduitpol directly, it does generate a string that
    auditpol.exe will consume in Invoke-AuditPol.
 .PARAMETER SubCategory
    The name of an audit category to set
 .PARAMETER AuditFlag
    The specifc flag to set (Success|Failure)
 .PARAMETER Ensure 
    The action to take on the flag
 .EXAMPLE
    Set-AuditCategoryCommand -SubCategory 'Logon' -AuditFlag 'Success' -Ensure 'Present'
 .OUTPUTS
    None 
#>
function Set-AuditCategoryCommand
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SubCategory,

        [parameter(Mandatory = $true)]
        [System.String]
        $AuditFlag,

        [parameter(Mandatory = $true)]
        [System.String]
        $Ensure
    )
    
    # translate $ensure=present to enable and $ensure=absent to disable
    $auditState = @{
        'Present' = 'enable'
        'Absent'  = 'disable'
    }
            
    # create the line needed auditpol to set the category flag
    if ( $AuditFlag -eq 'Success' )
    { 
        [string[]] $subcommand = @( "Subcategory:""$SubCategory""", "/success:$($auditState[$Ensure])" )
    }
    else   
    {
        [string[]] $subcommand = @( "Subcategory:""$SubCategory""", "/failure:$($auditState[$Ensure])" )
    }
                
    Invoke-AuditPol -Command 'Set' -Subcommand $subcommand | Out-Null
}


<#
 .SYNOPSIS 
    Sets the audit flag state for a specifc subcategory. 
 .DESCRIPTION
    Calls the private function to execute a set operation on the given subcategory
 .PARAMETER SubCategory
    The name of an audit category to set
 .PARAMETER AuditFlag
    The specifc flag to set (Success|Failure)
 .PARAMETER Ensure 
    The action to take on the flag
 .EXAMPLE
    Set-AuditCategory -SubCategory 'Logon' -AuditFlag 'Success' -Ensure 'Present'
 .OUTPUTS
    None 
#>
function Set-AuditCategory
{
    [CmdletBinding( SupportsShouldProcess=$true )]
    param
    (
        [parameter( Mandatory = $true )]
        [System.String]
        $SubCategory,
        
        [parameter( Mandatory = $true )]
        [ValidateSet( 'Success','Failure' )]
        [System.String]
        $AuditFlag,
        
        [parameter( Mandatory = $true )]
        [System.String]
        $Ensure
    )

    <#
        When PowerShell cmdlets are released for individual audit policy settings
        a condition will be placed here to use native PowerShell cmdlets to set
        the subcategory details. 
    #>

    if ( $pscmdlet.ShouldProcess( "$SubCategory","Set AuditFlag '$AuditFlag'" ) ) 
    {
        Set-AuditCategoryCommand @PSBoundParameters
    }
}


<#
 .SYNOPSIS
    Get-AuditOptionCommand is a private function that generates the specifc parameters 
    and switches to be passed to Invoke-AuditPol to Set a specific audit option.    
 .DESCRIPTION
     In the absense of a PS module, this function is designed to extract the most 
     precise string from the advanced audit policy in Windows using auditpol.exe.

    While this function does not use aduitpol directly, it does generate a string that
    auditpol.exe will consume in Invoke-AuditPol. 
 .PARAMETER Name
    The specifc Option to set
 .PARAMETER Value 
    The value to set on the provided Option
 .EXAMPLE
    Get-AuditOptionCommand -Name 'CrashOnAuditFail' -Value 'enabled'
 .OUTPUTS
    None 
#>
function Set-AuditOptionCommand
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Value
    )
 
    <# 
        The output text of auditpol is in simple past tense, but the input is in simple 
        present tense the hashtable corrects the tense for the input.  
    #>
    $valueHashTable = @{
        'Enabled'  = 'enable'
        'Disabled' = 'disable'
    }
    
    $SubCommand = "Option:$Name /value:$($valueHashTable[$value])"

    Invoke-AuditPol -Command "Set" -SubCommand $SubCommand | Out-Null
}


<#
 .SYNOPSIS
    Sets an audit policy option to enabled or disabled
 .DESCRIPTION
    This public function calls Set-AuditOptionCommand and enforces parameters 
    that will be passed to Set-AuditOptionCommand and aligns to a specifc parameterset. 
 .PARAMETER Name
    The specifc Option to set
 .PARAMETER Value 
    The value to set on the provided Option
 .OUTPUTS
    None
#>
function Set-AuditOption
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name,
        
        [Parameter(Mandatory=$true)]
        [System.String]
        $Value
    )

    <#
        When PowerShell cmdlets are released for individual audit policy settings
        a condition will be placed here to use native PowerShell cmdlets to set
        the option details. 
    #>

    if ( $pscmdlet.ShouldProcess( "$Name","Set $Value" ) ) 
    {
        Set-AuditOptionCommand @PSBoundParameters
    }
}


$members = @{

    Function = @(
         'Get-AuditCategory',
         'Get-AuditOption',
         'Set-AuditCategory',
         'Set-AuditOption'
    ) 
    Variable = 'localizedData'
}
Export-ModuleMember @members
