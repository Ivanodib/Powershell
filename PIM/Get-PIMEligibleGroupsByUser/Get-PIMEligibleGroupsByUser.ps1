param(
    [Parameter(Mandatory=$true)]
    [string]$UserUPN,

    [string]$GroupNameContains = "",
    [string]$ExportCsvPath = ""
)

# --- Verifica e installa moduli necessari ---
$requiredModules = @(
    'Microsoft.Graph.Authentication',
    'Microsoft.Graph.Users',
    'Microsoft.Graph.Groups',
    'Microsoft.Graph.Identity.Governance'
)
foreach ($mod in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "Installing $mod..." -ForegroundColor Yellow
        Install-Module $mod -Scope CurrentUser -Force -ErrorAction Stop
    }
    Import-Module $mod -ErrorAction Stop
}

$Scopes = @(
    "User.Read.All",
    "Group.Read.All",
    "Directory.Read.All",
    "PrivilegedEligibilitySchedule.Read.AzureADGroup",
    "PrivilegedAccess.Read.AzureADGroup"
)

$ctx = Get-MgContext
$missingScopes = $Scopes | Where-Object { $_ -notin $ctx.Scopes }
if (-not $ctx -or $missingScopes) {
    Connect-MgGraph -Scopes $Scopes -NoWelcome
}

# --- Resolve user ---
$user = Get-MgUser -UserId $UserUPN -Property Id,DisplayName,UserPrincipalName
if (-not $user) { throw "User not found: $UserUPN" }
Write-Host "Target user: $($user.DisplayName) <$($user.UserPrincipalName)>  Id=$($user.Id)" -ForegroundColor Cyan

# --- Gruppi PIM-enabled ---
Write-Host "Discovering PIM-enabled groups..." -ForegroundColor Yellow
$pimGroups = Get-MgGroup -All -Filter "isAssignableToRole eq true" -Property Id,DisplayName

if ($GroupNameContains.Trim().Length -gt 0) {
    $pimGroups = $pimGroups | Where-Object { $_.DisplayName -like "*$GroupNameContains*" }
}
Write-Host "PIM-enabled groups found: $($pimGroups.Count)" -ForegroundColor Yellow

# --- Itera gruppi ---
$results = [System.Collections.Generic.List[Object]]::new()
$total = $pimGroups.Count
$i = 0

foreach ($g in $pimGroups) {
    $i++
    Write-Host "[$i/$total] Checking group $($g.DisplayName) ..." -ForegroundColor Yellow

    $f = "principalId eq '$($user.Id)' and groupId eq '$($g.Id)'"

    # 1) Eligible
    try {
        $eligs = Get-MgIdentityGovernancePrivilegedAccessGroupEligibilityScheduleInstance -Filter $f -All -ErrorAction Stop
        foreach ($e in $eligs) {
            if ($e.AccessId -ne 'member') { continue }
            Write-Host "  -> Eligible: $($g.DisplayName)" -ForegroundColor Green
            $results.Add([pscustomobject]@{
                UserUPN          = $user.UserPrincipalName
                GroupDisplayName = $g.DisplayName
                GroupId          = $g.Id
                AssignmentType   = 'Eligible'
                StartDateTime    = $e.StartDateTime
                EndDateTime      = $e.EndDateTime
            })
        }
    } catch {
        Write-Warning "  [Eligible] Error on $($g.DisplayName): $_"
    }

    # 2) Active
    try {
        $actives = Get-MgIdentityGovernancePrivilegedAccessGroupAssignmentScheduleInstance -Filter $f -All -ErrorAction Stop
        foreach ($a in $actives) {
            if ($a.AccessId -ne 'member') { continue }
            Write-Host "  -> Active: $($g.DisplayName)" -ForegroundColor Green
            $results.Add([pscustomobject]@{
                UserUPN          = $user.UserPrincipalName
                GroupDisplayName = $g.DisplayName
                GroupId          = $g.Id
                AssignmentType   = 'Active'
                StartDateTime    = $a.StartDateTime
                EndDateTime      = $a.EndDateTime
            })
        }
    } catch {
        Write-Warning "  [Active] Error on $($g.DisplayName): $_"
    }
}

# --- Output ---
Write-Host "`nPIM group memberships found: $($results.Count)" -ForegroundColor Green
$results | Sort-Object GroupDisplayName, AssignmentType | Format-Table -AutoSize

# --- Export ---
if ($ExportCsvPath.Trim().Length -gt 0) {
    try {
        $results | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $ExportCsvPath -ErrorAction Stop
        Write-Host "Exported to: $ExportCsvPath" -ForegroundColor Green
    } catch {
        Write-Warning "Export failed: $_"
    }
} else {
    Write-Host "No export path specified (-ExportCsvPath). Skipping CSV export." -ForegroundColor DarkGray
}
