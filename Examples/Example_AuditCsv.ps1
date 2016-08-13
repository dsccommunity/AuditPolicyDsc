Configuration AuditPolicy
{
    Import-DscResource -ModuleName xAuditPolicy
    node localhost
    {
        xAuditCsv auditPolicy
        {
            CsvPath = "C:\Users\Administrator\Documents\test.csv"
        }
    
    }
}
AuditPolicy

#Test.csv works
Start-DscConfiguration -Wait -verbose -path .\AuditPolicy -force
#This should return false
invoke-dscresource xAuditCsv -Method Test -Property @{CsvPath = "C:\Users\Administrator\Documents\audit.csv"} -ModuleName xAuditPolicy
#This should return a blank CSV path
invoke-dscresource xAuditCsv -Method Get -Property @{CsvPath = "C:\Users\Administrator\Documents\audit.csv"} -ModuleName xAuditPolicy -verbose
#This should return true
invoke-dscresource xAuditCsv -Method Test -Property @{CsvPath = "C:\Users\Administrator\Documents\test.csv"} -ModuleName xAuditPolicy
#This should return the CSV path
invoke-dscresource xAuditCsv -Method Get -Property @{CsvPath = "C:\Users\Administrator\Documents\test.csv"} -ModuleName xAuditPolicy -verbose
