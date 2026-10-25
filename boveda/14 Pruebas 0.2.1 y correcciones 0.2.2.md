---
tipo: pruebas-y-correcciones
estado: publicado-con-validacion-local
actualizado: 2026-10-25
---
# Pruebas 0.2.1 y correcciones 0.2.2

## Informe del usuario

- Galaxy A34 5G: falta control multimedia en notificaciones; el ajuste parece bloqueado. La primera carga mejoró notablemente. Las listas recuperan canciones al volver a una raíz anterior.
- PC Windows 11 Pro 26H2, descrita como Ryzen 5 5800G: ya no se cierra al cambiar pistas y reconoce formatos. Faltan volumen dentro de la app y funcionamiento en segundo plano; cerrar completamente tarda y produce ruido/entre cortes.
- Poco X6 Pro: tampoco tiene controles multimedia en notificaciones. El usuario considera posible fallo global, pero no se comprobó en todos los dispositivos.
- Tecno Pova 7 4G: 0.2.1 no se instala incluso desinstalando la anterior; la versión anterior sí. Aclaración: Android 16, APK de GitHub y mensaje «no se instaló la app porque parece que el paquete no es válido». No hubo aviso de antivirus.
- La sugerencia inicial de pedir permisos de archivos para evitar antivirus es una hipótesis del usuario, no una causa confirmada. No se añaden permisos generales por ese motivo: SAF ya concede lectura de la carpeta elegida.

## Implementación local 0.2.2+4

- Estado multimedia: además de los eventos de carga, se observan los cambios de `playerStateStream`. Publica reproducir/pausar al servicio Android; antes esos cambios podían no propagarse al servicio.
- `POST_NOTIFICATIONS`, solicitud nativa una vez al entrar en esta versión en Android 13+, estado de permiso y acceso a ajustes. Permiso denegado no bloquea la base. Icono monocromo propio conservado ante reducción de recursos. Las notificaciones de sesiones multimedia tienen exención específica en Android; pedir permiso no constituye por sí solo el diagnóstico completo.
- Volumen software 0–100 %, silenciar/restaurar y persistencia del nivel. No modifica el volumen global del sistema.
- Windows: canal Win32 propio para bandeja y coordinación de cierre, sin dependencias externas nuevas. Cerrar mantiene reproducción en bandeja por defecto; ajuste persistente para salir con la X. Menú Abrir/Reproducir-Pausar/Salir. Restauración de icono al reiniciar Explorer; si no se puede mantener icono, evita ocultar una app inaccesible.
- Cierre: idempotente, invalida selecciones, silencia y pausa antes de guardar/stop/dispose. Cancela suscripciones sin esperar relojes de consumidores y espera cargas solo si están en curso. El proceso nativo se destruye después de liberar el reproductor.
- Se preparan APK universal y variante ARM64 con la misma versión/certificado; no se presenta la variante como corrección confirmada de instalación.
- Script manual `tools/diagnosticar-instalacion.ps1` para recoger `INSTALL_FAILED_...`, ABI y hash mediante ADB sin desinstalar ni borrar datos. No se ejecuta sobre el teléfono del usuario.

## Evidencia

