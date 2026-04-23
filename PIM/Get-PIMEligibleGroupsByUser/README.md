# PIM Discovery Script

## Overview  
This PowerShell script retrieves **Privileged Identity Management (PIM) Eligible/Active group assignments** for a given Entra ID user.

  <br>

## Features  

- Retrieve **PIM eligible/active group membership**
- Handle Microsoft Graph **API limitations**
- Export results to **CSV for reporting**
- Compatible with **Azure Cloud Shell** and PowerShell 7+

## Requirements  

- Entra ID roles:
  - `Global Reader` or   
  - `User Administrator` **and** `Privileged Role Administrator` 

- PowerShell 7+ (Azure Cloud Shell recommended)

- MS Graph Scope:
  - `User.Read.All`
  - `Group.Read.All`
  - `Directory.Read.All`,
  - `RoleManagement.Read.Directory`
  - `PrivilegedEligibilitySchedule.Read.AzureADGroup`
  - `PrivilegedAccess.Read.AzureADGroup`


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

