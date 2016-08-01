#Requires -Version 4.0

<# 
    This PS module contains functions for Desired State Configuration (DSC) AuditPolicyDsc provider. 
    It enables querying, creation, removal and update of Windows advanced audit policies through 
    Get, Set, and Test operations on DSC managed nodes.
#>

Import-LocalizedData -BindingVariable LocalizedData -Filename helper.psd1

<#
 .SYNOPSIS
    Invoke_Auditpol is a private function that wraps auditpol.exe to provide a 
    centralized function to mange access to and the output of auditpol.exe    
 .DESCRIPTION
    The function will accept a string to pass to auditpol.exe for execution. Any 'get' or
    'set' opertions can be passed to the central wrapper to execute. All of the 
    nuances of auditpol.exe can be further broken out into specalized functions that 
    call Invoke_AuditPol.   
    
    Since the call operators is being used to run auditpol, the input is restricted to only execute
    against auditpol.exe. Any input that is an invalid flag or parameter in 
    auditpol.exe will return an error to prevent abuse of the call.
    The call operator will not parse the parameters, so they are split in the fuction 
 .INPUTS
    The function accepts strings to control the execution against auditpol.exe 
 .OUTPUTS
    The raw string output of auditpol.exe with the /r switch to return a CSV string  
 .EXAMPLE
    Invoke_AuditPol -Command "Get" -SubCommand "Subcategory:logon"
#>

function Invoke_AuditPol
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Get", "Set")]
        [System.String]
        $Command,

        [parameter(Mandatory = $true)]
        [System.String]
        $SubCommand
    )

    Write-Debug -Message ($localizedData.ExecuteAuditpolCommand -f $CommandToExecute)

    <# 
        The raw auditpol data with the /r switch is a 3 line CSV
        0 - header row
        1 - blank row
        2 - the data row we are interested in
    #>

    # set the base commans to execute
    $commandString = "/$Command /$SubCommand"
    
    # add the /r if it is a get command
    if ( $Command -eq 'Get') 
    { 
        $commandString = $commandString + " /r"
    }

    try
    {
        # Use the call operator to process the auditpol command
        $return = & "auditpol" ( $commandString -split " " ) 2>&1

        # auditpol does not thrown exceptions, so test the results and throw if needed
        if( $LASTEXITCODE -ne 0 )
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
    Get_AuditCategory is a private function that generates the specifc parameters 
    and switches to be passed to Invoke_Auditpol to Get a specific audit category.    
 .DESCRIPTION
     In the absense of a PS module, this function is designed to extract the most 
     precise string from the advanced audit policy in Windows using auditpol.exe.

    While this function does not use aduitpol directly, it does generate a string that
    auditpol.exe will consume and return the correct result and then passes it to 
    Invoke_Auditpol 
 .INPUTS
    The nme os an audit subcategory in the forma of a String that has be validated
    by the public function  
 .OUTPUTS
    A string that is further processed by the public version of this function. 
#>

function Get_AuditCategory
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $SubCategory
    )
    
    # For auditpol format deatils see Invoke_Auditpol
    
    ( Invoke_Auditpol -Command "Get" -SubCommand "Subcategory:$SubCategory" )[2]
}

<#
 .SYNOPSIS 
    Gets the audit flag state for a specifc subcategory. 
 .DESCRIPTION
    Ths is one of the public functions that calls into Get_AuditCategory.
    This function enforces parameters that will be passed through to the 
    Get_AuditCategory function and aligns to a specifc parameterset. 
 .PARAMETER SubCategory 
    The name of the subcategory to get the audit flags from.
 .EXAMPLE
    Get-AuditCategory -SubCategory 'Logon'
#>

function Get-AuditCategory
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $SubCategory
    )

    <# 
        Get_AuditCategory returns a singel string in the following CSV format 
        Machine Name,Policy Target,Subcategory,Subcategory GUID,Inclusion Setting,Exclusion Setting
    #>
    $split = ( Get_AuditCategory @PSBoundParameters ) -split ","
    
    # remove the spaces from 'Success and Failure' to prevent any wierd string problems later
    [string] $auditFlag = $split[4] -replace " ",""
    
    $auditFlag
}


<#
 .SYNOPSIS
    Get_AuditOption is a private function that generates the specifc parameters 
    and switches to be passed to Invoke_Auditpol to Get a specific audit option.    
 .DESCRIPTION
     In the absense of a PS module, this function is designed to extract the most 
     precise string from the advanced audit policy in Windows using auditpol.exe.

    While this function does not use aduitpol directly, it does generate a string that
    auditpol.exe will consume and return the correct result and then passes it to 
    Invoke_Auditpol 
 .INPUTS
    The nme of an audit option in the form of a String that has be validated
    by the public function  
 .OUTPUTS
    A string that is further processed by the public version of this function. 
#>

