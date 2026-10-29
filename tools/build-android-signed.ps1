param(
    [switch]$Initialize,
    [switch]$SkipBuild,
    [switch]$Arm64,
    [switch]$NoDirectInstaller = $true,
    [string]$OutputDirectory,
    [string]$JdkPath = $env:JAVA_HOME,
    [string]$SdkPath = $env:ANDROID_HOME,
    [string]$Flutter = 'flutter',
    [string]$BuildTools = '36.0.0'
)
$ErrorActionPreference = 'Stop'
$repoPath = Split-Path -Parent $PSScriptRoot
$privatePath = Join-Path $repoPath '.signing'
if (!$JdkPath) { throw 'Selecciona un JDK completo mediante JAVA_HOME o -JdkPath.' }
if (!$SdkPath) { $SdkPath = Join-Path $env:LOCALAPPDATA 'Android/sdk' }
$keytool = Join-Path $JdkPath 'bin/keytool.exe'
$apksigner = Join-Path $SdkPath "build-tools/$BuildTools/apksigner.bat"
$keyPath = Join-Path $privatePath 'rp-music-production.p12'
$passwordPath = Join-Path $privatePath 'password.dpapi'
$legacyPath = Join-Path $privatePath 'legacy-debug.keystore'
$lineage = Join-Path $privatePath 'signing-lineage.bin'
if (!(Test-Path -LiteralPath $keytool) -or !(Test-Path -LiteralPath $apksigner)) { throw 'Faltan keytool o apksigner.' }
if ($Initialize) {
    if (Test-Path -LiteralPath $keyPath) { throw 'La clave ya existe. No se sustituye una identidad de firma existente.' }
    New-Item -ItemType Directory -Path $privatePath -Force | Out-Null
    $sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    & icacls $privatePath /inheritance:r /grant:r "*${sid}:(OI)(CI)F" '*S-1-5-18:(OI)(CI)F' | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo restringir el acceso a las claves.' }
    $bytes = New-Object byte[] 48
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    $newPassword = [Convert]::ToBase64String($bytes)
    ConvertTo-SecureString $newPassword -AsPlainText -Force | ConvertFrom-SecureString | Set-Content -LiteralPath $passwordPath
    $env:RP_ANDROID_STORE_PASSWORD = $newPassword
    try {
        & $keytool -genkeypair -keystore $keyPath -storetype PKCS12 -alias rp_music -keyalg RSA -keysize 3072 -validity 10000 -dname 'CN=RP Music, O=RP Music' -storepass:env RP_ANDROID_STORE_PASSWORD -noprompt
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo generar la clave de producción.' }
        $originalLegacy = Join-Path $env:USERPROFILE '.android/debug.keystore'
        if (!(Test-Path -LiteralPath $originalLegacy)) { throw 'Falta la clave anterior necesaria para preservar actualizaciones.' }
        Copy-Item -LiteralPath $originalLegacy -Destination $legacyPath
    } finally {
        $newPassword = $null
        Remove-Item Env:RP_ANDROID_STORE_PASSWORD -ErrorAction SilentlyContinue
    }
}
foreach ($path in @($keyPath, $passwordPath, $legacyPath)) {
    if (!(Test-Path -LiteralPath $path)) { throw 'Falta configuración privada. Inicializa una sola vez con -Initialize.' }
}
$secure = (Get-Content -LiteralPath $passwordPath -Raw).Trim() | ConvertTo-SecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try { $env:RP_ANDROID_STORE_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
$env:RP_ANDROID_KEY_PASSWORD = $env:RP_ANDROID_STORE_PASSWORD
$env:RP_ANDROID_KEYSTORE = $keyPath
$env:RP_ANDROID_KEY_ALIAS = 'rp_music'
$env:RP_LEGACY_PASSWORD = 'android'
$env:RP_ANDROID_NO_DIRECT_INSTALLER = if ($NoDirectInstaller) { 'true' } else { 'false' }
try {
    # Compare the legacy identity with the already published certificate before
    # authorizing a new descendant. Passwords never appear in arguments/logs.
    $legacyInfo = & $keytool '-J-Duser.language=en' -list -v -keystore $legacyPath -alias androiddebugkey -storepass:env RP_LEGACY_PASSWORD 2>&1
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo leer el certificado anterior.' }
    $fingerprint = (($legacyInfo | Select-String 'SHA256:').Line -replace '.*SHA256:\s*','' -replace ':','').Trim().ToLowerInvariant()
    if ($fingerprint -ne 'eba2769ed11d359c8f89f6991bc6867c7766f6f46a4295bc5386e7d41ce7d38d') { throw 'La clave anterior no corresponde a RP Music publicado.' }
    if (!(Test-Path -LiteralPath $lineage)) {
        & $apksigner rotate --out $lineage --old-signer --ks $legacyPath --ks-key-alias androiddebugkey --ks-pass env:RP_LEGACY_PASSWORD --new-signer --ks $keyPath --ks-key-alias rp_music --ks-pass env:RP_ANDROID_STORE_PASSWORD
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo crear la prueba criptográfica de transición.' }
    }
    $env:JAVA_HOME = $JdkPath
    Push-Location $repoPath
    try {
        if (!$SkipBuild) {
            # Flutter tests can leave a dev-only plugin in this ignored,
            # generated registrant. Release builds exclude its dependency.
            $registrant = Join-Path $repoPath 'android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java'
            if (Test-Path -LiteralPath $registrant) {
                $generated = [IO.File]::ReadAllText($registrant)
                $testPlugin = '    try \{\s*flutterEngine\.getPlugins\(\)\.add\(new dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin\(\)\);\s*\} catch \(Exception e\) \{\s*Log\.e\(TAG, "Error registering plugin integration_test, dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin", e\);\s*\}\s*'
                if ([regex]::Matches($generated, $testPlugin).Count -gt 1) { throw 'Registro de pruebas ambiguo.' }
                [IO.File]::WriteAllText($registrant, [regex]::Replace($generated, $testPlugin, ''))
            }
            $flutterArgs = @('build','apk','--release','--no-pub')
            if ($Arm64) { $flutterArgs += @('--split-per-abi','--target-platform','android-arm64') }
            & $Flutter @flutterArgs
            if ($LASTEXITCODE -ne 0) { throw 'Compilación Android fallida.' }
        }
        $versionLine = (Select-String -LiteralPath (Join-Path $repoPath 'pubspec.yaml') -Pattern '^version: (\d+\.\d+\.\d+)\+(\d+)$').Matches
        if ($versionLine.Count -ne 1) { throw 'Versión de app no reconocida.' }
        $version = $versionLine[0].Groups[1].Value
        $buildCode = $versionLine[0].Groups[2].Value
        $sourceName = if ($Arm64) { 'app-arm64-v8a-release.apk' } else { 'app-release.apk' }
        $sourceApk = Join-Path $repoPath "build/app/outputs/flutter-apk/$sourceName"
        $aapt = Join-Path $SdkPath "build-tools/$BuildTools/aapt.exe"
        $badging = & $aapt dump badging $sourceApk
        if ($LASTEXITCODE -ne 0 -or !($badging -match "versionCode='$buildCode' versionName='$version'")) { throw 'El APK no corresponde a la versión actual.' }
        $permissionList = & $aapt dump permissions $sourceApk
        if ($LASTEXITCODE -ne 0) { throw 'No se pudieron verificar los permisos del APK.' }
        $installerPresent = [bool]($permissionList -match "android.permission.REQUEST_INSTALL_PACKAGES")
        if ($installerPresent -eq [bool]$NoDirectInstaller) { throw 'Los permisos no corresponden al perfil de compilación solicitado.' }
        $output = if ($OutputDirectory) { [IO.Path]::GetFullPath((Join-Path $repoPath $OutputDirectory)) } else { Join-Path $repoPath 'dist/play-protect-review' }
        New-Item -ItemType Directory -Path $output -Force | Out-Null
        $platformName = if ($Arm64) { 'android-arm64' } else { 'android' }
        $edition = if ($NoDirectInstaller) { '-manual-updates' } else { '' }
        $apk = Join-Path $output "RP-Music-$version-$platformName$edition-review.apk"
        # Older Android versions retain their existing signer; Android 9+ use
        # the production signer plus a platform-verified proof of rotation.
        & $apksigner sign --ks $legacyPath --ks-key-alias androiddebugkey --ks-pass env:RP_LEGACY_PASSWORD --next-signer --ks $keyPath --ks-key-alias rp_music --ks-pass env:RP_ANDROID_STORE_PASSWORD --lineage $lineage --rotation-min-sdk-version 28 --v4-signing-enabled false --out $apk $sourceApk
        if ($LASTEXITCODE -ne 0) { throw 'Firma con transición fallida.' }
        & $apksigner verify --verbose --print-certs $apk
        if ($LASTEXITCODE -ne 0) { throw 'Verificación de firmas fallida.' }
        $legacyVerified = & $apksigner verify --min-sdk-version 23 --max-sdk-version 27 --print-certs $apk
        if ($LASTEXITCODE -ne 0 -or !($legacyVerified -match "certificate SHA-256 digest: $fingerprint")) { throw 'No se conserva la firma necesaria en Android antiguo.' }
        $modernVerified = & $apksigner verify --min-sdk-version 28 --max-sdk-version 32 --print-certs $apk
        if ($LASTEXITCODE -ne 0 -or ($modernVerified -match "certificate SHA-256 digest: $fingerprint") -or !($modernVerified -match 'certificate DN: CN=RP Music, O=RP Music')) { throw 'No se activó la firma de producción en Android moderno.' }
        Copy-Item -LiteralPath $apk -Destination $sourceApk -Force
        $hashLines = @(Get-ChildItem -LiteralPath $output -Filter '*.apk' -File | Sort-Object Name | ForEach-Object {
            "$((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant())  $($_.Name)"
        })
        [IO.File]::WriteAllText((Join-Path $output 'SHA256SUMS.txt'), ($hashLines -join "`n") + "`n")
        Write-Output 'APK de revisión preparado. El resultado de Play Protect todavía requiere verificación independiente.'
    } finally { Pop-Location }
} finally {
    foreach ($name in @('RP_ANDROID_STORE_PASSWORD','RP_ANDROID_KEY_PASSWORD','RP_ANDROID_KEYSTORE','RP_ANDROID_KEY_ALIAS','RP_LEGACY_PASSWORD','RP_ANDROID_NO_DIRECT_INSTALLER')) { Remove-Item "Env:$name" -ErrorAction SilentlyContinue }
}
