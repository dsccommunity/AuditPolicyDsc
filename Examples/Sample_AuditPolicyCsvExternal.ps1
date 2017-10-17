<#
    This example will apply the audit policy settings in the CSV file to the target node. The csv 
    file must be located on the target node at C:\data\AuditPolBackup.csv using the File resource 
    or other automated method. For inline Csv see Sample_AuditPolicyCsvInline
    To use this example, run it using PowerShell.
#>
Configuration Sample_AuditPolicyCsv
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
            CsvPath = "C:\data\AuditPolBackup.csv"
        }
    }
}

Sample_AuditPolicyCsv
