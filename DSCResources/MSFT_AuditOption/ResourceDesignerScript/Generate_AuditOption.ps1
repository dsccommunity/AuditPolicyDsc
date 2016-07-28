
$Name = New-xDscResourceProperty -Name Name -Type String -Attribute Key -Description "Sets the audit policy for the CrashOnAuditFail, FullPrivilegeAuditing, AuditBaseObjects, or AuditBaseDirectories options." `
-ValidateSet "CrashOnAuditFail","FullPrivilegeAuditing","AuditBaseObjects","AuditBaseDirectories"

$Value = New-xDscResourceProperty -Name Value -Type String -Attribute Write -Description "Describe the auditpol option state" `
-ValidateSet "Enabled","Disabled"


$AuditPol = @{
    Name = 'MSFT_AuditOption'
    Property = $Name,$Value
    FriendlyName = 'AuditOption'
    ModuleName = 'AuditPolicyDsc'
    Path = 'C:\Program Files\WindowsPowerShell\Modules\'
}

New-xDscResource @AuditPol
