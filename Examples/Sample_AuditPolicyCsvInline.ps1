<#
    This example will apply the audit policy settings in the CSV file to the target node. The csv
    file content from C:\data\AuditPolBackup.csv is loaded into the configuration (MOF) as raw
    strings and does not require an external file on the target node. The raw strings are required
    and not the Csv objects, so it is important to use Get-Content and not Import-Csv when
    retrieving the backup data. Get-Content also reduces the size of the MOF.
    For external Csv files see Sample_AuditPolicyCsvExternal.
    To use this example, run it using PowerShell.
#>
Configuration Sample_AuditPolicyCsvInline
{
    param
    (
        [String] $NodeName = 'localhost'
    )

    Import-DscResource -ModuleName AuditPolicyDsc

    Node $NodeName
    {
        AuditPolicyCsv auditPolicy
        {
            IsSingleInstance = 'Yes'
            CsvPath = ( Get-Content -Path "C:\data\AuditPolBackup.csv" )
        }
    }
}

Sample_AuditPolicyCsvInline
