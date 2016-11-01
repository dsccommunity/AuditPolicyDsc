
Import-Module -Name (Join-Path -Path ( Split-Path $PSScriptRoot -Parent ) `
                               -ChildPath 'AuditPolicyResourceHelper.psm1') `
                               -Force
<#
    .SYNOPSIS
        Returns the current audit flag for the given subcategory.
    .PARAMETER Subcategory
        Specifies the subcategory to retrieve.
    .PARAMETER AuditFlag
        Specifies the audit flag to retrieve.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Security System Extension', 'System Integrity', 'IPsec Driver', 
        'Other System Events', 'Security State Change', 'Logon', 'Logoff', 'Account Lockout', 
        'IPsec Main Mode', 'IPsec Quick Mode', 'IPsec Extended Mode', 'Special Logon', 
        'Other Logon/Logoff Events', 'Network Policy Server', 'User / Device Claims', 
        'Group Membership', 'File System', 'Registry', 'Kernel Object', 'SAM', 
        'Certification Services', 'Application Generated', 'Handle Manipulation', 'File Share', 
        'Filtering Platform Packet Drop', 'Filtering Platform Connection', 
        'Other Object Access Events', 'Detailed File Share', 'Removable Storage', 
        'Central Policy Staging', 'Non Sensitive Privilege Use', 'Other Privilege Use Events', 
        'Sensitive Privilege Use', 'Process Creation', 'Process Termination', 'DPAPI Activity', 
        'RPC Events', 'Plug and Play Events', 'Authentication Policy Change', 
        'Authorization Policy Change', 'MPSSVC Rule-Level Policy Change', 
        'Filtering Platform Policy Change', 'Other Policy Change Events', 'Audit Policy Change', 
        'User Account Management', 'Computer Account Management', 'Security Group Management', 
        'Distribution Group Management', 'Application Group Management', 
        'Other Account Management Events', 'Directory Service Changes', 
        'Directory Service Replication', 'Detailed Directory Service Replication', 
        'Directory Service Access', 'Kerberos Service Ticket Operations', 
        'Other Account Logon Events', 'Kerberos Authentication Service', 'Credential Validation')]
        [System.String]
        $Subcategory,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Success', 'Failure')]
        [System.String]
        $AuditFlag
    )

    try
    {
        $currentAuditFlag = Get-AuditCategory -SubCategory $Subcategory
        Write-Verbose -Message ( $localizedData.GetAuditpolSubcategorySucceed -f $Subcategory, $AuditFlag )
    }
    catch
    {
        Write-Verbose -Message ( $localizedData.GetAuditPolSubcategoryFailed -f $Subcategory, $AuditFlag )
    }

    <# 
        The auditType property returned from Get-AuditCategory can be either 'Success', 
        'Failure', or 'Success and Failure'. Using the match operator will return the correct 
        state if both are set. 
    #>
    if ( $currentAuditFlag -match $AuditFlag )
    {
        $currentAuditFlag = $AuditFlag
        $ensure = 'Present'
    }
    else
    {
        $ensure = 'Absent'
    }

    return @{
        Subcategory = $Subcategory
        AuditFlag   = $currentAuditFlag 
        Ensure      = $ensure
    }
}

