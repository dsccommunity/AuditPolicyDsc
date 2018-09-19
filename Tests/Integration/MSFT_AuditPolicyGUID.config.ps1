
configuration 'MSFT_AuditPolicyGUID_Config' 
{
    param 
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $AuditFlag,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AuditFlagEnsure
    )

    Import-DscResource -ModuleName 'AuditPolicyDsc'
    
    node localhost 
    {
        AuditPolicyGUID Integration_Test
        {
            Name      = $Name
            AuditFlag = $AuditFlag
            Ensure    = $AuditFlagEnsure
        }
    }
}
