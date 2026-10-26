param(
    [Parameter(Mandatory = $true)][string]$ApkPath,
    [Parameter(Mandatory = $true)][string]$SdkPath
)
$ErrorActionPreference = 'Stop'
$apk = (Resolve-Path -LiteralPath $ApkPath).Path
$buildTools = Get-ChildItem -LiteralPath (Join-Path $SdkPath 'build-tools') -Directory |
    Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'aapt.exe') } |
    Sort-Object { [version]($_.Name -replace '-.*$', '') } -Descending |
    Select-Object -First 1
if ($null -eq $buildTools) { throw 'No se encontró AAPT en el SDK indicado.' }
$resources = & (Join-Path $buildTools.FullName 'aapt.exe') dump resources $apk
if ($LASTEXITCODE -ne 0) { throw 'No se pudo leer la tabla de recursos del APK.' }
$required = @('ic_stat_music', 'audio_service_play_arrow', 'audio_service_pause', 'audio_service_skip_next', 'audio_service_skip_previous', 'audio_service_stop', 'rp_play', 'rp_pause', 'rp_next', 'rp_previous', 'rp_stop')
foreach ($icon in $required) {
    if (-not ($resources -match (':drawable/' + [regex]::Escape($icon) + ':'))) {
        throw "Falta el icono dinámico $icon. No distribuir este APK: puede fallar la sesión multimedia."
    }
}
Write-Output 'Correcto: el APK conserva el icono de notificación y todas las acciones multimedia utilizadas.'
