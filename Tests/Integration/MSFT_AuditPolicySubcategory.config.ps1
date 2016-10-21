
configuration 'MSFT_AuditPolicySubcategory_Config' {
    
    Import-DscResource -ModuleName 'AuditPolicyDsc'
    
    node localhost {
       
        AuditPolicySubcategory Integration_Test
        {
            Subcategory = $Subcategory
            AuditFlag   = $AuditFlag
            Ensure      = $AuditFlagEnsure
        }
    }
}
