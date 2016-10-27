$TestAuditPolicyOption = @{
    Name  = 'AuditBaseDirectories'
    Value = 'Enabled'
}

configuration 'MSFT_AuditPolicyOption_config' {

    Import-DscResource -ModuleName 'AuditPolicyDsc'

    node localhost {

        AuditPolicyOption Integration_Test 
        {
            Name  = $TestAuditPolicyOption.Name
            Value = $TestAuditPolicyOption.Value
        }
    }
}
