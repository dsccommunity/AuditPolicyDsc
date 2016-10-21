
$DscResourcePropertyName = @{
    Name = 'Name'
    Type = 'String'
    Attribute = 'Key'
    Description = 'Sets the audit policy options.'
    ValidateSet = @('CrashOnAuditFail', 'FullPrivilegeAuditing', 'AuditBaseObjects', 
    'AuditBaseDirectories')
}

$Name = New-xDscResourceProperty @DscResourcePropertyName


$DscResourcePropertyValue = @{
    Name = 'Value'
    Type = 'String' 
    Attribute = 'Write' 
    Description = 'Describe the auditpol option state'
    ValidateSet = @('Enabled','Disabled')   
}

$Value = New-xDscResourceProperty @DscResourcePropertyValue


$AuditPol = @{
    Name = 'MSFT_AuditOption'
    Property = $Name,$Value
    FriendlyName = 'AuditOption'
    ModuleName = 'AuditPolicyDsc'
    Path = 'C:\Program Files\WindowsPowerShell\Modules\'
}

New-xDscResource @AuditPol
