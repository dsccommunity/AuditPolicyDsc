# xAuditPolicy

The **xAuditPolicy** DSC resources allow you to configure and manage the advanced audit policy in Windows.

# Description

The **xAuditPolicy** module contains the **xAuditCategory** and **xAuditOption** DSC Resources. These DSC Resources allow you to configure the advanced audit policies in all currently supported versions of Windows.
# Resources

* **xAuditCategory** configures the advanced audit policy Subcategories audit flags. 

* **xAuditOption** manages the auditpol options available in the auditpol.exe utility. 


## xAuditCategory
* **Subcategory:** Name of the subcategory in the advanced audit policy.

* **AuditFlag:** The name of the audit flag to apply to the subcategory. This is can be either Success or Failure.

## xAuditOption

 * **Name:** The name of the option to configure. 
 
 * **Vaule:** The value to apply to the option. This can be either Enabled or Disabled. 
 
# Versions

## 1.0.0.0
* Initial release with the following resources:

..* xAuditPolicy and xAuditOption   