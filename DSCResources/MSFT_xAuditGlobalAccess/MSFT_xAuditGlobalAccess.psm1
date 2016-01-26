
Import-Module $PSScriptRoot\..\Misc\Helper.psm1 -Verbose:0

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("File","Key")]
        [System.String]
        $Resource,

        [parameter(Mandatory = $true)]
        [System.String]
        $User,

        [parameter(Mandatory = $true)]
        [ValidateSet("Success","Failure","SuccessAndFailure")]
        [System.String]
        $Event
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    <#
    $returnValue = @{
    Resource = [System.String]
    User = [System.String]
    Event = [System.String]
    Access = [System.String]
    Ensure = [System.String]
    }

    $returnValue
    #>
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("File","Key")]
        [System.String]
        $Resource,

        [parameter(Mandatory = $true)]
        [System.String]
        $User,

        [parameter(Mandatory = $true)]
        [ValidateSet("Success","Failure","SuccessAndFailure")]
        [System.String]
        $Event,

        [ValidateSet("FILE_GENERIC_READ","FILE_GENERIC_WRITE","FILE_GENERIC_EXECUTE","FILE_ALL_ACCESS","SYNCHRONIZE","WRITE_OWNER","WRITE_DAC","READ_CONTROL","DELETE","FILE_WRITE_ATTRIBUTES","FILE_READ_ATTRIBUTES","FILE_DELETE_CHILD","FILE_EXECUTE","FILE_WRITE_EA","FILE_READ_EA","FILE_APPEND_DATA","FILE_WRITE_DATA","FILE_READ_DATA","KEY_READ","KEY_WRITE","KEY_READ","KEY_ALL_ACCESS","KEY_CREATE_LINK","KEY_NOTIFY","KEY_ENUMERATE_SUB_KEYS","KEY_CREATE_SUB_KEY","KEY_SET_VALUE","KEY_QUERY_VALUE")]
        [System.String]
        $Access,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

    #Include this line if the resource requires a system reboot.
    #$global:DSCMachineStatus = 1


}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("File","Key")]
        [System.String]
        $Resource,

        [parameter(Mandatory = $true)]
        [System.String]
        $User,

        [parameter(Mandatory = $true)]
        [ValidateSet("Success","Failure","SuccessAndFailure")]
        [System.String]
        $Event,

        [ValidateSet("FILE_GENERIC_READ","FILE_GENERIC_WRITE","FILE_GENERIC_EXECUTE","FILE_ALL_ACCESS","SYNCHRONIZE","WRITE_OWNER","WRITE_DAC","READ_CONTROL","DELETE","FILE_WRITE_ATTRIBUTES","FILE_READ_ATTRIBUTES","FILE_DELETE_CHILD","FILE_EXECUTE","FILE_WRITE_EA","FILE_READ_EA","FILE_APPEND_DATA","FILE_WRITE_DATA","FILE_READ_DATA","KEY_READ","KEY_WRITE","KEY_READ","KEY_ALL_ACCESS","KEY_CREATE_LINK","KEY_NOTIFY","KEY_ENUMERATE_SUB_KEYS","KEY_CREATE_SUB_KEY","KEY_SET_VALUE","KEY_QUERY_VALUE")]
        [System.String]
        $Access,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    <#
    $result = [System.Boolean]
    
    $result
    #>
}


Export-ModuleMember -Function *-TargetResource

