$TestAuditPolicySubCategory = @{
    Subcategory     = 'Credential Validation'
    AuditFlag       = 'Failure'
    AuditFlagEnsure = 'Present'
}

configuration 'MSFT_AuditPolicySubcategory_Config' {
    
    Import-DscResource -ModuleName 'AuditPolicyDsc'
    
    node localhost {
       
        AuditPolicySubcategory Integration_Test
        {
            Subcategory = $TestAuditPolicySubCategory.Subcategory
            AuditFlag   = $TestAuditPolicySubCategory.AuditFlag
            Ensure      = $TestAuditPolicySubCategory.AuditFlagEnsure
        }
    }
}