<#
    .SYNOPSIS
        Sets the audit flag for the given subcategory.
    .PARAMETER Subcategory
        Specifies the subcategory to set.
    .PARAMETER AuditFlag
        Specifies the audit flag to set.
    .PARAMETER Ensure
        Specifies the state of the audit flag provided.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Security System Extension', 'System Integrity', 'IPsec Driver', 
        'Other System Events', 'Security State Change', 'Logon', 'Logoff', 'Account Lockout', 
        'IPsec Main Mode', 'IPsec Quick Mode', 'IPsec Extended Mode', 'Special Logon', 
        'Other Logon/Logoff Events', 'Network Policy Server', 'User / Device Claims', 
        'Group Membership', 'File System', 'Registry', 'Kernel Object', 'SAM', 
        'Certification Services', 'Application Generated', 'Handle Manipulation', 'File Share', 
        'Filtering Platform Packet Drop', 'Filtering Platform Connection', 
        'Other Object Access Events', 'Detailed File Share', 'Removable Storage', 
        'Central Policy Staging', 'Non Sensitive Privilege Use', 'Other Privilege Use Events', 
        'Sensitive Privilege Use', 'Process Creation', 'Process Termination', 'DPAPI Activity', 
        'RPC Events', 'Plug and Play Events', 'Authentication Policy Change', 
        'Authorization Policy Change', 'MPSSVC Rule-Level Policy Change', 
        'Filtering Platform Policy Change', 'Other Policy Change Events', 'Audit Policy Change', 
        'User Account Management', 'Computer Account Management', 'Security Group Management', 
        'Distribution Group Management', 'Application Group Management', 
        'Other Account Management Events', 'Directory Service Changes', 
        'Directory Service Replication', 'Detailed Directory Service Replication', 
        'Directory Service Access', 'Kerberos Service Ticket Operations', 
        'Other Account Logon Events', 'Kerberos Authentication Service', 'Credential Validation')]
        [System.String]
        $Subcategory,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Success', 'Failure')]
        [System.String]
        $AuditFlag,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )

    try
    {
        Set-AuditCategory -SubCategory $Subcategory -AuditFlag $AuditFlag -Ensure $Ensure
        Write-Verbose -Message ( $localizedData.SetAuditpolSubcategorySucceed `
                        -f $Subcategory, $AuditFlag, $Ensure )
    }
    catch 
    {
        Write-Verbose -Message ( $localizedData.SetAuditpolSubcategoryFailed `
                        -f $Subcategory, $AuditFlag, $Ensure )
    }
}

<#
    .SYNOPSIS
        Tests the audit flag state for the given subcategory.
    .PARAMETER Subcategory
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
        [ValidateSet('Security System Extension', 'System Integrity', 'IPsec Driver', 
        'Other System Events', 'Security State Change', 'Logon', 'Logoff', 'Account Lockout', 
        'IPsec Main Mode', 'IPsec Quick Mode', 'IPsec Extended Mode', 'Special Logon', 
        'Other Logon/Logoff Events', 'Network Policy Server', 'User / Device Claims', 
        'Group Membership', 'File System', 'Registry', 'Kernel Object', 'SAM', 
        'Certification Services', 'Application Generated', 'Handle Manipulation', 'File Share', 
        'Filtering Platform Packet Drop', 'Filtering Platform Connection', 
        'Other Object Access Events', 'Detailed File Share', 'Removable Storage', 
        'Central Policy Staging', 'Non Sensitive Privilege Use', 'Other Privilege Use Events', 
        'Sensitive Privilege Use', 'Process Creation', 'Process Termination', 'DPAPI Activity', 
        'RPC Events', 'Plug and Play Events', 'Authentication Policy Change', 
        'Authorization Policy Change', 'MPSSVC Rule-Level Policy Change', 
        'Filtering Platform Policy Change', 'Other Policy Change Events', 'Audit Policy Change', 
        'User Account Management', 'Computer Account Management', 'Security Group Management', 
        'Distribution Group Management', 'Application Group Management', 
        'Other Account Management Events', 'Directory Service Changes', 
        'Directory Service Replication', 'Detailed Directory Service Replication', 
        'Directory Service Access', 'Kerberos Service Ticket Operations', 
        'Other Account Logon Events', 'Kerberos Authentication Service', 'Credential Validation')]     
        [System.String]
        $Subcategory,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Success', 'Failure')]
        [System.String]
        $AuditFlag,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )

    [System.Boolean] $returnValue

    try
    {
        $currentAuditFlag = Get-AuditCategory -SubCategory $Subcategory
        Write-Verbose -Message ( $localizedData.GetAuditpolSubcategorySucceed -f $Subcategory, $AuditFlag )
    }
    catch
    {
        Write-Verbose -Message ( $localizedData.GetAuditPolSubcategoryFailed -f $Subcategory, $AuditFlag )
    }

    # If the setting should be present look for a match, otherwise look for a notmatch
    if ( $Ensure -eq 'Present' )
    {
        $returnValue = $currentAuditFlag -match $AuditFlag
    }
    else
    { 
        $returnValue = $currentAuditFlag -notmatch $AuditFlag
    }

    <# 
        The audit type can be true in either a match or non-match state. If the audit type 
        matches the ensure property return the setting correct message, else return the 
        setting incorrect message
    #>
    if ( $returnValue )
    {
        Write-Verbose -Message ( $localizedData.TestAuditpolSubcategoryCorrect `
                        -f $Subcategory, $AuditFlag, $Ensure )
    }
    else
    {
        Write-Verbose -Message ( $localizedData.TestAuditpolSubcategoryIncorrect `
                       -f $Subcategory, $AuditFlag, $Ensure )
    }

    $returnValue
}

