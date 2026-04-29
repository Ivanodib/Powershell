
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

    $pwd = @(
        ($lower.ToCharArray()   | Get-Random -Count 1)
        ($upper.ToCharArray()   | Get-Random -Count 1)
        ($digits.ToCharArray()  | Get-Random -Count 1)
        ($special.ToCharArray() | Get-Random -Count 1)
    )

    $pwd += (1..8 | ForEach-Object { $all | Get-Random })

    return (-join ($pwd | Get-Random -Count $pwd.Count))
}

$Users = Import-Csv -Path $File

$Results = @()

foreach ($user in $Users) {

    $upn = $user.UPN
    $sam = $user.UPN.Split('@')[0]

    $ResultObj = [PSCustomObject]@{
        UPN    = $upn
        SAM    = $sam
        Result = ""
    }

    try {
        $pwd = New-RandomPassword
        $sec = ConvertTo-SecureString $pwd -AsPlainText -Force

        Set-ADAccountPassword -Identity $sam -NewPassword $sec -Reset -ErrorAction Stop

        $ResultObj.Result = "password resetted"
        Write-Host "[OK] $upn | password resetted" -ForegroundColor Green
    }
    catch {
        $ResultObj.Result = $_.Exception.Message
        Write-Host "[ERR] $upn - $_.Exception.Message" -ForegroundColor Red
    }

    $Results += $ResultObj
}

$OutFile = "C:\temp\account-resetted.csv"

$Results | Export-Csv -Path $OutFile -NoTypeInformation -Encoding UTF8
Write-Host "Output salvato in $OutFile" -ForegroundColor Green
