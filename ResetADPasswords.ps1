param (
    [string]$File
)

Import-Module ActiveDirectory

# Se non passi -File → chiedi input
if (-not $File) {
    $File = Read-Host "Inserisci percorso file CSV"
}

# Funzione password random
function New-RandomPassword {
    return ([System.Web.Security.Membership]::GeneratePassword(12,2))
}

# Import CSV
$Users = Import-Csv -Path $File

foreach ($user in $Users) {
    $upn = $user.UPN.Trim()

    if ($upn) {
        try {
            $plainPassword = New-RandomPassword
            $securePassword = ConvertTo-SecureString $plainPassword -AsPlainText -Force

            Set-ADAccountPassword -Identity $upn -NewPassword $securePassword -Reset

            Write-Host "[OK] $upn | password resetted" -ForegroundColor Green
        }
        catch {
            Write-Host "[ERR] $upn - $_" -ForegroundColor Red
        }
    }
}