function Get_AuditOption
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Option
    )
    
    # For auditpol format deatils see Invoke_Auditpol
    ( Invoke_Auditpol -Command "Get" -SubCommand "Option:$Option" )[2]    
}

<#
.SYNOPSIS
    Gets the audit policy option state.
     
.DESCRIPTION
    Ths is one of the public functions that calls into Get_AuditOption.
    This function enforces parameters that will be passed through to the 
    Get_AuditOption function and aligns to a specifc parameterset. 

.INPUTS
    The option name 
    
.OUTPUTS
    A string that is the state of the option (Enabled|Disables). 
#>

function Get-AuditOption
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name
    )
 
    # Get_AuditOption returns a single string with the Option and value on a single line
    # so we simply return the matched value. 

    ( ( Get_AuditOption -Option $Name ) -split "," )[4]
}


<#
 .SYNOPSIS
    Set_AuditCategory is a private function that generates the specifc parameters 
    and switches to be passed to Invoke_Auditpol to Set a specific audit category.    
 .DESCRIPTION
     In the absense of a PS module, this function is designed to extract the most 
     precise string from the advanced audit policy in Windows using auditpol.exe.

    While this function does not use aduitpol directly, it does generate a string that
    auditpol.exe will consume and return the correct result and then passes it to 
    Invoke_Auditpol 
 .INPUTS
    The nme of an audit category in the form of a String that has be validated
    by the public function  
 .OUTPUTS
    A string that is further processed by the public version of this function. 
#>

function Set_AuditCategory
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory=$true)]
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
        "Present"="enable";
        "Absent"="disable"
    }
            
    # select the line needed from the auditpol output
    if( $AuditFlag -eq 'Success' )
    { 
        [string] $subcommand = "subcategory:$SubCategory /success:$($auditState[$Ensure])" 
    }
    else   
    {
        [string] $subcommand = "subcategory:$SubCategory /failure:$($auditState[$Ensure])"
    }
                
    Invoke_Auditpol -Command "Set" -Subcommand $subcommand
}


<#
.SYNOPSIS 
    Sets the audit flag state for a specifc subcategory. 
.PARAMETER SubCategory 
    The name of the subcategory to set the audit flag on.
.PARAMETER AuditFlag 
    The name of the Auditflag to set.
.PARAMETER Ensure 
    The name of the subcategory to get the audit flags from.
.EXAMPLE
    Set-AuditCategory -SubCategory 'Logon'
.OUTPUTS
    None
#>

function Set-AuditCategory
{
    [CmdletBinding( SupportsShouldProcess=$true )]
    [OutputType([String])]
    param
    (
        [parameter( Mandatory = $true )]
        [System.String]
        $SubCategory,
        
        [parameter( Mandatory = $true )]
        [ValidateSet( "Success","Failure" )]
        [System.String]
        $AuditFlag,
        
        [parameter( Mandatory = $true )]
        [System.String]
        $Ensure
    )
 
    if( $pscmdlet.ShouldProcess( "$SubCategory","Set AuditFlag '$AuditFlag'" ) ) 
    {
        Set_AuditCategory @PSBoundParameters
    }
}


<#
.SYNOPSIS
    Set_AuditOption is a private function that generates the specifc parameters 
    and switches to be passed to Invoke_Auditpol to Set a specific audit option.    
.DESCRIPTION
     In the absense of a PS module, this function is designed to extract the most 
     precise string from the advanced audit policy in Windows using auditpol.exe.

    While this function does not use aduitpol directly, it does generate a string that
    auditpol.exe will consume and return the correct result and then passes it to 
    Invoke_Auditpol 
.INPUTS
    The nme of an audit option in the form of a String that has be validated
    by the public function  
.OUTPUTS
    A string that is further processed by the public version of this function. 
#>

function Set_AuditOption
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Value
    )
 
    # the output text of auditpol is in simple past tense, but the input is in simple 
    # present tense the hashtable corrects the tense for the input.  
    $valueHashTable = @{
        "Enabled" ="enable";
        "Disabled"="disable"
    }

    Invoke_Auditpol -Command "Set" -SubCommand "Option:$Name /value:$($valueHashTable[$value])"
}


<#
.SYNOPSIS
    Sets an audit policy option to enabled or disabled
.DESCRIPTION
    Ths is one of the public functions that calls into Set_AuditpolSubcommand.
    This function enforces parameters that will be passed through to the 
    Set_AuditpolSubcommand function and aligns to a specifc parameterset. 
.INPUTS
    The option name and state it will be set to. 
.OUTPUTS
    None
#>

function Set-AuditOption
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name,
        
        [Parameter(Mandatory=$true)]
        [System.String]
        $Value
    )

    if( $pscmdlet.ShouldProcess(  "$Name","Set $Value"  ) ) 
    {
        Set_AuditOption @PSBoundParameters
    }
}


# all private functions are named with "_" vs. "-"
Export-ModuleMember -Function *-* -Variable localizedData

