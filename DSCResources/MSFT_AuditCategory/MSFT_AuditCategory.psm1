
Import-Module $PSScriptRoot\..\Helper.psm1 -Verbose:0

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
        [ValidateSet('Success','Failure')]
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
        [ValidateSet('Success','Failure')]
        [System.String]
        $AuditFlag,

        [ValidateSet('Present','Absent')]
        [System.String]
        $Ensure
    )

    try
    {
        Set-AuditCategory -SubCategory $Subcategory -AuditFlag $AuditFlag -Ensure $Ensure
        Write-Verbose ( $localizedData.SetAuditpolSubcategorySucceed `
                        -f $Subcategory,$AuditFlag,$Ensure )
    }
    catch 
    {
        Write-Verbose ( $localizedData.SetAuditpolSubcategoryFailed `
                        -f $Subcategory,$AuditFlag,$Ensure )
    }
}


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
        [ValidateSet('Success','Failure')]
        [System.String]
        $AuditFlag,

        [ValidateSet('Present','Absent')]
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
                        -f $Subcategory,$AuditFlag,$Ensure )
    }
    else
    {
        Write-Verbose ( $localizedData.TestAuditpolSubcategoryIncorrect `
                       -f $Subcategory,$AuditFlag,$Ensure )
    }

    $return
}

Export-ModuleMember -Function *-TargetResource
