Import-Module -Name (Join-Path -Path ( Split-Path $PSScriptRoot -Parent ) `
                               -ChildPath 'AuditPolicyResourceHelper\AuditPolicyResourceHelper.psm1') `
                               -Force

# Localized messages for Write-Verbose statements in this resource
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_AuditPolicySubcategory'

# A keymap for the localized audit policy flag name lookup
$script:localizedAuditFlagBitTable = @{
    $localizedData.NoAuditing = 0
    $localizedData.Success = 1
    $localizedData.Failure = 2
    $localizedData.SuccessandFailure = 3
}

$script:AuditFlagParmaterBitTable = @{
    'Success' = 1
    'Failure' = 2
}

<#
    .SYNOPSIS
        Returns the current audit flag for the given subcategory.
    .PARAMETER Name
        Specifies the subcategory to retrieve.
    .PARAMETER AuditFlag
        Specifies the audit flag to retrieve.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Success', 'Failure')]
        [String]
        $AuditFlag
    )

    try
    {
        $currentAuditFlag = Get-AuditSubCategory -Name $Name
        Write-Verbose -Message ( $localizedData.GetAuditpolSubcategorySucceed -f $Name, $AuditFlag )
    }
    catch
    {
        Write-Verbose -Message ( $localizedData.GetAuditPolSubcategoryFailed -f $Name, $AuditFlag )
    }

    if ( Test-AuditSubcategoryBitPresent -CurrentAuditFlag $currentAuditFlag -AuditFlag $AuditFlag )
    {
        $currentAuditFlag = $AuditFlag
        $ensure = 'Present'
    }
    else
    {
        $ensure = 'Absent'
    }

    return @{
        Name      = $Name
        AuditFlag = $currentAuditFlag
        Ensure    = $ensure
    }
}

<#
    .SYNOPSIS
        Sets the audit flag for the given subcategory.
    .PARAMETER Name
        Specifies the subcategory to set.
    .PARAMETER AuditFlag
        Specifies the audit flag to set.
    .PARAMETER Ensure
        Specifies the state of the audit flag provided. By default this is set to Present.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Success', 'Failure')]
        [String]
        $AuditFlag,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present'
    )

    if ( -Not ( Test-ValidSubcategory -Name $Name ) )
    {
        Throw ( $localizedData.InvalidSubcategory -f $Name )
    }

    try
    {
        Set-AuditSubcategory -Name $Name -AuditFlag $AuditFlag -Ensure $Ensure
        Write-Verbose -Message ( $localizedData.SetAuditpolSubcategorySucceed `
                        -f $Name, $AuditFlag, $Ensure )
    }
    catch
    {
        Write-Verbose -Message ( $localizedData.SetAuditpolSubcategoryFailed `
                        -f $Name, $AuditFlag, $Ensure )
    }
}

