
Configuration AuditPolicy
{
    Import-DscResource -ModuleName AuditPolicyDsc

    AuditOption AuditBaseDirectories
    {
        Name  = 'AuditBaseDirectories'
        Value = 'Enabled'
    }

    AuditCategory LogonSuccess
    {
        Subcategory = 'Logon'
        AuditFlag   = 'Success'
        Ensure      = 'Absent' 
    } 

    AuditCategory LogonFailure
    {
        Subcategory = 'Logon'
        AuditFlag   = 'Failure'
        Ensure      = 'Present' 
    } 
}

AuditPolicy

# Test-DscConfiguration -Path .\AuditPolicy

# Get-DscConfiguration

# Start-DscConfiguration -Path .\AuditPolicy -Wait -Verbose -Force
