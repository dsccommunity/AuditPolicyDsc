
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
    [OutputType([Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [String[]]
        $CsvPath
    )

    [String] $tempFile = ([system.IO.Path]::GetTempFileName()).Replace('.tmp','.csv')

    try
    {
        Write-Verbose -Message ($localizedData.BackupFilePath -f $tempFile)
        Invoke-SecurityCmdlet -Action "Export" -CsvPath $tempFile
    }
    catch
    {
        Write-Verbose -Message ($localizedData.ExportFailed -f $tempFile)
    }

    return @{
        CsvPath = $tempFile
        IsSingleInstance = 'Yes'
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
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [String[]]
        $CsvPath
    )

    $csvToSet = Get-CsvFile -CsvPath $CsvPath

    try
    {
        Invoke-SecurityCmdlet -Action "Import" -CsvPath $csvToSet | Out-Null
        Write-Verbose -Message ($localizedData.ImportSucceeded -f $csvToSet)
    }
    catch
    {
        Write-Verbose -Message ($localizedData.ImportFailed -f $csvToSet)
    }

    # Only remove temp files that are created by the resource
    if($csvToSet -ne $CsvPath)
    {
        Remove-BackupFile -CsvPath $csvToSet
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
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [String[]]
        $CsvPath
    )

    # The CsvPath in Get-TargetResource is ignored but a temp file is returned for comparison.
    $currentAuditPolicyBackupPath = (Get-TargetResource -CsvPath $CsvPath `
                                                        -IsSingleInstance $IsSingleInstance).CsvPath
    [String] $csvPropertyToTest = 'Subcategory'

    $currentAuditPolicy = Import-Csv -Path $currentAuditPolicyBackupPath |
        Select-Object -Property $csvPropertyToTest, @{
            'Name' = 'Value';
            'Expression' = {$_.'Setting Value'}
        }

    $desiredAuditPolicy = Get-CsvContent -CsvPath $CsvPath |
        Select-Object -Property $csvPropertyToTest, @{
            'Name' = 'Value';
            'Expression' = {$_.'Setting Value'}
        }

    # Assume the node is in the desired state until proven false.
    [Boolean] $inDesiredState = $true

    foreach ($desiredAuditPolicySetting in $desiredAuditPolicy)
    {
        # Get the current setting name that mathches the desired setting name
        $currentAuditPolicySetting = $currentAuditPolicy.Where({
            $_.$csvPropertyToTest -eq $desiredAuditPolicySetting.$csvPropertyToTest
        })

        # If the current and desired setting do not match, set the flag to $false
        if ($desiredAuditPolicySetting.Value -ne $currentAuditPolicySetting.Value)
        {
            Write-Warning -Message ($localizedData.testCsvFailed -f
                $desiredAuditPolicySetting.$csvPropertyToTest)

            $inDesiredState = $false
        }
        else
        {
            Write-Verbose -Message ($localizedData.testCsvSucceed -f
                $desiredAuditPolicySetting.$csvPropertyToTest)
        }
    }

    # Cleanup the temp file, since it is no longer needed.
    Remove-BackupFile -CsvPath $currentAuditPolicyBackupPath -Verbose

    return $inDesiredState
}

<#
    .SYNOPSIS
        Helper function to use SecurityCmdlet modules if present. If not, go through AuditPol.exe.
    .PARAMETER Action
        The action to take, either Import or Export. Import will clear existing policy before writing.
    .PARAMETER CsvPath
        The path to a CSV file to either create or import.
    .EXAMPLE
        Invoke-SecurityCmdlet -Action Import -CsvPath .\test.csv
#>
function Invoke-SecurityCmdlet
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Import','Export')]
        [String]
        $Action,

        [Parameter(Mandatory = $true)]
        [String]
        $CsvPath
    )

    # Use the security cmdlets if present. If not, use Invoke-AuditPol to call auditpol.exe.
    if ($null -eq (Get-Module -ListAvailable -Name "SecurityCmdlets"))
    {
        Write-Verbose -Message ($localizedData.CmdletsNotFound)

        if ($Action -ieq "Import")
        {
            Invoke-AuditPol -Command Restore -SubCommand "file:$CsvPath"
        }
        else
        {
            # No force option on Backup, manually check for file and delete it so we can write back again
            if (Test-Path -Path $CsvPath)
            {
                Remove-Item -Path $CsvPath -Force
            }

            Invoke-AuditPol -Command Backup -SubCommand "file:$CsvPath"
        }
    }
    else
    {
        Import-Module -Name SecurityCmdlets

        if ($Action -ieq "Import")
        {
            Restore-AuditPolicy -Path $CsvPath | Out-Null
        }
        elseif ($Action -ieq "Export")
        {
            # No force option on Backup, manually check for file and delete it so we can write back again
            if (Test-Path -Path $CsvPath)
            {
                Remove-Item -Path $CsvPath -Force
            }
            Backup-AuditPolicy -Path $CsvPath | Out-Null
        }
    }
}

<#
    .SYNOPSIS
        Removes the temporary file that is created by the Get\Test functions.
    .PARAMETER CsvPath
        Specifies the path of the temp file to remove.
#>
function Remove-BackupFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
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
        Get the contents of a Csv whether it is from an external file or inline to the configuration.
    .PARAMETER CsvPath
        Specifies the Csv content to get.
#>
function Get-CsvContent
{
    [CmdletBinding()]
    [OutputType([Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String[]]
        $CsvPath
    )

    <#
        If CsvPath is a csv file (ByFileExtension), then import the contents and return the object.
        If it is not a file path, then assume it is inline Csv and convert it into an object. Csv
        content validation should occur before it is provded to the resource for processing.
    #>
    if ( $CsvPath -match '\.csv$' )
    {
        if ( Test-Path -Path $CsvPath )
        {
            return ( Import-Csv -Path $CsvPath )
        }
        else
        {
            Write-Error -Message ($localizedData.FileNotFound -f $CsvPath)
        }
    }
    else
    {
        return ( ConvertFrom-Csv -InputObject $CsvPath )
    }
}

<#
    .SYNOPSIS
        Get the contents of a Csv whether it is from an external file or inline to the configuration.
    .PARAMETER CsvPath
        Specifies the Csv content to set.
#>
function Get-CsvFile
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String[]]
        $CsvPath
    )

    <#
        If CsvPath is a csv file (ByFileExtension), then return the path as no further processing is
        needed. If it is not a file path,then assume it is inline Csv and output the content to a 
        temp csv file and return the path.
    #>
    if ( $CsvPath -match '\.csv$' )
    {
        if ( Test-Path -Path $CsvPath )
        {
            return $CsvPath
        }
        else
        {
            Write-Error -Message ($localizedData.FileNotFound -f $CsvPath)
        }
    }
    else
    {
        [String] $tempFile = ([system.IO.Path]::GetTempFileName()).Replace('.tmp','.csv')
        $CsvPath | ConvertFrom-Csv | Export-Csv -Path $tempFile
        return $tempFile
    }
}