# Integration Test Config Template Version 1.0.0

configuration 'MSFT_AuditPolicyOption_config'
{
    param 
    (
        [Parameter(Mandatory)]
        [System.String]
        $OptionName,
        
        [Parameter(Mandatory)]
        [System.String]
        $OptionValue
    )

    Import-DscResource -ModuleName 'AuditPolicyDsc'

    node localhost 
    {
        AuditPolicyOption Integration_Test 
        {
            Name  = $OptionName
            Value = $OptionValue
        }
    }
}
