
Import-Module -Name (Join-Path -Path (Split-Path $PSScriptRoot -Parent) `
                               -ChildPath (Join-Path -Path 'DscResources' `
                                                     -ChildPath 'AuditPolicyResourceHelper.psm1')) `
                                                     -Force
<#
    .SYNOPSIS
    Gets the value of the audit policy option.
    .PARAMETER Name
    Specifies the option to get.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('CrashOnAuditFail', 'FullPrivilegeAuditing', 'AuditBaseObjects',
        'AuditBaseDirectories')]
        [System.String]
        $Name
    )
    
    # get the option's current value 
    $optionValue = Get-AuditOption @PSBoundParameters

    Write-Verbose ( $localizedData.GetAuditpolOptionSucceed -f $Name )

    $returnValue = @{
        Name   = $Name
        Value  = $optionValue
    }

    $returnValue
}

<#
    .SYNOPSIS
    Sets the value of the audit policy option.
    .PARAMETER Name
    Specifies the option to set.
    .PARAMETER Value
    Specifies the value to set on the option.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('CrashOnAuditFail', 'FullPrivilegeAuditing', 'AuditBaseObjects',
        'AuditBaseDirectories')]
        [System.String]
        $Name,

        [ValidateSet('Enabled', 'Disabled')]
        [System.String]
        $Value
    )

    try 
    {
        Set-AuditOption @PSBoundParameters
        Write-Verbose ( $localizedData.SetAuditpolOptionSucceed -f $Name, $Value )
    }
    catch
    {
        Write-Verbose ( $localizedData.SetAuditpolOptionFailed -f $Name, $Value )
    }
}

<#
    .SYNOPSIS
    Sets the value of the audit policy option.
    .PARAMETER Name
    Specifies the option to test.
    .PARAMETER Value
    Specifies the value to test against the option.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('CrashOnAuditFail', 'FullPrivilegeAuditing', 'AuditBaseObjects',
        'AuditBaseDirectories')]
        [System.String]
        $Name,

        [ValidateSet('Enabled', 'Disabled')]
        [System.String]
        $Value
    )

    if ( ( Get-AuditOption -Name $Name ) -eq $Value )
    {
        Write-Verbose ( $localizedData.TestAuditpolOptionCorrect -f $Name,$value )
        $return = $true
    }
    else
    {
        Write-Verbose ( $localizedData.TestAuditpolOptionIncorrect -f $Name,$value )
        $return = $false
    }

    $return
}

#---------------------------------------------------------------------------------------------------
# Support functions to handle auditpol I/O

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
        When PowerShell cmdlets are released for individual audit policy settings a condition 
        will be placed here to use native PowerShell cmdlets to set the option details. 
    #>
    # get the auditpol raw csv output
    $returnCsv =  Invoke-AuditPol -Command "Get" -SubCommand "Option:$Name"
    
    # split the details into an array
    $optionDetails = ( $returnCsv[2] ) -split ','

    # return the option value
    return $optionDetails[4]
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
        When PowerShell cmdlets are released for individual audit policy settings a condition 
        will be placed here to use native PowerShell cmdlets to set the option details. 
    #>
    if ( $pscmdlet.ShouldProcess( "$Name","Set $Value" ) ) 
    {
        <# 
        The output text of auditpol is in simple past tense, but the input is in simple 
        present tense the hashtable corrects the tense for the input.  
        #>
        $valueHashTable = @{
            'Enabled'  = 'enable'
            'Disabled' = 'disable'
        }
        
        [string[]] $SubCommand = @( "Option:$Name", "/value:$($valueHashTable[$value])" )

        Invoke-AuditPol -Command "Set" -SubCommand $SubCommand | Out-Null
    }
}

Export-ModuleMember -Function *-TargetResource
