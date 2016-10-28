
Import-Module $PSScriptRoot\..\Helper.psm1

<#
    .SYNOPSIS
    Returns the current audit flag for the given subcategory.
    .PARAMETER Subcategory
    Specifies the subcategory to get.
    .PARAMETER AuditFlag
    Specifies the audit flag to get.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
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

        [parameter(Mandatory = $true)]
        [ValidateSet('Success', 'Failure')]
        [System.String]
        $AuditFlag
    )

    try
    {
        $currentAuditFlag = Get-AuditCategory -SubCategory $Subcategory
        Write-Verbose ( $localizedData.GetAuditpolSubcategorySucceed -f $Subcategory, $AuditFlag )
    }
    catch
    {
        Write-Verbose ( $localizedData.GetAuditPolSubcategoryFailed -f $Subcategory, $AuditFlag )
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

    $returnValue = @{
        Subcategory = $Subcategory
        AuditFlag   = $currentAuditFlag 
        Ensure      = $ensure
    }

    $returnValue
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
        [parameter(Mandatory = $true)]
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

        [parameter(Mandatory = $true)]
        [ValidateSet('Success', 'Failure')]
        [System.String]
        $AuditFlag,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )

    try
    {
        Set-AuditCategory -SubCategory $Subcategory -AuditFlag $AuditFlag -Ensure $Ensure
        Write-Verbose ( $localizedData.SetAuditpolSubcategorySucceed `
                        -f $Subcategory, $AuditFlag, $Ensure )
    }
    catch 
    {
        Write-Verbose ( $localizedData.SetAuditpolSubcategoryFailed `
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
        [parameter(Mandatory = $true)]
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

        [parameter(Mandatory = $true)]
        [ValidateSet('Success', 'Failure')]
        [System.String]
        $AuditFlag,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )

    try
    {
        $currentAuditFlag = Get-AuditCategory -SubCategory $Subcategory
        Write-Verbose ( $localizedData.GetAuditpolSubcategorySucceed -f $Subcategory, $AuditFlag )
    }
    catch
    {
        Write-Verbose ( $localizedData.GetAuditPolSubcategoryFailed -f $Subcategory, $AuditFlag )
    }

    # if the setting should be present look for a match, otherwise look for a notmatch
    if ( $Ensure -eq 'Present' )
    {
        $return = $currentAuditFlag -match $AuditFlag
    }
    else
    { 
        $return = $currentAuditFlag -notmatch $AuditFlag
    }

    <# 
        the audit type can be true in either a match or non-match state. If the audit type 
        matches the ensure property return the setting correct message, else return the 
        setting incorrect message
    #>
    if ( $return )
    {
        Write-Verbose ( $localizedData.TestAuditpolSubcategoryCorrect `
                        -f $Subcategory, $AuditFlag, $Ensure )
    }
    else
    {
        Write-Verbose ( $localizedData.TestAuditpolSubcategoryIncorrect `
                       -f $Subcategory, $AuditFlag, $Ensure )
    }

    $return
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
    $auditpolReturn = Invoke-AuditPol -Command "Get" -SubCommand "Subcategory:""$SubCategory"""
    
    $split = ( $auditpolReturn[2] ) -split ','

    # remove the spaces from 'Success and Failure' to prevent any wierd string problems later
    [string] $auditFlag = $split[4] -replace ' ',''
    
    $auditFlag
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
}

Export-ModuleMember -Function *-TargetResource
