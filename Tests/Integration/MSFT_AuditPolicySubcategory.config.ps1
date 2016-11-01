# Integration Test Config Template Version 1.0.0

configuration 'MSFT_AuditPolicySubcategory_Config' 
{
    param 
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Subcategory,
        
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
        AuditPolicySubcategory Integration_Test
        {
            Subcategory = $Subcategory
            AuditFlag   = $AuditFlag
            Ensure      = $AuditFlagEnsure
        }
    }
}
