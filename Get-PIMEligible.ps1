param(
  [Parameter(Mandatory=$true)]
  [string]$UserUPN,

  # Facoltativo: limita ai gruppi role-assignable (più veloce, tipico per GA group)
  [switch]$RoleAssignableOnly,

  # Facoltativo: filtra per nome gruppo (contiene)
  [string]$GroupNameContains = "",

  # Facoltativo: export CSV (path locale Cloud Shell)
  [string]$ExportCsvPath = ""
)

# --- Moduli ---
Import-Module Microsoft.Graph.Users -ErrorAction Stop
Import-Module Microsoft.Graph.Groups -ErrorAction Stop
Import-Module Microsoft.Graph.Identity.Governance -ErrorAction Stop

# --- Connect Graph (delegated) ---
Disconnect-MgGraph -ErrorAction SilentlyContinue
$Scopes = @(
  "User.Read.All",
  "Group.Read.All",
  "Directory.Read.All",
  "PrivilegedEligibilitySchedule.Read.AzureADGroup"
)
Connect-MgGraph -Scopes $Scopes -NoWelcome

# --- Resolve user ---
$user = Get-MgUser -UserId $UserUPN -Property Id,DisplayName,UserPrincipalName
if (-not $user) { throw "User not found: $UserUPN" }

Write-Host "Target user: $($user.DisplayName) <$($user.UserPrincipalName)>  Id=$($user.Id)" -ForegroundColor Cyan

# --- Candidate groups ---
# Nota: non esiste una “lista diretta” di gruppi PIM-enabled per un altro utente senza iterare.
# Riduciamo la superficie: role-assignable oppure securityEnabled.
$groupFilter = $RoleAssignableOnly.IsPresent ? "isAssignableToRole eq true" : "securityEnabled eq true"

$groups = Get-MgGroup -All -Filter $groupFilter -Property Id,DisplayName,SecurityEnabled,IsAssignableToRole

if ($GroupNameContains -and $GroupNameContains.Trim().Length -gt 0) {
  $groups = $groups | Where-Object { $_.DisplayName -like "*$GroupNameContains*" }
}

Write-Host "Candidate groups: $($groups.Count) (filter: $groupFilter, nameContains: '$GroupNameContains')" -ForegroundColor Yellow

# --- Iterate groups and query eligibilityScheduleInstances scoped by (principalId AND groupId) ---
# Questo evita il 403 “principalId-only” su other user. [1](https://learn.microsoft.com/en-us/answers/questions/5826484/unable-to-get-eligible-groups-for-user-accounts-wh)[2](https://learn.microsoft.com/en-us/graph/api/privilegedaccessgroup-list-eligibilityschedules?view=graph-rest-1.0)
$results = New-Object System.Collections.Generic.List[Object]
$i = 0

foreach ($g in $groups) {
  $i++
  if (($i % 50) -eq 0) { Write-Host "Progress: $i / $($groups.Count) ..." -ForegroundColor DarkGray }

  try {
    $elig = Get-MgIdentityGovernancePrivilegedAccessGroupEligibilityScheduleInstance `
      -Filter "principalId eq '$($user.Id)' and groupId eq '$($g.Id)'" `
      -ExpandProperty group `
      -ErrorAction Stop

    foreach ($e in $elig) {
      $results.Add([pscustomobject]@{
        UserUPN        = $user.UserPrincipalName
        GroupDisplayName = $g.DisplayName
        GroupId        = $g.Id
        AccessId       = $e.AccessId      # "member" / "owner"
        StartDateTime  = $e.StartDateTime
        EndDateTime    = $e.EndDateTime
        Status         = $e.Status
      })
    }
  }
  catch {
    # Molti gruppi non sono PIM-enabled -> zero results / o errori; li ignoriamo e continuiamo.
    continue
  }
}

# --- Output ---
Write-Host "`nEligible groups found: $($results.Count)" -ForegroundColor Green
$results | Sort-Object GroupDisplayName, AccessId | Format-Table -AutoSize

# --- Export (opzionale) ---
if ($ExportCsvPath -and $ExportCsvPath.Trim().Length -gt 0) {
  $results | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $ExportCsvPath
  Write-Host "Exported to: $ExportCsvPath" -ForegroundColor Green
}