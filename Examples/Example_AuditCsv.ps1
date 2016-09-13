Configuration AuditPolicy
{
    Import-DscResource -ModuleName xAuditPolicy
    node localhost
    {
        xAuditCsv auditPolicy
        {
            CsvPath = "C:\Users\Administrator\Documents\examples\audit.csv"
        }
    
    }
}
AuditPolicy

#Invoke-DscResource xAuditCsv -Method Set -Property @{CsvPath = "C:\Users\Administrator\Documents\examples\test.csv"} -ModuleName xAuditPolicy -verbose
#Test.csv works
Start-DscConfiguration -Wait -verbose -path .\AuditPolicy -force
#This should return false
#invoke-dscresource xAuditCsv -Method Test -Property @{CsvPath = "C:\Users\Administrator\Documents\examples\audit.csv"} -ModuleName xAuditPolicy
#This should return a blank CSV path
#invoke-dscresource xAuditCsv -Method Get -Property @{CsvPath = "C:\Users\Administrator\Documents\examples\audit.csv"} -ModuleName xAuditPolicy 
#This should return true
#invoke-dscresource xAuditCsv -Method Test -Property @{CsvPath = "C:\Users\Administrator\Documents\examples\test.csv"} -ModuleName xAuditPolicy #-verbose
#This should return the CSV path
#invoke-dscresource xAuditCsv -Method Get -Property @{CsvPath = "C:\Users\Administrator\Documents\examples\test.csv"} -ModuleName xAuditPolicy 
