<# $cred = get-credential
$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName="*"
            #INSECURE - DO NOT REPLICATE - FOR TEST PURPOSES ONLY
            #LITERALLY EXPOSES PASSWORDS IN PLAINTEXT. 
            PSDscAllowPlainTextPassword = $true
        },
        @{
            NodeName = "localhost"
        }
        )
}
#>
Configuration AuditPolicy
{
    Import-DscResource -ModuleName xAuditPolicy
    node localhost
    {
        xAuditCsv auditPolicy
        {
            CsvPath = "C:\Users\Administrator\Documents\examples\test.csv"

        }
    
    }
}
AuditPolicy

Invoke-DscResource xAuditCsv -Method Set -Property @{CsvPath = "C:\Users\Administrator\Documents\examples\audit.csv"} -ModuleName xAuditPolicy -verbose

Start-DscConfiguration -Wait -verbose -path .\AuditPolicy -force
