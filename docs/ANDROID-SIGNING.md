# Firma de Android y conservación de identidad

La configuración release usa producción y rechaza compilar sin credenciales; no vuelve silenciosamente a debug. tools/build-android-signed.ps1 configura credenciales solo en el proceso, firma y valida el APK final. Inicializar una sola vez con -Initialize y un JDK completo; las siguientes ejecuciones reutilizan las claves. Nunca regenerarlas para quitar una advertencia.

.signing/ está excluido de Git. ClaveRSA3072, contraseña aleatoria protegida por WindowsDPAPI y permisos de carpeta restringidos al usuario/SYSTEM. No poner claves/contraseñas en README, bóveda, logs, APK ni repositorio. El certificado y su huella son públicos.

Para un respaldo recuperable en otro equipo, ejecutar tools/backup-android-signing.ps1 -BackupDirectory <carpeta nueva y privada> -JdkPath <JDK>. Pide una contraseña interactiva, reprotege los almacenes con ella y copia la prueba de rotación. Guardar la contraseña por separado en un gestor y custodiar ese respaldo. DPAPI por sí solo depende del perfil Windows original; no confiar en copiar password.dpapi a otro equipo como recuperación. El helper de respaldo no se ejecutó automáticamente ni se eligió una contraseña por el usuario.

La prueba de rotación enlaza la clave histórica con la nueva. Android9+ usa producción; Android6–8 usa aún el firmante anterior para que los usuarios puedan actualizar. No cambiar applicationId ni desinstalar. El actualizador0.3.14 reconoce descendientes verificados por Android; la versión0.3.13 exige igualdad exacta y la primera transición debe abrirse desde Archivos/Descargas. Android vuelve a verificar firma/linaje en la instalación; no se omite su comprobación.

La distribución pública debe usar el resultado final de tools/build-android-signed.ps1 (también copiado a app-release.apk después de validar), no un APK intermedio firmado directamente por Gradle. Verificar SHA256, versión/código, ABI y certificados por rangos de SDK antes de publicar. Las claves no certifican que una app sea segura ni garantizan cambiar un veredicto de Play Protect.
