
$Resource = New-xDscResourceProperty -Name Resource -Type String -Attribute Key -Description "The resource for which object access auditing is being configured." `
-ValidateSet "File","Key"

$User = New-xDscResourceProperty -Name User -Type String -Attribute Key -Description "Specifies a user or group the SACL will apply to." `

$Event = New-xDscResourceProperty -Name Event -Type String -Attribute Required -Description "The type of auditing to apply to the user" `
-ValidateSet "Success","Failure","SuccessAndFailure"

$Access = New-xDscResourceProperty -Name Access -Type String -Attribute Write -Description "Specifies a File permission mask" `
-ValidateSet "FILE_GENERIC_READ","FILE_GENERIC_WRITE","FILE_GENERIC_EXECUTE","FILE_ALL_ACCESS","SYNCHRONIZE","WRITE_OWNER","WRITE_DAC",
"READ_CONTROL","DELETE","FILE_WRITE_ATTRIBUTES","FILE_READ_ATTRIBUTES","FILE_DELETE_CHILD","FILE_EXECUTE","FILE_WRITE_EA","FILE_READ_EA",
"FILE_APPEND_DATA","FILE_WRITE_DATA","FILE_READ_DATA","KEY_READ","KEY_WRITE","KEY_READ","KEY_ALL_ACCESS","KEY_CREATE_LINK","KEY_NOTIFY",
"KEY_ENUMERATE_SUB_KEYS","KEY_CREATE_SUB_KEY","KEY_SET_VALUE","KEY_QUERY_VALUE"

$Ensure = New-xDscResourceProperty -Name Ensure -Type String -Attribute Write -Description "Describe the setting state" `
-ValidateSet "Present","Absent"

$AuditPol = @{
    Name = 'MSFT_xAuditGlobalAccess'
    Property = $Resource,$User,$Event,$Access,$Ensure
    FriendlyName = 'xAuditGlobalAccess'
    ModuleName = 'xAuditPolicy'
    Path = 'C:\Program Files\WindowsPowerShell\Modules\'
}

New-xDscResource @AuditPol
