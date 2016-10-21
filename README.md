[![Build status](https://ci.appveyor.com/api/projects/status/urjs5g2l5kt71msb?svg=true)](https://ci.appveyor.com/project/athaynes/auditpolicydsc)

# AuditPolicyDsc

The **AuditPolicyDsc** module allows you to configure and manage the advanced audit policy on all currently supported versions of Windows.

This project has adopted the Microsoft Open Source Code of Conduct.
For more information see the Code of Conduct FAQ or contact opencode@microsoft.com with any additional questions or comments.

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResources/blob/master/CONTRIBUTING.md).

## Resources

* **AuditPolicySubcategory** configures the advanced audit policy Subcategory audit flags. 

* **AuditPolicyOption** manages the audit policy options available in the auditpol.exe utility. 


### AuditPolicySubcategory
* **Subcategory**: Name of the subcategory in the advanced audit policy.

* **AuditFlag**: The name of the audit flag to apply to the subcategory. This is can be either Success or Failure.

### AuditPolicyOption

 * **Name**: The name of the option to configure. 
 
 * **Value**: The value to apply to the option. This can be either Enabled or Disabled. 
 
## Versions

### Unreleased

### 1.0.0.0

* Initial release with the following resources:
 
  * AuditPolicySubcategory
  * AuditPolicyOption

## Examples

### Example 1 Audit Logon Success and Failure
```powershell
    Configuration AuditPolicy
    {
        Import-DscResource -ModuleName AuditPolicyDsc

        AuditPolicySubcategory LogonSuccess
        {
            Subcategory = 'Logon'
            AuditFlag   = 'Success'
            Ensure      = 'Present' 
        } 

        AuditPolicySubcategory LogonFailure
        {
            Subcategory = 'Logon'
            AuditFlag   = 'Failure'
            Ensure      = 'Present' 
        } 
    }
```

### Example 2 Audit Logon Failure only
```powershell
    Configuration AuditPolicy
    {
        Import-DscResource -ModuleName AuditPolicyDsc

        AuditPolicySubcategory LogonSuccess
        {
            Subcategory = 'Logon'
            AuditFlag   = 'Success'
            Ensure      = 'Absent' 
        } 

        AuditPolicySubcategory LogonFailure
        {
            Subcategory = 'Logon'
            AuditFlag   = 'Failure'
            Ensure      = 'Present' 
        } 
    }
```

### Example 3 Enable the option AuditBaseDirectories
```powershell
    Configuration AuditPolicy
    {
        Import-DscResource -ModuleName AuditPolicyDsc

        AuditPolicyOption AuditBaseDirectories
        {
            Name  = 'AuditBaseDirectories'
            Value = 'Enabled'
        }
    }
```
