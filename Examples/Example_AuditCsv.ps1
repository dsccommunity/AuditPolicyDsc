Configuration AuditPolicy
{
    Import-DscResource -ModuleName xAuditPolicy
    node localhost
    {
        xAuditCsv auditPolicy
        {
            CsvPath = "C:\Users\Administrator\Documents\audit.csv"
        }
    
    }
}
AuditPolicy

invoke-dscresource xAuditCsv -Method Test -Property @{CsvPath = "C:\Users\Administrator\Documents\audit.csv"} -ModuleName xAuditPolicy -verbose
invoke-dscresource xAuditCsv -Method Get -Property @{CsvPath = "C:\Users\Administrator\Documents\audit.csv"} -ModuleName xAuditPolicy -verbose
Start-DscConfiguration -Wait -verbose -path .\AuditPolicy -force