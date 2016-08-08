$CsvPath = New-xDscResourceProperty -Name CsvPath -Type String -Attribute "Key" -Description "Path to a .CSV backup of Auditing settings"

$AuditPol = @{
    Name = 'MSFT_xAuditCsv'
    Property = $CsvPath
    FriendlyName = 'xAuditCsv'
    ModuleName = 'xAuditPolicy'
    Path = 'C:\git\'
}

New-xDscResource @AuditPol
