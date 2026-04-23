# PIM Eligible Discovery Script

## Overview  
This PowerShell script retrieves **Privileged Identity Management (PIM) eligible/ group and role assignments** for a given Microsoft Entra ID user.


## Features  

- Retrieve **PIM eligible/active group memberships**
- Retrieve **PIM eligible/active roles memberships**
- Handle Microsoft Graph **API limitations**
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


``` powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Ivanodib/Powershell/main/PIM/Get-PIMEligibleGroupsByUser/Get-PIMEligibleGroupsByUser.ps1" -OutFile "Get-PIMEligibleGroupsByUser.ps1"
```


### Run the script  

``` powershell
.\Get-PIMEligibleGroupsByUser.ps1 -UserUPN "user@domain.com" -ExportCsvPath "eligible_groups.csv"
```

- Filter by group name
``` powershell
.\Get-PIMEligibleGroupsByUser.ps1 -UserUPN "user@domain.com" -GroupNameContains "PIM" -ExportCsvPath "eligible_groups.csv"
```

