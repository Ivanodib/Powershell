# PIM Eligible Discovery Script

## Overview  
This PowerShell script retrieves **Privileged Identity Management (PIM) eligible assignments** for a given Microsoft Entra ID user.

It collects:
-  **Eligible directory roles (PIM roles)**  
-  **Eligible group assignments (PIM for Groups – Member / Owner)**  

The script is designed for **security operations, audit, and compliance use cases**, where it is necessary to identify all potential privileged access assigned to a user.

---

## Features  

- Retrieve **PIM eligible directory roles**
- Retrieve **PIM eligible group memberships**
- Handle Microsoft Graph **API limitations automatically**
- Export results to **CSV for reporting**
- Compatible with **Azure Cloud Shell** and PowerShell 7+

---

## Requirements  

- PowerShell 7 (Azure Cloud Shell recommended)
- Microsoft Graph PowerShell modules
- Required permissions:
  - `User.Read.All`
  - `Group.Read.All`
  - `RoleManagement.Read.Directory`
  - `PrivilegedEligibilitySchedule.Read.AzureADGroup`

- Recommended Entra roles:
  - Global Reader  
  - Privileged Role Administrator  

---

## Usage  

### Run the script  

```powershell
.\Get-PIMEligible.ps1 -UserUPN user@domain.com
