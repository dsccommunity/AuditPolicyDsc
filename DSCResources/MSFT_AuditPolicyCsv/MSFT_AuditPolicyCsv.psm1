
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
        $currentAuditPolicy = @{}
        $desiredAuditPolicy = @{}

        Import-Csv -Path (Get-TargetResource -CsvPath $CsvPath).CsvPath | Foreach-Object {
            $currentAuditPolicy.Add($_.Subcategory ,$_."Setting Value")
        }

        Import-Csv -Path $CsvPath | Foreach-Object {
            $desiredAuditPolicy.Add($_.Subcategory ,$_."Setting Value")
        }

        # Assume in desired state until proven false.
        $inDesiredState = $true

        # Loop throgh the list of desired settings
        foreach ($auditPolicySetting in $desiredAuditPolicy.GetEnumerator()) 
        {
            if (-not (Test-AuditFlagState `
                        -CurrentSetting $currentAuditPolicy[$auditPolicySetting.Key] `
                        -DesiredSetting $auditPolicySetting.Value `
                        -Force:$Force)
            )
            {
                Write-Verbose -Message ($localizedData.testCsvFailed -f $auditPolicySetting.Key)
                    
                $inDesiredState = $false
            }
        }

        if ($inDesiredState)
        {
            # Since no changes are needed, cleanup the temp file 
            Remove-BackupFile -CsvPath $targetResourceReturn
            Write-Verbose -Message $localizedData.testCsvSuccess
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

<#
    .SYNOPSIS
        Checks the bit flags of the current audit policy against the desired state. 
    .PARAMETER CurrentSetting
        Specifies the current bit flag to test against.
    .PARAMETER DesiredSetting
        Specifies the desired bit flag to check.
    .PARAMETER Force
        Forces an exact match of all audit flags instead of a specific flag.
#>
function Test-AuditFlagState
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Int32]
        $CurrentSetting,

        [parameter(Mandatory = $true)]
        [System.Int32]
        $DesiredSetting,

        [parameter()]
        [System.Boolean]
        $Force
    )
    
    # 
    if ($force)
    {
        if ($CurrentSetting -eq $DesiredSetting)
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
        <# 
            Bit comparison against zero always returns 0, so if the Desired state 
            is 0 and the current state is not 0, return false
        #>
        if ( ($DesiredSetting -eq 0) -and ($CurrentSetting -ne $DesiredSetting) )
        {
            return $false
        }

        # If the audit flags are equal return true. 
        if ($CurrentSetting -ne $DesiredSetting)
        {
            # If the audit flags are not equal, compare the bits to see if the desired flag is set. 
            if (( $CurrentSetting -band $DesiredSetting ) -eq $DesiredSetting )
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
            return $true
        }
    }
}

Export-ModuleMember -Function *-TargetResource

## TODO Cleanup the temp files
