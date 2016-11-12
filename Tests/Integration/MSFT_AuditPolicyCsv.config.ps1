
configuration 'MSFT_AuditPolicyCsv_config'
{
    param 
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $CsvPath,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $Force
    )

    Import-DscResource -ModuleName 'AuditPolicyDsc'

    node localhost 
    {
        AuditPolicyCsv Integration_Test 
        {
            CsvPath = $CsvPath
            Force   = $Force
        }
    }
}
