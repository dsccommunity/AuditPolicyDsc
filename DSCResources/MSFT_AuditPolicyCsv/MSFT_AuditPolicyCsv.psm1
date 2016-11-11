
Import-Module -Name (Join-Path -Path ( Split-Path $PSScriptRoot -Parent ) `
                               -ChildPath 'AuditPolicyResourceHelper\AuditPolicyResourceHelper.psm1') `
                               -Force                              

# Localized messages for Write-Verbose statements in this resource
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_AuditPolicyCsv'

<#
    .SYNOPSIS
        Gets the current audit policy for the node.
    .PARAMETER CsvPath
        Specifies the path to store the exported results.
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
        Specifies the path to store the exported results.
    .PARAMETER Force
        Clears the current audit policy and applies the desired state policy.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $CsvPath,

        [parameter()]
        [System.Boolean]
        $Force
    )

    if (Test-Path $CsvPath)
    {
        try
        {
            if ($Force)
            {
                # Need to import settings, null them out and reset.
            }
            else
            {
                Invoke-SecurityCmdlet -Action "Import" -Path $CsvPath | Out-Null
                Write-Verbose -Message ($localizedData.ImportSucceeded -f $CsvPath)    
            }
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
        Specifies the path to store the exported results.
    .PARAMETER Force
        Clears the current audit policy and applies the desired state policy.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $CsvPath,

        [parameter()]
        [System.Boolean]
        $Force
    )

    if (Test-Path $CsvPath)
    {
        $targetResourceReturn = (Get-TargetResource -CsvPath $CsvPath).CsvPath

        <# 
            Ignore "Machine Name" since it will cause a failure if the CSV was generated on a 
            different machine.

            Compare GUIDs and values to see if they are the same
            Options have no GUIDs, just object names...

            Clearing settings just writes "0"s on top, so discard those from consideration
        #>

        $currentAuditPolicy = Import-Csv -Path $targetResourceReturn |
            Where-Object  { $_."Setting Value" -ne 0 -and $_."Setting Value" -ne ""} |
            Select-Object -Property "Subcategory GUID", "Setting Value"

        $desiredAuditPolicy = Import-Csv -Path $CsvPath |
            Where-Object { $_."Setting Value" -ne 0 -and $_."Setting Value" -ne ""} |
            Select-Object -Property "Subcategory GUID", "Setting Value"
        
        $compareResults = Compare-Object -ReferenceObject $desiredAuditPolicy -DifferenceObject $currentAuditPolicy

        if ($null -ne $compareResults)
        {
            #TODO: branch on $force
            foreach ($entry in $compareResults)
            {
                Write-Verbose -Message ($localizedData.testCsvFailed -f $($entry.InputObject.'Subcategory GUID'))
            }
            return $false
        }
        else
        {
            # Since no changes are needed, cleanup the temp file 
            Remove-BackupFile -CsvPath $targetResourceReturn
            Write-Verbose -Message $localizedData.testCsvSuccess
            return $true
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
            Invoke-AuditPol -Command Restore -SubCommand "file:$path"
        }
        else
        {
            Invoke-AuditPol -Command Backup -SubCommand "file:$path"
        }
    }
    else
    {
        Import-Module -Name SecurityCmdlets

        if ($Action -eq "Import")
        {
            Restore-AuditPolicy $Path | Out-Null
        }
        elseif ($Action -eq "Export")
        {
            #no force option on Backup, manually check for file and delete it so we can write back again
            if (Test-Path $path)
            {
                Remove-Item $path -force
            }
            Backup-AuditPolicy $Path | Out-Null
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
    [OutputType([System.Collections.Hashtable])]
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

Export-ModuleMember -Function *-TargetResource

## TODO Cleanup the temp files