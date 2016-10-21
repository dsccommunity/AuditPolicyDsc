<#
.Synopsis
   DSC Configuration Template for DSC Resource Integration tests.
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Integration\ folder and rename MSFT_<ResourceName>.config.ps1 (e.g. MSFT_xFirewall.config.ps1)
     2. Customize TODO sections.

.NOTES
#>


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

