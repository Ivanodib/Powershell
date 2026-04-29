param (
    [string]$File
)

Import-Module ActiveDirectory

if (-not $File) {
    $File = Read-Host "Inserisci percorso file CSV"
}

function New-RandomPassword {
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%'
    $password = -join ((1..12) | ForEach-Object { $chars | Get-Random })
    return $password
}

$Users = Import-Csv -Path $File

foreach ($user in $Users) {
    $upn = $user.UPN.Trim()
    if ($upn) {
        try {
            $pwd = New-RandomPassword
            $sec = ConvertTo-SecureString $pwd -AsPlainText -Force

            Set-ADAccountPassword -Identity $upn -NewPassword $sec -Reset

            Write-Host "[OK] $upn | password reset" -ForegroundColor Green
        }
        catch {
            Write-Host "[ERR] $upn - $_" -ForegroundColor Red
        }
    }
}
``
