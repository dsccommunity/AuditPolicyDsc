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

Export-ModuleMember -Function 'Invoke-AuditPol' -Variable 'LocalizedData'
