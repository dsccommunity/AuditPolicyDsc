<#
    This example will apply the audit policy settings in the csv to the localhost. 
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
            CsvPath = "C:\data\AuditPolBackup.csv"
        }
    
    }
}

Sample_AuditPolicyCsv