#---------------------------------------------------------------------------------------------------
# Support functions to handle auditpol I/O

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
        [Parameter(Mandatory = $true)]
        [System.String]
        $SubCategory
    )
    <#
        When PowerShell cmdlets are released for individual audit policy settings a condition 
        will be placed here to use native PowerShell cmdlets to set the option details. 
    #>
    # get the auditpol raw csv output
    $returnCsv = Invoke-AuditPol -Command 'Get' -subCommand "Subcategory:""$SubCategory"""
    
    # split the details into an array
    $subcategoryFlags = ( $returnCsv[2] ) -Split ','

    # remove the spaces from 'Success and Failure' to prevent any wierd string problems later
    return $subcategoryFlags[4] -replace ' ',''
}


<#
    .SYNOPSIS 
        Sets the audit flag state for a specifc subcategory. 
    .DESCRIPTION
        Calls the private function to execute a set operation on the given subcategory
    .PARAMETER SubCategory
        The name of the audit subcategory to set
    .PARAMETER AuditFlag
        The specifc flag to set (Success|Failure)
    .PARAMETER Ensure 
        The action to take on the flag
    .EXAMPLE
        Set-AuditCategory -SubCategory 'Logon' -AuditFlag 'Success' -Ensure 'Present'
#>
function Set-AuditCategory
{
    [CmdletBinding( SupportsShouldProcess=$true )]
    param
    (
        [Parameter( Mandatory = $true )]
        [System.String]
        $SubCategory,
        
        [Parameter( Mandatory = $true )]
        [ValidateSet( 'Success','Failure' )]
        [System.String]
        $AuditFlag,
        
        [Parameter( Mandatory = $true )]
        [System.String]
        $Ensure
    )

    <#
        When PowerShell cmdlets are released for individual audit policy settings a condition 
        will be placed here to use native PowerShell cmdlets to set the option details. 
    #>
    if ( $pscmdlet.ShouldProcess( "$SubCategory","Set AuditFlag '$AuditFlag'" ) ) 
    {
        # translate $ensure=present to enable and $ensure=absent to disable
        $auditState = @{
            'Present' = 'enable'
            'Absent'  = 'disable'
        }
                
        # Create the line needed for auditpol to set the category flag
        if ( $AuditFlag -eq 'Success' )
        { 
            [String[]] $subcommand = @( "Subcategory:""$SubCategory""", "/success:$($auditState[$Ensure])" )
        }
        else   
        {
            [String[]] $subcommand = @( "Subcategory:""$SubCategory""", "/failure:$($auditState[$Ensure])" )
        }
                    
        Invoke-AuditPol -Command 'Set' -subCommand $subcommand | Out-Null
    }
}

Export-ModuleMember -Function *-TargetResource
