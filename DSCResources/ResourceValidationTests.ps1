If(!(Get-Module xDscResourceDesigner -ListAvailable))
{
    throw "xDscResourceDesigner not found!"
}

Write-Host "Testing xAuditCategory" -ForegroundColor Yellow
Test-xDscResource $PSScriptRoot\MSFT_xAuditCategory -Verbose
Test-xDscSchema $PSScriptRoot\MSFT_xAuditCategory\MSFT_xAuditCategory.schema.mof -Verbose


Write-Host "Testing xAuditCategory" -ForegroundColor Yellow
Test-xDscResource $PSScriptRoot\MSFT_xAuditOption -Verbose
Test-xDscSchema $PSScriptRoot\MSFT_xAuditOption\MSFT_xAuditOption.schema.mof -Verbose