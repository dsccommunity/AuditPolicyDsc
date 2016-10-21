
Import-Module $PSScriptRoot\..\Helper.psm1

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


Export-ModuleMember -Function *-TargetResource
