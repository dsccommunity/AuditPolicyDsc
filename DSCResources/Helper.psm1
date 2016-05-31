#Requires -Version 4.0

# This PS module contains functions for Desired State Configuration (DSC) xAuditPolicy provider. 
# It enables querying, creation, removal and update of Windows advanced audit policies through 
# Get, Set and Test operations on DSC managed nodes.

Import-LocalizedData -BindingVariable LocalizedData -Filename xAuditPolicy.psd1


<#
.SYNOPSIS
    Invoke_Auditpol is a private function that wraps the auditpol.exe to provide a 
    centralized function to mange access to and the output of auditpol.exe    
.DESCRIPTION
    The function will accept a string to pass to auditpol.exe for execution. Any 'get' or
    'set' opertions can be passed to the central wrapper to execute, so that all of the 
    nuances of auditpol.exe can be further broken out into specalized functions that 
    call Invoke_AuditPol.   
    
    Since Invoke-Expression is being used, the input is restricted to only execute
    against auditpol.exe. Any input that is an invalid flag or parameter in 
    auditpol.exe will return an error to prevent abuse of the Invoke-Expression cmdlet. 
.INPUTS
    The funcion accepts a string to execute against auditpol.exe 
.OUTPUTS
    The raw string output of auditpol.exe   
.EXAMPLE
    Invoke_AuditPol -CommandToExecute "/get /category:*"
#>

function Invoke_AuditPol
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $CommandToExecute 
    )

    Write-Debug -Message ($localizedData.ExecuteAuditpolCommand -f $CommandToExecute)

    try
    {
        $return = Invoke-Expression -Command "$env:SystemRoot\System32\auditpol.exe $CommandToExecute" 2>&1
        
        if($LASTEXITCODE -eq 87)
        {
            Throw New-Object -TypeName System.ArgumentException $localizedData.IncorrectParameter
        }
        $return
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        # catch error if the auditpol command is not found on the system
        Write-Error -Message $localizedData.AuditpolNotFound 
    }
    catch [System.ArgumentException]
    {
        $localizedData.IncorrectParameter 
    }
    catch
    {
        $localizedData.UnknownError
    }
}


<#
.SYNOPSIS
    Get_AuditCategory is a private function that generates the specifc parameters 
    and switches to be passed to Invoke_Auditpol to Get a specific audit category.    
.DESCRIPTION
     In the absense of a PS module, this function is designed to extract the most 
     precise string from the advanced audit policy in Windows using auditpol.exe.

    While this function does not use aduitpol directly, it does generate a string that
    auditpol.exe will consume and return the correct result and then passes it to 
    Invoke_Auditpol 
.INPUTS
    The nme os an audit subcategory in the forma of a String that has be validated
    by the public function  
.OUTPUTS
    A string that is further processed by the public version of this function. 
#>

function Get_AuditCategory
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $SubCategory
    )
    
    (Invoke_Auditpol -CommandToExecute "/get /subcategory:""$SubCategory"" /r" | 
    Select-String -Pattern $env:ComputerName)

}

<#
.SYNOPSIS 
    Gets the audit flag state for a specifc subcategory. 
.DESCRIPTION
    Ths is one of the public functions that calls into Get_AuditpolSubcommand.
    This function enforces parameters that will be passed through to the 
    Get_AuditpolSubcommand function and aligns to a specifc parameterset. 
.PARAMETER SubCategory 
    The name of the subcategory to get the audit flags from.
.EXAMPLE
    Get-AuditCategory -SubCategory 'Logon'
#>

