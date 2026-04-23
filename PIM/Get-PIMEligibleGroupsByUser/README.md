# PIM Eligible Discovery Script

## Overview  
This PowerShell script retrieves **Privileged Identity Management (PIM) eligible assignments** for a given Microsoft Entra ID user.

It collects:
-  **Eligible group assignments (PIM for Groups – Member / Owner)**  
---

## Features  

- Retrieve **PIM eligible group memberships**
- Handle Microsoft Graph **API limitations automatically**
- Export results to **CSV for reporting**
- Compatible with **Azure Cloud Shell** and PowerShell 7+

---

## Requirements  

- Required Entra roles:
  - `Global Reader` or   
  - `Privileged Role Administrator` 

- PowerShell 7+ (Azure Cloud Shell recommended)

- Microsoft Graph PowerShell modules:
  - `Install-Module Microsoft.Graph.Users`
  - `Install-Module Microsoft.Graph.Groups`
  - `Install-Module Microsoft.Graph.Identity.Governance`
    
  > **Azure Cloud Shell already includes these modules**

- Required permissions:
  - `User.Read.All`
  - `Group.Read.All`
  - `RoleManagement.Read.Directory`
  - `PrivilegedEligibilitySchedule.Read.AzureADGroup`

---

## Usage

### Download the script (usefull from cloudshell)
`Invoke-WebRequest -Uri "(https://github.com/Ivanodib/Powershell/blob/main/PIM/Get-PIMEligibleGroupsByUser/Get-PIMEligibleGroupsByUser.ps1)" -OutFile "Get-PIMEligibleUserGroups.ps1"`

### Run the script  

```powershell
.\Get-PIMEligibleGroupsByUser.ps1 -UserUPN "user@domain.com" -ExportCsvPath "eligible_groups.csv"
