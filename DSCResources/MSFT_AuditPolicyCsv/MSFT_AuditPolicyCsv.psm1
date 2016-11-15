
Import-Module -Name (Join-Path -Path ( Join-Path -Path ( Split-Path $PSScriptRoot -Parent ) `
                                                 -ChildPath 'AuditPolicyResourceHelper' ) `
                               -ChildPath 'AuditPolicyResourceHelper.psm1')                         

# Localized messages for Write-Verbose statements in this resource
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_AuditPolicyCsv'

<#
    .SYNOPSIS
        Gets the current audit policy for the node.
    .PARAMETER CsvPath
        This parameter is ignored in the Get operation, but does return the path to the 
        backup of the current audit policy settings. 
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $CsvPath
    )
    
    $tempFile = ([system.IO.Path]::GetTempFileName()).Replace('.tmp','.csv')

    try
    {
        Write-Verbose -Message ($localizedData.BackupFilePath -f $tempFile)
        Invoke-SecurityCmdlet -Action "Export" -Path $tempFile 
    }
    catch
    {
        Write-Verbose -Message ($localizedData.ExportFailed -f $tempFile)
    }

    return @{
        CsvPath = $tempFile
    }
}

<#
    .SYNOPSIS
        Sets the current audit policy for the node.
    .PARAMETER CsvPath
        Specifies the path to desired audit policy settings to apply to the node.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $CsvPath
    )

    if (Test-Path $CsvPath)
    {
        try
        {
            Invoke-SecurityCmdlet -Action "Import" -Path $CsvPath | Out-Null
            Write-Verbose -Message ($localizedData.ImportSucceeded -f $CsvPath)    
        }
        catch
        {
            Write-Verbose -Message ($localizedData.ImportFailed -f $CsvPath)
        }
    }
    else
    {
        Write-Verbose -Message ($localizedData.FileNotFound -f $CsvPath)
    }
}

<#
    .SYNOPSIS
        Tests the current audit policy against the desired policy.
    .PARAMETER CsvPath
        Specifies the path to desired audit policy settings to test against the node.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $CsvPath
    )

    if (Test-Path $CsvPath)
    {
        # The path to the CSV that contains the current audit policy backup. 
        $currentAuditPolicyBackupPath = (Get-TargetResource -CsvPath $CsvPath).CsvPath
        
        $currentAuditPolicy = Import-Csv -Path $currentAuditPolicyBackupPath | 
            Select-Object -Property Subcategory, @{
                'Name' = 'Value';
                'Expression' = {$_.'Setting Value'}
            } 
        
        $desiredAuditPolicy = Import-Csv -Path $CsvPath | 
            Select-Object -Property Subcategory, @{
                'Name' = 'Value';
                'Expression' = {$_.'Setting Value'}
            }

        # Assume in desired state until proven false.
        $inDesiredState = $true

        foreach ($desiredAuditPolicySetting in $desiredAuditPolicy)
        {
            $currentAuditPolicySetting = $currentAuditPolicy.Where({
                $_.Subcategory -eq $desiredAuditPolicySetting.Subcategory
            })

            if ($desiredAuditPolicySetting.Value -ne $currentAuditPolicySetting.Value)
            {
                Write-Verbose -Message ($localizedData.testCsvFailed -f 
                    $desiredAuditPolicySetting.Subcategory)
                    
                $inDesiredState = $false
            }
            else 
            {
                Write-Verbose -Message ($localizedData.testCsvSucceed -f 
                    $desiredAuditPolicySetting.Subcategory)
            }
        }

        # Cleanup the temp file, since it is no longer needed. 
        Remove-BackupFile -CsvPath $currentAuditPolicyBackupPath

        if ($inDesiredState)
        {            
            return $true
        }
        else
        {
            return $false
        }
    }
    else
    {
        Write-Verbose -Message ($localizedData.FileNotFound -f $CsvPath)
        return $false
    }
}

<#
    .SYNOPSIS 
        Helper function to use SecurityCmdlet modules if present. If not, go through AuditPol.exe.
    .PARAMETER Action 
        The action to take, either Import or Export. Import will clear existing policy before writing.
    .PARAMETER Path 
        The path to a CSV file to either create or import.  
    .EXAMPLE
        Invoke-SecurityCmdlet -Action Import -Path .\test.csv
#>
function Invoke-SecurityCmdlet
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Import","Export")]
        [System.String]
        $Action,
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path 
    )

    # Test if security cmdlets are present. If not, use auditpol directly.
    if ($null -eq (Get-Module -ListAvailable -Name "SecurityCmdlets"))
    {
        Write-Verbose -Message ($localizedData.CmdletsNotFound)

        if ($Action -ieq "Import")
        {
            Invoke-AuditPol -Command Restore -SubCommand "file:$Path"
        }
        else
        {
            Invoke-AuditPol -Command Backup -SubCommand "file:$Path"
        }
    }
    else
    {
        Import-Module -Name SecurityCmdlets

        if ($Action -ieq "Import")
        {
            Restore-AuditPolicy -Path $Path | Out-Null
        }
        elseif ($Action -ieq "Export")
        {
            #no force option on Backup, manually check for file and delete it so we can write back again
            if (Test-Path -Path $Path)
            {
                Remove-Item -Path $Path -Force
            }
            Backup-AuditPolicy -Path $Path | Out-Null
        }
    }
}

<#
    .SYNOPSIS
        Gets the current audit policy for the node.
    .PARAMETER CsvPath
        Specifies the path to store the exported results.
#>
function Remove-BackupFile
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $CsvPath
    )

    try 
    {
        Remove-Item -Path $CsvPath
        Write-Verbose -Message ($localizedData.RemoveFile -f $CsvPath)
    }
    catch 
    {
        Write-Error $error[0]
    }
}