function Get-AuditCategory
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Security System Extension","System Integrity","IPsec Driver",
        "Other System Events","Security State Change","Logon","Logoff","Account Lockout",
        "IPsec Main Mode","IPsec Quick Mode","IPsec Extended Mode","Special Logon",
        "Other Logon/Logoff Events","Network Policy Server","User / Device Claims",
        "Group Membership","File System","Registry","Kernel Object","SAM","Certification Services",
        "Application Generated","Handle Manipulation","File Share","Filtering Platform Packet Drop",
        "Filtering Platform Connection","Other Object Access Events","Detailed File Share",
        "Removable Storage","Central Policy Staging","Non Sensitive Privilege Use",
        "Other Privilege Use Events","Sensitive Privilege Use","Process Creation",
        "Process Termination","DPAPI Activity","RPC Events","Plug and Play Events",
        "Authentication Policy Change","Authorization Policy Change",
        "MPSSVC Rule-Level Policy Change","Filtering Platform Policy Change",
        "Other Policy Change Events","Audit Policy Change","User Account Management",
        "Computer Account Management","Security Group Management","Distribution Group Management",
        "Application Group Management","Other Account Management Events",
        "Directory Service Changes","Directory Service Replication",
        "Detailed Directory Service Replication","Directory Service Access",
        "Kerberos Service Ticket Operations","Other Account Logon Events",
        "Kerberos Authentication Service","Credential Validation")]
        [System.String]
        $SubCategory
    )
 
    $split = (Get_AuditCategory @PSBoundParameters) -split ","

    $subcategoryObject = New-Object -TypeName PSObject
    $subcategoryObject | Add-Member -MemberType NoteProperty -Name Name -Value $split[2]
    # remove the spaces from 'Success and Failure' to prevent any wierd sting problems later. 
    $subcategoryObject | Add-Member -MemberType NoteProperty -Name AuditFlag `
                                    -Value ($split[4] -replace " ","")
    return $subcategoryObject
}


<#
.SYNOPSIS
    Get_AuditOption is a private function that generates the specifc parameters 
    and switches to be passed to Invoke_Auditpol to Get a specific audit option.    
.DESCRIPTION
     In the absense of a PS module, this function is designed to extract the most 
     precise string from the advanced audit policy in Windows using auditpol.exe.

    While this function does not use aduitpol directly, it does generate a string that
    auditpol.exe will consume and return the correct result and then passes it to 
    Invoke_Auditpol 
.INPUTS
    The nme of an audit option in the form of a String that has be validated
    by the public function  
.OUTPUTS
    A string that is further processed by the public version of this function. 
#>

function Get_AuditOption
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Option
    )
    
    (Invoke_Auditpol -CommandToExecute "/get /option:$Option")[1]    
}

<#
.SYNOPSIS
    Gets the audit policy option state.
     
.DESCRIPTION
    Ths is one of the public functions that calls into Get_AuditpolSubcommand.
    This function enforces parameters that will be passed through to the 
    Get_AuditpolSubcommand function and aligns to a specifc parameterset. 

.INPUTS
    The option name 
    
.OUTPUTS
    A string that is the state of the option (Enabled|Disables). 
#>

function Get-AuditOption
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("CrashOnAuditFail","FullPrivilegeAuditing",
                     "AuditBaseObjects","AuditBaseDirectories")]
        [System.String]
        $Name
    )
 
    # Get_Auditpoloption returns a single string with the Option and value on a single line
    # so we simply return the matched value. 
    Switch (Get_AuditOption -Option $Name)
    {
        {$_ -match "Disabled"} {$auditpolStrings = 'Disabled'}
        {$_ -match "Enabled" } {$auditpolStrings = 'Enabled' }
    }

    $auditpolStrings
}


<#
.SYNOPSIS
    Set_AuditCategory is a private function that generates the specifc parameters 
    and switches to be passed to Invoke_Auditpol to Set a specific audit category.    
.DESCRIPTION
     In the absense of a PS module, this function is designed to extract the most 
     precise string from the advanced audit policy in Windows using auditpol.exe.

    While this function does not use aduitpol directly, it does generate a string that
    auditpol.exe will consume and return the correct result and then passes it to 
    Invoke_Auditpol 
.INPUTS
    The nme of an audit category in the form of a String that has be validated
    by the public function  
.OUTPUTS
    A string that is further processed by the public version of this function. 
#>

function Set_AuditCategory
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $SubCategory,

        [parameter(Mandatory = $true)]
        [System.String]
        $AuditFlag,

        [parameter(Mandatory = $true)]
        [System.String]
        $Ensure
    )
    
    # translate $ensure=present to enable and $ensure=absent to disable
    $auditState = @{"Present"="enable";"Absent"="disable"}
            
    # select the line needed from the auditpol output
    if($AuditFlag -eq 'Success')
    { 
        [string]$commandToExecute = '/set /subcategory:"' +
        $SubCategory + '" /success:' + $($auditState[$Ensure]) 
    }
        else   
    {
        [string]$commandToExecute = '/set /subcategory:"' +
        $SubCategory + '" /failure:' + $($auditState[$Ensure]) 
    }
                
    if($PSCmdlet.ShouldProcess($Option))
    {
        Invoke_Auditpol -CommandToExecute $commandToExecute
    }
        else
    {
        # Return a sting when the -whatif switch is set 
        "Set $SubCategory $AuditFlag to $($auditState[$Ensure])"
    }
}


<#
.SYNOPSIS 
    Sets the audit flag state for a specifc subcategory. 
.PARAMETER SubCategory 
    The name of the subcategory to set the audit flag on.
.PARAMETER AuditFlag 
    The name of the Auditflag to set.
.PARAMETER Ensure 
    The name of the subcategory to get the audit flags from.
.EXAMPLE
    Set-AuditCategory -SubCategory 'Logon'
.OUTPUTS
    None
#>

function Set-AuditCategory
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true,
                   ParameterSetName="SubCategory")]
        [ValidateSet("Security System Extension","System Integrity","IPsec Driver",
        "Other System Events","Security State Change","Logon","Logoff","Account Lockout",
        "IPsec Main Mode","IPsec Quick Mode","IPsec Extended Mode","Special Logon",
        "Other Logon/Logoff Events","Network Policy Server","User / Device Claims",
        "Group Membership","File System","Registry","Kernel Object","SAM","Certification Services",
        "Application Generated","Handle Manipulation","File Share","Filtering Platform Packet Drop",
        "Filtering Platform Connection","Other Object Access Events","Detailed File Share",
        "Removable Storage","Central Policy Staging","Non Sensitive Privilege Use",
        "Other Privilege Use Events","Sensitive Privilege Use","Process Creation",
        "Process Termination","DPAPI Activity","RPC Events","Plug and Play Events",
        "Authentication Policy Change","Authorization Policy Change",
        "MPSSVC Rule-Level Policy Change","Filtering Platform Policy Change",
        "Other Policy Change Events","Audit Policy Change","User Account Management",
        "Computer Account Management","Security Group Management","Distribution Group Management",
        "Application Group Management","Other Account Management Events",
        "Directory Service Changes","Directory Service Replication",
        "Detailed Directory Service Replication","Directory Service Access",
        "Kerberos Service Ticket Operations","Other Account Logon Events",
        "Kerberos Authentication Service","Credential Validation")]
        [System.String]
        $SubCategory,
        
        [parameter(Mandatory = $true,
                   ParameterSetName="SubCategory")]
        [ValidateSet("Success","Failure")]
        [System.String]
        $AuditFlag,
        
        [parameter(Mandatory = $true,
                   ParameterSetName="SubCategory")]
        [System.String]
        $Ensure
    )
 
    Set_AuditCategory @PSBoundParameters
}


<#
.SYNOPSIS
    Set_AuditOption is a private function that generates the specifc parameters 
    and switches to be passed to Invoke_Auditpol to Set a specific audit option.    
.DESCRIPTION
     In the absense of a PS module, this function is designed to extract the most 
     precise string from the advanced audit policy in Windows using auditpol.exe.

    While this function does not use aduitpol directly, it does generate a string that
    auditpol.exe will consume and return the correct result and then passes it to 
    Invoke_Auditpol 
.INPUTS
    The nme of an audit option in the form of a String that has be validated
    by the public function  
.OUTPUTS
    A string that is further processed by the public version of this function. 
#>

function Set_AuditOption
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [parameter(Mandatory = $true,
                   ParameterSetName="Option")]
        [ValidateSet("CrashOnAuditFail","FullPrivilegeAuditing","AuditBaseObjects",
        "AuditBaseDirectories")]
        [System.String]
        $Name,

        [parameter(Mandatory = $true,
                   ParameterSetName="Option")]
        [ValidateSet("Enabled","Disabled")]
        [System.String]
        $Value
    )
 
    # the output text of auditpol is in simple past tense, but the input is in simple 
    # present tense the hashtable corrects the tense for the input.  
    $valueHashTable = @{"Enabled"="enable";"Disabled"="disable"}

    if($PSCmdlet.ShouldProcess($Name))
    {
        Invoke_Auditpol `
        -CommandToExecute "/set /option:$Name /value:$($valueHashTable[$value])"
    }
    else
    {
        # Return a sting when the -whatif switch is set 
        "Set $Name to $Value"
    }
}


<#
.SYNOPSIS
    Sets an audit policy option to enabled or disabled
.DESCRIPTION
    Ths is one of the public functions that calls into Set_AuditpolSubcommand.
    This function enforces parameters that will be passed through to the 
    Set_AuditpolSubcommand function and aligns to a specifc parameterset. 
.INPUTS
    The option name and state it will be set to. 
.OUTPUTS
    None
#>


function Set-AuditOption
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Name,
        
        [Parameter(Mandatory=$true)]
        [System.String]
        $Value
    )
 
    Set_AuditOption @PSBoundParameters
}


# all internal functions are named with "_" vs. "-"
Export-ModuleMember -Function *-* -Variable localizedData

