param(
    [Parameter(Mandatory=$true)][string]$BackupDirectory,
    [string]$JdkPath = $env:JAVA_HOME
)
$ErrorActionPreference = 'Stop'
$privatePath = Join-Path (Split-Path -Parent $PSScriptRoot) '.signing'
$keytool = Join-Path $JdkPath 'bin/keytool.exe'
if (!(Test-Path -LiteralPath $keytool)) { throw 'Selecciona un JDK completo.' }
if (Test-Path -LiteralPath $BackupDirectory) { throw 'Elige una carpeta nueva para no sobrescribir un respaldo.' }
$recovery = Read-Host 'Contraseña nueva para el respaldo (guárdala en tu gestor de contraseñas)' -AsSecureString
if ($recovery.Length -lt 16) { throw 'Usa al menos 16 caracteres para proteger las claves.' }
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($recovery)
try { $env:RP_BACKUP_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
$secure = (Get-Content -LiteralPath (Join-Path $privatePath 'password.dpapi') -Raw).Trim() | ConvertTo-SecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try { $env:RP_SOURCE_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
$env:RP_OLD_PASSWORD = 'android'
try {
    New-Item -ItemType Directory -Path $BackupDirectory | Out-Null
    & $keytool -importkeystore -srckeystore (Join-Path $privatePath 'rp-music-production.p12') -srcalias rp_music -srcstorepass:env RP_SOURCE_PASSWORD -destkeystore (Join-Path $BackupDirectory 'production.p12') -deststoretype PKCS12 -deststorepass:env RP_BACKUP_PASSWORD -destkeypass:env RP_BACKUP_PASSWORD -noprompt
    if ($LASTEXITCODE -ne 0) { throw 'Falló el respaldo de producción.' }
    & $keytool -importkeystore -srckeystore (Join-Path $privatePath 'legacy-debug.keystore') -srcalias androiddebugkey -srcstorepass:env RP_OLD_PASSWORD -destkeystore (Join-Path $BackupDirectory 'legacy.p12') -deststoretype PKCS12 -deststorepass:env RP_BACKUP_PASSWORD -destkeypass:env RP_BACKUP_PASSWORD -noprompt
    if ($LASTEXITCODE -ne 0) { throw 'Falló el respaldo de transición.' }
    Copy-Item -LiteralPath (Join-Path $privatePath 'signing-lineage.bin') -Destination (Join-Path $BackupDirectory 'signing-lineage.bin')
    Write-Output 'Respaldo cifrado creado. Guarda la contraseña por separado y no publiques las claves.'
} finally {
    foreach ($name in @('RP_BACKUP_PASSWORD','RP_SOURCE_PASSWORD','RP_OLD_PASSWORD')) { Remove-Item "Env:$name" -ErrorAction SilentlyContinue }
}
