
configuration 'MSFT_AuditPolicyOption_config' {

    Import-DscResource -ModuleName 'AuditPolicyDsc'

    node localhost {

        AuditPolicyOption Integration_Test 
        {
            Name  = $optionName
            Value = $optionValue
        }
    }
}
