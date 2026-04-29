param (
    [string]$File
)

Import-Module ActiveDirectory

if (-not $File) {
    $File = Read-Host "Inserisci percorso file CSV"
}

function New-RandomPassword {
    $lower   = 'abcdefghijklmnopqrstuvwxyz'
    $upper   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $digits  = '0123456789'
    $special = '!@#$%*-_'
    $all     = ($lower + $upper + $digits + $special).ToCharArray()

    # garantisce complessità minima
    $pwd = @(
        ($lower.ToCharArray()   | Get-Random -Count 1)
        ($upper.ToCharArray()   | Get-Random -Count 1)
        ($digits.ToCharArray()  | Get-Random -Count 1)
        ($special.ToCharArray() | Get-Random -Count 1)
    )

    # completa fino a 12 caratteri
    $pwd += (1..8 | ForEach-Object { $all | Get-Random })

    # shuffle finale
    return (-join ($pwd | Get-Random -Count $pwd.Count))
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
