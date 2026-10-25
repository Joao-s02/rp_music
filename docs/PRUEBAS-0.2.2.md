# Versión local 0.2.2 — notificaciones, volumen y bandeja

## Android

- Al abrir por primera vez esta versión en Android 13 o posterior se solicita el permiso de notificaciones. Si lo denegaste, la biblioteca y reproducción local siguen disponibles.
- En **Ajustes → Notificaciones de reproducción** puedes solicitarlo o abrir los ajustes del sistema. Después reproduce una canción y comprueba los controles en notificaciones y en la pantalla de bloqueo; pausa y reanuda desde ellos.
- Se corrigió la publicación de los cambios reproducir/pausar hacia la sesión multimedia. El permiso por sí solo no demuestra que la notificación funcione en cada teléfono.
- Los archivos se autorizan con el selector de carpeta de Android; no se pide acceso general a todo el almacenamiento. Más permisos no garantizan evitar advertencias de antivirus.

## Windows

- La barra inferior incorpora volumen de la aplicación y silenciar. Se guarda el nivel elegido.
- Por defecto, cerrar la ventana mantiene RP Music reproduciendo en la **bandeja del sistema**. Si no ves el icono, busca entre los iconos ocultos junto al reloj.
- Pulsa el icono para abrir la ventana. Con clic derecho tienes **Abrir RP Music**, **Reproducir / Pausar** y **Salir**.
- **Salir** cierra por completo: primero silencia/pausa, guarda la sesión y libera el audio, y después destruye la ventana.
- En **Ajustes**, desactiva **Seguir reproduciendo al cerrar la ventana** si prefieres que la X cierre por completo.
- Si no se puede crear el icono, la app sale ordenadamente en lugar de quedar oculta sin acceso.

Prueba bajar/subir volumen, silenciar, cerrar a bandeja, seguir escuchando, restaurar y salir. Comprueba también cerrar con la preferencia desactivada y reabrir: la canción debe restaurarse en pausa. Falta confirmar la ausencia del ruido de cierre con audio real en la PC del usuario.

## Tecno Pova 7 4G — instalación pendiente de diagnóstico

El usuario informó Android 16 y «no se instaló la app porque parece que el paquete no es válido», incluso tras desinstalar la anterior. La descarga fue desde GitHub; no hubo aviso del antivirus.

El APK 0.2.1 local pasa verificación de firma, usa el mismo certificado que 0.2.0, incluye ARM32/ARM64/x64 y pasa alineación ZIP de 16 KB; sus ELF ARM64 también tienen alineación suficiente. Esto no confirma que el archivo recibido por el teléfono sea idéntico ni explica todavía el rechazo.

Se preparan APK universal y una variante **solo ARM64**, más pequeña, con el mismo identificador/firma y versión. La variante es una alternativa de prueba, **no una solución confirmada** al error del Tecno. Si el universal vuelve a fallar, prueba ARM64 en ese dispositivo. No cambies el nombre de un ZIP de fuentes a APK.

Si vuelve a fallar, hace falta el código `INSTALL_FAILED_...` del instalador. Conecta y autoriza ese teléfono con depuración USB y ejecuta desde PowerShell en el proyecto:

```powershell
./tools/diagnosticar-instalacion.ps1 -ApkPath ./dist/0.2.2/RP-Music-0.2.2-android-arm64.apk
```

El script instala/actualiza el APK seleccionado y genera `diagnostico-instalacion.txt` con modelo, Android, ABI, hash y respuesta de instalación. No desinstala ni borra datos. Revisa el archivo antes de compartirlo. Si hay varios dispositivos, utiliza `-DeviceSerial`.

## Alcance

Distribución preliminar [0.2.2-alpha.1 en GitHub](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.2-alpha.1). Se conservan catálogo y listas de `v2`. La firma Android sigue siendo de desarrollo. No se afirma que el fallo de instalación esté corregido hasta probarlo en el teléfono.
