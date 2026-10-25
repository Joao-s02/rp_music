param(
    [Parameter(Mandatory = $true)][string]$ApkPath,
    [string]$DeviceSerial,
    [string]$OutputPath = 'diagnostico-instalacion.txt'
)

# Run manually with the phone connected and USB debugging authorized.
# Installs/updates the supplied APK. Never uninstalls or clears application data.
$ErrorActionPreference = 'Stop'
$resolvedApk = (Resolve-Path -LiteralPath $ApkPath).Path
$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
$adb = if ($adbCommand) { $adbCommand.Source } else {
    Join-Path $env:LOCALAPPDATA 'Android/Sdk/platform-tools/adb.exe'
}
if (-not (Test-Path -LiteralPath $adb)) { throw 'No se encontró adb del Android SDK.' }
if (-not $DeviceSerial) {
    $devices = @(& $adb devices | Where-Object { $_ -match '^\S+\s+device$' })
    if ($devices.Count -ne 1) { throw 'Conecta y autoriza un solo teléfono, o indica -DeviceSerial.' }
    $DeviceSerial = ($devices[0] -split '\s+')[0]
}
$deviceArgs = @('-s', $DeviceSerial)
$model = & $adb @deviceArgs shell getprop ro.product.model
$android = & $adb @deviceArgs shell getprop ro.build.version.release
$abis = & $adb @deviceArgs shell getprop ro.product.cpu.abilist
$hash = (Get-FileHash -LiteralPath $resolvedApk -Algorithm SHA256).Hash
try {
    $ErrorActionPreference = 'Continue'
    $result = @(& $adb @deviceArgs install -r $resolvedApk 2>&1 | ForEach-Object { $_.ToString() })
    $installExit = $LASTEXITCODE
} finally { $ErrorActionPreference = 'Stop' }
@("Modelo: $model", "Android: $android", "ABI: $abis", "APK SHA256: $hash", "Código de salida: $installExit", '', $result) |
    Set-Content -LiteralPath $OutputPath -Encoding utf8
Write-Output "Diagnóstico guardado en $OutputPath"
Write-Output $result
if ($installExit -ne 0) { exit $installExit }