<#
    .SYNOPSIS
        Tests the audit flag state for the given subcategory.
    .PARAMETER Name
        Specifies the subcategory to test.
    .PARAMETER AuditFlag
        Specifies the audit flag to test.
    .PARAMETER Ensure
        Specifies the state of the audit flag should be in.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Success', 'Failure')]
        [String]
        $AuditFlag,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [String]
        $Ensure = 'Present'
    )

    [Boolean] $isInDesiredState = $false

    if ( -Not ( Test-ValidSubcategory -Name $Name ) )
    {
        Throw ( $localizedData.InvalidSubcategory -f $Name )
    }

    [String] $currentAuditFlag = (Get-TargetResource -Name $Name -AuditFlag $AuditFlag).AuditFlag

    # If the setting should be present look for a match, otherwise look for a notmatch
    if ( $Ensure -eq 'Present' )
    {
        $isInDesiredState = Test-AuditSubcategoryBitPresent -CurrentAuditFlag $currentAuditFlag -AuditFlag $AuditFlag
    }
    else
    {
        $isInDesiredState = ( -not ( Test-AuditSubcategoryBitPresent -CurrentAuditFlag $currentAuditFlag `
                                                                     -AuditFlag $AuditFlag ) )
    }

    <#
        The audit type can be true in either a match or non-match state. If the audit type
        matches the ensure property return the setting correct message, else return the
        setting incorrect message
    #>
    if ( $isInDesiredState )
    {
        Write-Verbose -Message ( $localizedData.TestAuditpolSubcategoryCorrect `
                        -f $Name, $AuditFlag, $Ensure )
    }
    else
    {
        Write-Verbose -Message ( $localizedData.TestAuditpolSubcategoryIncorrect `
                       -f $Name, $AuditFlag, $Ensure )
    }

    $isInDesiredState
}

#---------------------------------------------------------------------------------------------------
# Support functions to handle auditpol I/O

<#
    .SYNOPSIS
        Gets the audit flag state for a specifc subcategory.
    .DESCRIPTION
        This function enforces parameters that will be passed to Invoke-Auditpol.
    .PARAMETER Name
        The name of the subcategory to get the audit flags from.
    .OUTPUTS
        A string with the flags that are set for the specificed subcategory
    .EXAMPLE
        Get-AuditSubCategory -Name 'Logon'
#>
function Get-AuditSubCategory
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Name
    )
    <#
        When PowerShell cmdlets are released for individual audit policy settings a condition
        will be placed here to use native PowerShell cmdlets to set the subcategory flags.
    #>
    # get the auditpol raw csv output
    $subcategory = Invoke-AuditPol -Command 'Get' -SubCommand "Subcategory:""$Name"""

    # The subcategory flag is stored in the 'Inclusion Setting' property of the output CSV.
    return $subcategory.'Inclusion Setting'
}

<#
    .SYNOPSIS
        Sets the audit flag state for a specifc subcategory.
    .DESCRIPTION
        Calls the private function to execute a set operation on the given subcategory
    .PARAMETER Name
        The name of the audit subcategory to set
    .PARAMETER AuditFlag
        The specifc flag to set (Success|Failure)
    .PARAMETER Ensure
        The action to take on the flag
    .EXAMPLE
        Set-AuditSubcategory -Name 'Logon' -AuditFlag 'Success' -Ensure 'Present'
#>
function Set-AuditSubcategory
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateSet( 'Success','Failure' )]
        [String]
        $AuditFlag,

        [Parameter(Mandatory = $true)]
        [String]
        $Ensure
    )
    <#
        When PowerShell cmdlets are released for individual audit policy settings a condition
        will be placed here to use native PowerShell cmdlets to set the option details.
    #>
    if ( $pscmdlet.ShouldProcess( "$Name","Set AuditFlag '$AuditFlag'" ) )
    {
        # Translate $ensure=present to enable and $ensure=absent to disable
        $auditState = @{
            'Present' = 'enable'
            'Absent'  = 'disable'
        }

        # Create the line needed for auditpol to set the category flag
        if ( $AuditFlag -eq 'Success' )
        {
            [String[]] $subcommand = @( "Subcategory:""$Name""", "/success:$($auditState[$Ensure])" )
        }
        else
        {
            [String[]] $subcommand = @( "Subcategory:""$Name""", "/failure:$($auditState[$Ensure])" )
        }

        Invoke-AuditPol -Command 'Set' -subCommand $subcommand | Out-Null
    }
}

function Test-AuditSubcategoryBitPresent
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $CurrentAuditFlag,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Success', 'Failure')]
        [String]
        $AuditFlag
    )

    <#
        Since the subcategory flags are localized on the system that generates the configuration
        string comparisons may not be reliable.
        The localizedAuditFlagBitTable is loaded from the locaization strings, so the same
        2 bits can be evaluated reguardless of the language.
    #>

    $bitSet = $localizedAuditFlagBitTable.$CurrentAuditFlag -band $AuditFlagParmaterBitTable.$AuditFlag
    if ( $bitSet -eq $AuditFlagParmaterBitTable.$AuditFlag )
    {
        return $true
    }
    else
    {
        return $false
    }
}

Export-ModuleMember -Function *-TargetResource
