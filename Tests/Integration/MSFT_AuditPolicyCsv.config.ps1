
configuration 'MSFT_AuditPolicyCsv_config'
{
    param 
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $CsvPath
    )

    Import-DscResource -ModuleName 'AuditPolicyDsc'

    node localhost 
    {
        AuditPolicyCsv Integration_Test 
        {
            CsvPath  = $CsvPath
        }
    }
}