- APK 0.2.1 local: `apksigner verify` correcto, esquema v2, mismo certificado SHA-256 que 0.2.0. SDK mínimo 24, objetivo 36; ARM64, ARM32 y x64 presentes.
- `zipalign -c -P 16`: correcto. ELF ARM64: `libapp.so`/`libflutter.so` con LOAD 0x10000 y `libdartjni.so` con 0x4000. No se atribuye el fallo a alineación sin evidencia.
- 25 pruebas unitarias/de widgets aprobadas: incluye estado multimedia dinámico, permisos, volumen persistente, cierre/bandeja y regresiones anteriores. Análisis estático final limpio.
- Prueba nativa Windows final con volumen 0,35 y ocultar/restaurar ventana manteniendo audio, cambios repetidos y cierre del reproductor: aprobada. El ruido subjetivo de salida en la PC del usuario aún requiere retesteo con su música.
- Compilaciones release completas: APK universal, APK ARM64 y Windows x64; paquetes locales verificados en `dist/0.2.2`. Firmas v2 correctas, versión 0.2.2 y código 4 compartido por ambos APK. Icono de notificación y permiso presentes en el APK reducido por R8; sin permisos generales de lectura de medios.
- Se detectó que `--target-platform android-arm64` por sí solo dejaba bibliotecas JNI de otras arquitecturas. La variante definitiva usa `--split-per-abi --target-platform android-arm64` y `force-version-code-ignoring-abi` condicionado en Gradle. AAPT confirma exclusivamente `arm64-v8a` y código 4, permitiendo futuras actualizaciones entre universal/ARM64 sin inflar el código de versión. Este hallazgo de empaquetado de la variante no se presenta como causa del rechazo del universal 0.2.1.
- APK universal: 54 236 904 bytes; ARM64: 19 132 725 bytes; ZIP Windows: 12 815 787 bytes. ZIP comprobado con EXE, motor, backend de audio, datos y guía, sin plugin de integración.
- Guía `docs/PRUEBAS-0.2.2.md`, script ADB manual con sintaxis comprobada sin ejecutarlo sobre un teléfono y SHA-256 de los paquetes. No se publicó una nueva release ni se enviaron estos cambios a GitHub.
- No se ha reproducido la instalación en Tecno ni comprobado físicamente la notificación en Android. Faltan código exacto del instalador y nuevos resultados del usuario. No se promete resolver el aviso de instalación solo por añadir permisos.

## Fuentes

- [Android: permiso de notificaciones y exenciones multimedia](https://developer.android.com/develop/ui/views/notifications/notification-permission).
- [audio_service](https://pub.dev/packages/audio_service).

Consultadas el 2026-10-25 junto con las fuentes locales y el manifiesto. La versión se mantuvo local durante las correcciones; su publicación autorizada se registra a continuación.

Relaciones: [[13 Pruebas reales y correcciones 0.2.1]], [[03 Biblioteca y reproduccion]], [[05 Rendimiento]], [[10 Estado del repositorio]], [[09 Registro de cambios]].

## Publicación solicitada

El usuario autorizó crear una nueva release. Se prepara `v0.2.2-alpha.1` como preliminar con las fuentes correspondientes, ambos APK, ZIP Windows, guías, ejemplo, diagnóstico manual y SHA-256. Se mantienen los binarios ya verificados y se actualizan las guías empaquetadas. Confirmar URL, commit y adjuntos tras publicar.

## Publicación confirmada — 2026-10-25

- [Release v0.2.2-alpha.1](https://github.com/Joao-s02/rp_music/releases/tag/v0.2.2-alpha.1), confirmada como publicada (`isDraft=false`) y preliminar (`isPrerelease=true`).
- Etiqueta sobre `9f1e4f80966d5d020235200e23b6b58170c8b7fc`; fuentes publicadas en `main`. La actualización de esta confirmación es posterior al commit etiquetado.
- Ocho adjuntos: APK universal, APK ARM64, ZIP Windows, `USO.md`, `PRUEBAS-0.2.2.md`, script de diagnóstico manual, ejemplo `descubrir.json` y SHA-256.
- Verificación automática de todos los tamaños y digest SHA-256 publicados contra los archivos locales; todos en estado `uploaded`. Ambos APK mantienen sus binarios compilados y firmas verificadas. No se descargaron nuevamente desde GitHub.
- Se actualizaron y reempaquetaron las guías para distribución; ZIP final de 12 819 019 bytes. No se sustituyeron releases anteriores.
- Instalación Tecno, notificaciones en teléfonos y sonido de cierre subjetivo en la PC siguen pendientes de retesteo: publicar la release no modifica esos límites.
