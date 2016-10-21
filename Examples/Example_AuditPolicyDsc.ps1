<#
    This example will enable Base Directory auditing and set the Logon Success and Failure flags 
    on the localhost. 
    To use this example, run it using PowerShell.
#>
Configuration SetAuditPolicy
{
    param
    (
        [String[]] $NodeName = $env:COMPUTERNAME
    )    
   
    Import-DscResource -ModuleName AuditPolicyDsc

    Node $NodeName

    {
        AuditPolicyOption AuditBaseDirectories
        {
            Name  = 'AuditBaseDirectories'
            Value = 'Enabled'
        }

        AuditPolicySubcategory LogonSuccess
        {
            Subcategory = 'Logon'
            AuditFlag   = 'Success'
            Ensure      = 'Absent' 
        } 

        AuditPolicySubcategory LogonFailure
        {
            Subcategory = 'Logon'
            AuditFlag   = 'Failure'
            Ensure      = 'Present' 
        }
    }
}

SetAuditPolicy -NodeName 'localhost'

Start-DscConfiguration -Path .\SetAuditPolicy -Wait -Verbose -Force
